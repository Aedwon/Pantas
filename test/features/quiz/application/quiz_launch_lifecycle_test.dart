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

  test('resumeToday is read-only and never persists a replacement', () async {
    final active = _session('session-open');
    var persists = 0;
    final coordinator = QuizLaunchCoordinator(
      preparer: _preparer(),
      readActive: (_) async => active,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        persists += 1;
        return StartTodaySessionStarted(_session('replacement'));
      },
    );

    final resumed = await coordinator.resumeToday(request);

    expect(resumed?.sessionId, 'session-open');
    expect(persists, 0);
  });

  test('completed committed session is not reused by a later Today launch',
      () async {
    QuizSession? active;
    var persists = 0;
    final coordinator = QuizLaunchCoordinator(
      preparer: _preparer(),
      readActive: (_) async => active,
      persist: ({
        required request,
        required prepared,
        required canPersist,
      }) async {
        persists += 1;
        final session = _session('session-$persists');
        active = session;
        return StartTodaySessionStarted(session);
      },
    );

    final first = await coordinator.launchToday(request);
    expect((first as QuizLaunchStarted).session.sessionId, 'session-1');

    // Simulates the durable terminal commit: activeFor no longer returns the
    // completed row. A later Today launch must not resurrect the cache entry.
    active = null;
    final second = await coordinator.launchToday(request);

    expect((second as QuizLaunchStarted).session.sessionId, 'session-2');
    expect(persists, 2);
  });
}

TodayQuizPreparer _preparer() => TodayQuizPreparer(
      readStamp: (_) async => QuizPreparationStamp(
        contentRevision: 'content-1',
        accountLifetimeToken: 'uid:anon',
        examId: 'exam',
        topicId: null,
        scopeToken: 'topic-a',
        topicExclusionToken: '',
        ordering: SessionOrdering.interleavedTail,
        sessionLength: 10,
        newCardCap: 10,
        historyRevision: 'history-1',
        sessionStateRevision: 'session-state-1',
        localDay: DateTime(2026, 9, 9),
        nextDueExpiry: null,
      ),
      buildPlan: (_) async => _plan(),
      now: () => DateTime(2026, 9, 9, 9),
    );

TodaySessionPlan _plan() => const TodaySessionPlan(
      questions: [
        Question(
          id: 'q-1',
          version: 1,
          examIds: ['exam'],
          topicId: 'topic-a',
          language: 'en',
          stem: 'Stem',
          choices: [
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

QuizSession _session(String id) => QuizSession.start(
      sessionId: id,
      examId: 'exam',
      questions: _plan().questions,
      startedAt: DateTime(2026, 9, 9, 9),
      origin: SessionOrigin.todayInterleaved,
      topicId: 'topic-a',
    );
