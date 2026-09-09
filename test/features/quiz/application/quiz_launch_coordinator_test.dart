import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/quiz_preparation_stamp.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_today_session.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';

void main() {
  const request = QuizPreparationRequest(userId: 'local', examId: 'exam');

  test('rapid Today launches coalesce into one persistence call', () async {
    final gate = Completer<void>();
    var persists = 0;
    final coordinator = QuizLaunchCoordinator(
      preparer: _preparer(),
      readActive: (_) async => null,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        persists += 1;
        await gate.future;
        return StartTodaySessionStarted(_session(prepared));
      },
    );

    final first = coordinator.launchToday(request);
    final second = coordinator.launchToday(request);
    await Future<void>.delayed(Duration.zero);
    expect(persists, 1);

    gate.complete();
    final results = await Future.wait([first, second]);
    expect(results, everyElement(isA<QuizLaunchStarted>()));
    expect(persists, 1);
  });

  test('launch failure is reported once without a detached cleanup error',
      () async {
    final coordinator = QuizLaunchCoordinator(
      preparer: _preparer(),
      readActive: (_) async => null,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        throw StateError('persist failed');
      },
    );

    await expectLater(
      coordinator.launchToday(request),
      throwsA(isA<StateError>()),
    );
    await Future<void>.delayed(Duration.zero);
  });

  test('a stale supplied preparation is recomputed before persistence',
      () async {
    var revision = 'history-1';
    var builds = 0;
    final preparer = _preparer(
      readStamp: () => _stamp(historyRevision: revision),
      buildPlan: () {
        builds += 1;
        return _plan('q-$builds');
      },
    );
    final stale = await preparer.prepare(request);
    revision = 'history-2';
    PreparedTodaySession? persisted;
    final coordinator = QuizLaunchCoordinator(
      preparer: preparer,
      readActive: (_) async => null,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        persisted = prepared;
        return StartTodaySessionStarted(_session(prepared));
      },
    );

    final result = await coordinator.launchToday(request, prepared: stale);

    expect(result, isA<QuizLaunchStarted>());
    expect(persisted, isNotNull);
    expect(identical(persisted, stale), isFalse);
    expect(persisted!.orderedQuestionIds, const ['q-2']);
  });

  test('cancellation before persistence prevents a late create', () async {
    final planGate = Completer<TodaySessionPlan>();
    var persistCalled = false;
    final preparer = TodayQuizPreparer(
      readStamp: (_) async => _stamp(historyRevision: 'history-1'),
      buildPlan: (_) => planGate.future,
      now: () => DateTime(2026, 9, 9, 9),
    );
    final coordinator = QuizLaunchCoordinator(
      preparer: preparer,
      readActive: (_) async => null,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        persistCalled = true;
        return StartTodaySessionStarted(_session(prepared));
      },
    );

    final launch = coordinator.launchToday(request);
    await Future<void>.delayed(Duration.zero);
    coordinator.cancel(request);
    planGate.complete(_plan('q-1'));

    expect(await launch, isA<QuizLaunchCancelled>());
    expect(persistCalled, isFalse);
  });

  test('cancellation while persistence waits can prevent the commit', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    var commits = 0;
    final coordinator = QuizLaunchCoordinator(
      preparer: _preparer(),
      readActive: (_) async => null,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        entered.complete();
        await release.future;
        if (!canPersist()) return null;
        commits += 1;
        return StartTodaySessionStarted(_session(prepared));
      },
    );

    final launch = coordinator.launchToday(request);
    await entered.future;
    coordinator.cancel(request);
    release.complete();

    expect(await launch, isA<QuizLaunchCancelled>());
    expect(commits, 0);
  });

  test(
      'post-commit cancellation keeps one resumable session and later launch '
      'reuses it', () async {
    final committed = Completer<void>();
    final release = Completer<void>();
    var persists = 0;
    QuizSession? active;
    final coordinator = QuizLaunchCoordinator(
      preparer: _preparer(),
      readActive: (_) async => active,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        persists += 1;
        final session = _session(prepared);
        active = session;
        committed.complete();
        await release.future;
        return StartTodaySessionStarted(session);
      },
    );

    final launch = coordinator.launchToday(request);
    await committed.future;
    coordinator.cancel(request);
    release.complete();

    final cancelled = await launch;
    expect(cancelled, isA<QuizLaunchCancelled>());
    expect(
      (cancelled as QuizLaunchCancelled).persistedSession?.sessionId,
      'session-1',
    );

    final resumed = await coordinator.launchToday(request);
    expect(resumed, isA<QuizLaunchStarted>());
    expect((resumed as QuizLaunchStarted).session.sessionId, 'session-1');
    expect(persists, 1);
  });

  test(
      'freshness change after terminal completion launches a new Today session',
      () async {
    var revision = 'history-1';
    var persists = 0;
    QuizSession? active;
    final coordinator = QuizLaunchCoordinator(
      preparer: _preparer(
        readStamp: () => _stamp(historyRevision: revision),
      ),
      readActive: (_) async => active,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        persists += 1;
        active = _session(prepared, sessionId: 'session-$persists');
        return StartTodaySessionStarted(active!);
      },
    );

    final first = await coordinator.launchToday(request);
    expect(first, isA<QuizLaunchStarted>());
    expect((first as QuizLaunchStarted).session.sessionId, 'session-1');

    active = null;
    revision = 'history-2';
    final second = await coordinator.launchToday(request);

    expect(second, isA<QuizLaunchStarted>());
    expect((second as QuizLaunchStarted).session.sessionId, 'session-2');
    expect(persists, 2);
  });

  test('freshness change never replaces an authoritative active session',
      () async {
    var revision = 'history-1';
    var persists = 0;
    QuizSession? active;
    final coordinator = QuizLaunchCoordinator(
      preparer: _preparer(
        readStamp: () => _stamp(historyRevision: revision),
      ),
      readActive: (_) async => active,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        persists += 1;
        active = _session(prepared, sessionId: 'session-$persists');
        return StartTodaySessionStarted(active!);
      },
    );

    final first = await coordinator.launchToday(request);
    expect((first as QuizLaunchStarted).session.sessionId, 'session-1');

    revision = 'history-2';
    final second = await coordinator.launchToday(request);

    expect((second as QuizLaunchStarted).session.sessionId, 'session-1');
    expect(persists, 1);
  });
}

TodayQuizPreparer _preparer({
  QuizPreparationStamp Function()? readStamp,
  TodaySessionPlan Function()? buildPlan,
}) {
  return TodayQuizPreparer(
    readStamp: (_) async =>
        readStamp?.call() ?? _stamp(historyRevision: 'history-1'),
    buildPlan: (_) async => buildPlan?.call() ?? _plan('q-1'),
    now: () => DateTime(2026, 9, 9, 9),
  );
}

QuizPreparationStamp _stamp({required String historyRevision}) =>
    QuizPreparationStamp(
      contentRevision: 'content-1',
      accountLifetimeToken: 'uid:anon',
      examId: 'exam',
      topicId: null,
      scopeToken: 'topic-a',
      topicExclusionToken: '',
      ordering: SessionOrdering.interleavedTail,
      sessionLength: 10,
      newCardCap: 10,
      historyRevision: historyRevision,
      sessionStateRevision: 'session-1',
      localDay: DateTime(2026, 9, 9),
      nextDueExpiry: null,
    );

TodaySessionPlan _plan(String id) => TodaySessionPlan(
      questions: [
        Question(
          id: id,
          version: 1,
          examIds: const ['exam'],
          topicId: 'topic-a',
          language: 'en',
          stem: 'Stem',
          choices: const [
            Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
            Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
          ],
          explanation: 'Because.',
        ),
      ],
      dueCount: 1,
      weaknessCount: 0,
      freshCount: 0,
      topicId: 'topic-a',
      topicName: 'Topic A',
    );

QuizSession _session(
  PreparedTodaySession prepared, {
  String sessionId = 'session-1',
}) =>
    QuizSession.start(
      sessionId: sessionId,
      examId: 'exam',
      questions: prepared.plan.questions,
      startedAt: DateTime(2026, 9, 9, 9),
      origin: SessionOrigin.todayInterleaved,
      topicId: prepared.plan.topicId,
    );
