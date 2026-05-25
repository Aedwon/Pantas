import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/core/sync/engine/pending_queue.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/new_card_intro_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/rating_heuristic.dart';

class SubmitAnswer {
  SubmitAnswer({
    required ReviewStateRepository reviewRepo,
    required FsrsScheduler scheduler,
    QuizSessionRepository? sessions,
    PendingQueue? pendingQueue,
    NewCardIntroRepository? newCards,
  })  : _reviewRepo = reviewRepo,
        _scheduler = scheduler,
        _sessions = sessions,
        _pendingQueue = pendingQueue,
        _newCards = newCards;

  final ReviewStateRepository _reviewRepo;
  final FsrsScheduler _scheduler;
  final QuizSessionRepository? _sessions;
  final PendingQueue? _pendingQueue;
  final NewCardIntroRepository? _newCards;

  Future<AnswerOutcome> call({
    required Question question,
    required String chosenChoiceId,
    required int responseMs,
    required DateTime now,
    String? sessionId,
    String? userId,
    ExamId? examId,
  }) async {
    final correctId = question.correctChoice.id;
    final isCorrect = chosenChoiceId == correctId;

    final existing = await _reviewRepo.byQuestionId(question.id);
    final prev = existing ??
        ReviewState.seed(
          questionId: question.id,
          questionVersion: question.version,
          now: now,
        );

    final rating =
        RatingHeuristic.from(isCorrect: isCorrect, responseMs: responseMs);
    final next = _scheduler.next(prev: prev, rating: rating, now: now);
    await _reviewRepo.upsert(next);
    if (sessionId != null) {
      await _sessions?.recordAnswer(
        sessionId: sessionId,
        isCorrect: isCorrect,
        answeredAt: now,
      );
    }
    await _pendingQueue?.enqueue(
      tableType: 'fsrs_cards',
      rowId: question.id,
      op: PendingSyncOp.upsert,
      queuedAt: now,
    );
    if (existing == null && userId != null && examId != null) {
      await _newCards?.incrementForDay(
        userId: userId,
        examId: examId,
        day: now,
      );
    }

    return AnswerOutcome(
      questionId: question.id,
      questionVersion: question.version,
      chosenChoiceId: chosenChoiceId,
      correctChoiceId: correctId,
      responseMs: responseMs,
    );
  }
}
