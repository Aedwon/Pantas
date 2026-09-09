import 'dart:async';

import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';

typedef QuizCompletionCommitted = void Function();

/// The one application owner for durable terminal quiz completion.
///
/// For persisted sessions the Attempt and `quiz_sessions.completedAt` are
/// committed in the same recorded database transaction. Streak/notification
/// effects happen only after the durable terminal state exists.
class QuizCompletionCoordinator {
  QuizCompletionCoordinator({
    required AttemptsRepository attempts,
    required QuizSessionRepository sessions,
    StreakEvaluator? streakEvaluator,
    NotificationService? notifications,
    QuizCompletionCommitted? onCommitted,
  })  : _attempts = attempts,
        _sessions = sessions,
        _streakEvaluator = streakEvaluator,
        _notifications = notifications,
        _onCommitted = onCommitted;

  final AttemptsRepository _attempts;
  final QuizSessionRepository _sessions;
  final StreakEvaluator? _streakEvaluator;
  final NotificationService? _notifications;
  final QuizCompletionCommitted? _onCommitted;
  final Map<String, Future<Attempt>> _inFlight = <String, Future<Attempt>>{};

  Future<Attempt> complete({
    required QuizSession session,
    required DateTime now,
    required bool persisted,
  }) {
    final existing = _inFlight[session.sessionId];
    if (existing != null) return existing;

    late final Future<Attempt> future;
    future = _complete(session: session, now: now, persisted: persisted);
    _inFlight[session.sessionId] = future;
    void clear() {
      if (identical(_inFlight[session.sessionId], future)) {
        _inFlight.remove(session.sessionId);
      }
    }

    unawaited(
      future.then<void>(
        (_) => clear(),
        onError: (Object _, StackTrace __) => clear(),
      ),
    );
    return future;
  }

  Future<Attempt> _complete({
    required QuizSession session,
    required DateTime now,
    required bool persisted,
  }) async {
    if (!session.isComplete) {
      throw StateError('Cannot complete a quiz with unanswered questions');
    }

    if (persisted) {
      final completedAt = await _sessions.completedAtFor(session.sessionId);
      if (completedAt != null) {
        final existing = await _attempts.byId(session.sessionId);
        if (existing == null) {
          throw StateError(
            'Persisted quiz session ${session.sessionId} is complete '
            'without an Attempt',
          );
        }
        return existing;
      }
    }

    final attempt = Attempt(
      id: session.sessionId,
      examId: session.examId,
      origin: session.origin.storageValue,
      startedAt: session.startedAt,
      completedAt: now,
      items: session.outcomes
          .map(
            (outcome) => AttemptItem(
              questionId: outcome.questionId,
              questionVersion: outcome.questionVersion,
              chosenChoiceId: outcome.chosenChoiceId,
              correctChoiceId: outcome.correctChoiceId,
              responseMs: outcome.responseMs,
            ),
          )
          .toList(growable: false),
    );

    await _attempts.saveAtomically<void>(attempt, () async {
      if (!persisted) return;
      await _sessions.completeRequired(
        sessionId: session.sessionId,
        completedAt: now,
      );
    });

    _onCommitted?.call();
    await _streakEvaluator?.evaluate(
      origin: session.origin,
      completedAt: now,
    );
    await _notifications?.onSessionCompleted();
    return attempt;
  }
}
