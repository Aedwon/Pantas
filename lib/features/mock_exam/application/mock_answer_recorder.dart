import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';
import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';

/// Records a submitted mock's answers the way every other answer is recorded,
/// so missed mock questions come back as reviews and topic scores include
/// them (roadmap spec 4.7, which reverses the May mock spec's D4).
///
/// It follows the placement assessment: one attempt row with untimed items,
/// and each answered question rated good or again at submission. There is no
/// review log row because the mock has no per-question timing to record.
///
/// Idempotent by mock attempt id: the attempt row and the review states are
/// written in one transaction, and an existing row means it was already done.
class MockAnswerRecorder {
  MockAnswerRecorder({
    required MockAttemptRepo mocks,
    required AttemptsRepository attempts,
    required ReviewStateRepository reviews,
    required ContentRepository content,
    required FsrsScheduler scheduler,
    MockPayloadReader payloadReader = const MockPayloadReader(),
  })  : _mocks = mocks,
        _attempts = attempts,
        _reviews = reviews,
        _content = content,
        _scheduler = scheduler,
        _payloadReader = payloadReader;

  final MockAttemptRepo _mocks;
  final AttemptsRepository _attempts;
  final ReviewStateRepository _reviews;
  final ContentRepository _content;
  final FsrsScheduler _scheduler;
  final MockPayloadReader _payloadReader;

  /// Records one mock. Returns true when this call wrote the answers.
  Future<bool> record(String mockAttemptId) async {
    final mock = await _mocks.findById(mockAttemptId);
    if (mock == null) return false;
    return _record(mock);
  }

  /// Records every submitted mock of [examId] that has not been recorded,
  /// which heals a crash between submitting a mock and recording it.
  /// Returns how many mocks this call recorded.
  Future<int> reconcile(String examId) async {
    var recorded = 0;
    for (final mock in await _mocks.answeredTerminalForExam(examId)) {
      if (await _record(mock)) recorded++;
    }
    return recorded;
  }

  Future<bool> _record(MockAttempt mock) async {
    final submittedAt = mock.submittedAt;
    if (submittedAt == null) return false;
    if (mock.status != MockAttemptStatus.completed &&
        mock.status != MockAttemptStatus.forfeited) {
      return false;
    }
    if (await _attempts.byId(mock.id) != null) return false;

    final payload = _payloadReader.read(
      sampledQuestionsJson: mock.sampledQuestionsJson,
      answersJson: mock.answersJson,
      flagsJson: mock.flagsJson,
    );
    final answeredIds = [
      for (final section in payload.sections)
        for (final questionId in section.questionIds)
          if (payload.answers.containsKey(questionId)) questionId,
    ];
    final questions = await _content.questionsByIds(answeredIds);

    final items = <AttemptItem>[];
    final ratings = <({String questionId, int version, Rating rating})>[];
    for (final questionId in answeredIds) {
      final question = questions[questionId];
      // A question withdrawn or retired since the mock has nothing to review.
      if (question == null) continue;
      final index = payload.answers[questionId]!.selectedIndex;
      if (index < 0 || index >= question.choices.length) continue;
      final chosen = question.choices[index];
      final correct = question.choices.firstWhere((c) => c.isCorrect);
      items.add(
        AttemptItem(
          questionId: questionId,
          questionVersion: question.version,
          chosenChoiceId: chosen.id,
          correctChoiceId: correct.id,
          responseMs: 0,
        ),
      );
      ratings.add(
        (
          questionId: questionId,
          version: question.version,
          rating: chosen.isCorrect ? Rating.good : Rating.again,
        ),
      );
    }

    final attempt = Attempt(
      id: mock.id,
      examId: mock.examId,
      startedAt: mock.startedAt,
      completedAt: submittedAt,
      origin: AttemptOrigins.mock,
      items: items,
    );
    await _attempts.saveAtomically<void>(attempt, () async {
      for (final entry in ratings) {
        final existing = await _reviews.byQuestionId(entry.questionId);
        final prev = existing ??
            ReviewState.seed(
              questionId: entry.questionId,
              questionVersion: entry.version,
              now: submittedAt,
            );
        await _reviews.upsert(
          _scheduler.next(prev: prev, rating: entry.rating, now: submittedAt),
        );
      }
    });
    return true;
  }
}
