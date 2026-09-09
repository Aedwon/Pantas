import 'dart:async';

import 'package:meta/meta.dart';
import 'package:pantas/features/quiz/application/quiz_preparation_stamp.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_today_session.dart';

sealed class QuizLaunchResult {
  const QuizLaunchResult();
}

@immutable
class QuizLaunchStarted extends QuizLaunchResult {
  const QuizLaunchStarted(this.session);

  final QuizSession session;
}

@immutable
class QuizLaunchNoQuestions extends QuizLaunchResult {
  const QuizLaunchNoQuestions(this.message);

  final String message;
}

@immutable
class QuizLaunchCancelled extends QuizLaunchResult {
  const QuizLaunchCancelled({this.persistedSession});

  final QuizSession? persistedSession;
}

typedef PreparedTodayPersister = Future<StartTodaySessionResult?> Function({
  required QuizPreparationRequest request,
  required PreparedTodaySession prepared,
  required bool Function() canPersist,
});

typedef ReadActiveTodaySession = Future<QuizSession?> Function(
  QuizPreparationRequest request,
);

class QuizLaunchCoordinator {
  QuizLaunchCoordinator({
    required TodayQuizPreparer preparer,
    required PreparedTodayPersister persist,
    required ReadActiveTodaySession readActive,
  })  : _preparer = preparer,
        _persist = persist,
        _readActive = readActive;

  final TodayQuizPreparer _preparer;
  final PreparedTodayPersister _persist;
  final ReadActiveTodaySession _readActive;
  final Map<QuizPreparationRequest, _LaunchOperation> _inFlight =
      <QuizPreparationRequest, _LaunchOperation>{};
  final Map<QuizPreparationRequest, _CommittedLaunch> _committed =
      <QuizPreparationRequest, _CommittedLaunch>{};

  Future<QuizLaunchResult> launchToday(
    QuizPreparationRequest request, {
    PreparedTodaySession? prepared,
  }) {
    final existing = _inFlight[request];
    if (existing != null) return existing.future;

    final operation = _LaunchOperation();
    late final Future<QuizLaunchResult> future;
    future = _launch(request, prepared, operation);
    operation.future = future;
    _inFlight[request] = operation;
    void clear() {
      if (identical(_inFlight[request], operation)) {
        _inFlight.remove(request);
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

  /// Returns the already-persisted active session and never creates one.
  Future<QuizSession?> resumeToday(QuizPreparationRequest request) {
    return _readActive(request);
  }

  void cancel(QuizPreparationRequest request) {
    _inFlight[request]?.cancelled = true;
  }

  void clearCommitted(QuizPreparationRequest request) {
    _committed.remove(request);
  }

  void clearAllCommitted() {
    _committed.clear();
  }

  Future<QuizLaunchResult> _launch(
    QuizPreparationRequest request,
    PreparedTodaySession? supplied,
    _LaunchOperation operation,
  ) async {
    final reusable = await _reusablePersistedSession(request);
    if (reusable != null) return QuizLaunchStarted(reusable);
    if (operation.cancelled) return const QuizLaunchCancelled();

    final canonical = await _preparer.prepare(request);
    if (operation.cancelled) return const QuizLaunchCancelled();

    // The shared preparer is the freshness authority. A supplied preview is
    // consumed by identity when still current; a stale one is replaced by the
    // preparer's newly revalidated snapshot before persistence.
    final prepared = identical(canonical, supplied) ? supplied! : canonical;

    // Revalidate once more at the launch boundary. This is normally the same
    // cached object and therefore does not reselect or rehydrate.
    final revalidated = await _preparer.prepare(request);
    if (operation.cancelled) return const QuizLaunchCancelled();

    final launchPreparation =
        identical(revalidated, prepared) ? prepared : revalidated;
    final result = await _persist(
      request: request,
      prepared: launchPreparation,
      canPersist: () => !operation.cancelled,
    );
    if (result == null) return const QuizLaunchCancelled();

    return switch (result) {
      StartTodaySessionStarted(:final session) => _finishStarted(
          request,
          operation,
          session,
          launchPreparation,
        ),
      StartTodaySessionNoQuestions(:final message) =>
        QuizLaunchNoQuestions(message),
    };
  }

  Future<QuizSession?> _reusablePersistedSession(
    QuizPreparationRequest request,
  ) async {
    final committed = _committed[request];
    final active = await _readActive(request);
    if (active == null) {
      _committed.remove(request);
      return null;
    }

    // The persisted row is authoritative while it remains active. Preparation
    // freshness never reselects or reorders an active session.
    if (committed == null || active.sessionId != committed.session.sessionId) {
      final currentStamp = await _preparer.currentStamp(request);
      _committed[request] = _CommittedLaunch(active, currentStamp);
      return active;
    }
    return committed.session;
  }

  QuizLaunchResult _finishStarted(
    QuizPreparationRequest request,
    _LaunchOperation operation,
    QuizSession session,
    PreparedTodaySession prepared,
  ) {
    _committed[request] = _CommittedLaunch(session, prepared.stamp);
    if (operation.cancelled) {
      return QuizLaunchCancelled(persistedSession: session);
    }
    return QuizLaunchStarted(session);
  }
}

class _CommittedLaunch {
  const _CommittedLaunch(this.session, this.stamp);

  final QuizSession session;
  final QuizPreparationStamp stamp;
}

class _LaunchOperation {
  bool cancelled = false;
  late Future<QuizLaunchResult> future;
}
