import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/storage/data/repos/review_log_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/review_log.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/quiz/data/repos/new_card_intro_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/rating_heuristic.dart';

class SubmitAnswer {
  SubmitAnswer({
    required ReviewStateRepository reviewRepo,
    required FsrsScheduler scheduler,
    QuizSessionRepository? sessions,
    NewCardIntroRepository? newCards,
    ReviewLogRepository? reviewLog,
    Telemetry? telemetry,
  })  : _telemetry = telemetry,
        _reviewLog = reviewLog,
        _reviewRepo = reviewRepo,
        _scheduler = scheduler,
        _sessions = sessions,
        _newCards = newCards;

  final ReviewStateRepository _reviewRepo;
  final ReviewLogRepository? _reviewLog;
  final FsrsScheduler _scheduler;
  final QuizSessionRepository? _sessions;
  final NewCardIntroRepository? _newCards;
  final Telemetry? _telemetry;

  Future<AnswerOutcome> call({
    required Question question,
    required String chosenChoiceId,
    required int responseMs,
    required DateTime now,
    String? sessionId,
    String? userId,
    ExamId? examId,
    String? origin,
  }) async {
    final correctId = question.correctChoice.id;
    final isCorrect = chosenChoiceId == correctId;

    final chosenChoice = question.choices.firstWhere(
      (c) => c.id == chosenChoiceId,
      orElse: () => Choice(
        id: chosenChoiceId,
        label: chosenChoiceId,
        text: '',
        isCorrect: isCorrect,
      ),
    );

    await _telemetry?.log(
      TelemetryEvent.questionAnswered,
      properties: {
        'question_id': question.id,
        'is_correct': isCorrect,
        'chosen_label': chosenChoice.label,
        'origin': origin ?? 'unknown',
      },
    );

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
    final nextIntervalDays = next.scheduledDays.ceil();
    await _reviewRepo.upsert(next);

    // Written with the state as it was before this review, and with the exact
    // rating the scheduler was handed. A row recording anything else is worse
    // than no row, because a fit would learn from a review that never happened
    // that way.
    await _reviewLog?.insert(
      ReviewLog(
        id: '${question.id}-${now.microsecondsSinceEpoch}',
        questionId: question.id,
        rating: rating,
        state: prev.stage,
        due: prev.due,
        stability: prev.stability,
        difficulty: prev.difficulty,
        elapsedDays: prev.elapsedDays,
        lastElapsedDays: prev.elapsedDays,
        scheduledDays: prev.scheduledDays,
        review: now,
        durationMs: responseMs,
        isCorrect: isCorrect,
        heuristicVersion: kRatingHeuristicVersion,
      ),
    );
    final outcome = AnswerOutcome(
      questionId: question.id,
      questionVersion: question.version,
      chosenChoiceId: chosenChoiceId,
      correctChoiceId: correctId,
      responseMs: responseMs,
      derivedRating: rating,
      nextReviewIntervalDays: nextIntervalDays < 1 ? 1 : nextIntervalDays,
    );
    if (sessionId != null) {
      await _sessions?.recordAnswer(
        sessionId: sessionId,
        outcome: outcome,
        answeredAt: now,
      );
    }
    if (existing == null && userId != null && examId != null) {
      await _newCards?.incrementForDay(
        userId: userId,
        examId: examId,
        day: now,
      );
    }

    return outcome;
  }
}
