import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/sync/engine/pending_queue.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/streak/streak_evaluator.dart';

class CompleteQuiz {
  CompleteQuiz(
    this._attempts, {
    StreakEvaluator? streakEvaluator,
    PendingQueue? pendingQueue,
    NotificationService? notifications,
  })  : _streakEvaluator = streakEvaluator,
        _pendingQueue = pendingQueue,
        _notifications = notifications;

  final AttemptsRepository _attempts;
  final StreakEvaluator? _streakEvaluator;
  final PendingQueue? _pendingQueue;
  final NotificationService? _notifications;

  Future<Attempt> call({
    required QuizSession session,
    required DateTime now,
  }) async {
    if (!session.isComplete) {
      throw StateError('Cannot complete a quiz with unanswered questions');
    }
    final attempt = Attempt(
      id: session.sessionId,
      examId: session.examId,
      origin: session.origin.storageValue,
      startedAt: session.startedAt,
      completedAt: now,
      items: session.outcomes
          .map(
            (o) => AttemptItem(
              questionId: o.questionId,
              questionVersion: o.questionVersion,
              chosenChoiceId: o.chosenChoiceId,
              correctChoiceId: o.correctChoiceId,
              responseMs: o.responseMs,
            ),
          )
          .toList(),
    );
    await _attempts.save(attempt);
    await _pendingQueue?.enqueue(
      tableType: 'quiz_attempts',
      rowId: attempt.id,
      op: PendingSyncOp.upsert,
      queuedAt: now,
    );
    await _streakEvaluator?.evaluate(
      origin: session.origin,
      completedAt: now,
    );
    await _notifications?.onSessionCompleted();
    return attempt;
  }
}
