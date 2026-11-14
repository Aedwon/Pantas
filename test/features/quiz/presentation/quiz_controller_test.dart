import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/app/update_coordinator_provider.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

import '../../../core/platform/app_update/update_coordinator_test.dart'
    show FakeBridge;
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_telemetry.dart';

class _MockStart extends Mock implements StartQuickQuiz {}

class _MockSubmit extends Mock implements SubmitAnswer {}

class _MockInline extends Mock implements StartInlineLessonQuiz {}

class _MockCompletionCoordinator extends Mock
    implements QuizCompletionCoordinator {}

class _FakeQuestion extends Fake implements Question {}

class _FakeQuizSession extends Fake implements QuizSession {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeQuestion());
    registerFallbackValue(_FakeQuizSession());
  });

  const q1 = Question(
    id: 'q1',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 's1',
    choices: [
      Choice(id: 'c1a', label: 'A', text: 'x', isCorrect: true),
      Choice(id: 'c1b', label: 'B', text: 'y', isCorrect: false),
    ],
    explanation: 'e',
  );

  late _MockStart start;
  late _MockSubmit submit;
  late _MockCompletionCoordinator complete;

  Future<ProviderContainer> makeContainer({
    List<Override> extra = const [],
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'test')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        quizCompletionCoordinatorProvider.overrideWithValue(complete),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
        ...extra,
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    return container;
  }

  setUp(() {
    start = _MockStart();
    submit = _MockSubmit();
    complete = _MockCompletionCoordinator();
  });

  test('start() loads questions and transitions to running', () async {
    final session = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: const [q1],
      startedAt: DateTime.utc(2026, 5, 9, 12),
    );
    when(
      () => start(
        examId: any(named: 'examId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).thenAnswer((_) async => session);

    final container = await makeContainer();
    final notifier = container.read(quizControllerProvider.notifier);
    await notifier.start(examId: 'e', count: 1);

    final state = container.read(quizControllerProvider);
    expect(state, isA<QuizRunning>());
    expect((state as QuizRunning).session.questions, hasLength(1));
  });

  test('answer() records and stays, and next() ends the session', () async {
    final session = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: const [q1],
      startedAt: DateTime.utc(2026, 5, 9, 12),
    );
    when(
      () => start(
        examId: any(named: 'examId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).thenAnswer((_) async => session);
    when(
      () => submit(
        question: any(named: 'question'),
        chosenChoiceId: any(named: 'chosenChoiceId'),
        responseMs: any(named: 'responseMs'),
        now: any(named: 'now'),
        origin: any(named: 'origin'),
        sessionId: any(named: 'sessionId'),
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
      ),
    ).thenAnswer(
      (_) async => const AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'c1a',
        correctChoiceId: 'c1a',
        responseMs: 1500,
      ),
    );
    when(
      () => complete.complete(
        session: any(named: 'session'),
        now: any(named: 'now'),
        persisted: any(named: 'persisted'),
      ),
    ).thenAnswer(
      (_) async => Attempt(
        id: 'sess',
        examId: 'e',
        startedAt: DateTime.utc(2026, 5, 9, 12),
        completedAt: DateTime.utc(2026, 5, 9, 12, 1),
        items: const [],
      ),
    );

    final container = await makeContainer();
    final notifier = container.read(quizControllerProvider.notifier);
    await notifier.start(examId: 'e', count: 1);
    notifier.markQuestionReady(sessionId: 'sess', questionIndex: 0);
    await notifier.answer(chosenChoiceId: 'c1a');

    // The answer and the scheduler are written on the tap, and the session
    // holds still so the reveal can be read.
    final answered = container.read(quizControllerProvider);
    expect(answered, isA<QuizRunning>());
    expect((answered as QuizRunning).session.currentOutcome, isNotNull);
    verify(
      () => submit(
        question: any(named: 'question'),
        chosenChoiceId: any(named: 'chosenChoiceId'),
        responseMs: any(named: 'responseMs'),
        now: any(named: 'now'),
        origin: any(named: 'origin'),
        sessionId: any(named: 'sessionId'),
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
      ),
    ).called(1);

    await notifier.next();
    expect(container.read(quizControllerProvider), isA<QuizComplete>());
  });

  group('study-loop events', () {
    final session = QuizSession.start(
      sessionId: 'sess',
      examId: 'e',
      questions: const [q1],
      startedAt: DateTime.utc(2026, 5, 9, 12),
      origin: SessionOrigin.drill,
    );

    void stubFullRun() {
      when(
        () => start(
          examId: any(named: 'examId'),
          count: any(named: 'count'),
          now: any(named: 'now'),
          randomSeed: any(named: 'randomSeed'),
        ),
      ).thenAnswer((_) async => session);
      when(
        () => submit(
          question: any(named: 'question'),
          chosenChoiceId: any(named: 'chosenChoiceId'),
          responseMs: any(named: 'responseMs'),
          now: any(named: 'now'),
          origin: any(named: 'origin'),
          sessionId: any(named: 'sessionId'),
          userId: any(named: 'userId'),
          examId: any(named: 'examId'),
        ),
      ).thenAnswer(
        (_) async => const AnswerOutcome(
          questionId: 'q1',
          questionVersion: 1,
          chosenChoiceId: 'c1a',
          correctChoiceId: 'c1a',
          responseMs: 1500,
        ),
      );
      when(
        () => complete.complete(
          session: any(named: 'session'),
          now: any(named: 'now'),
          persisted: any(named: 'persisted'),
        ),
      ).thenAnswer(
        (_) async => Attempt(
          id: 'sess',
          examId: 'e',
          startedAt: DateTime.utc(2026, 5, 9, 12),
          completedAt: DateTime.utc(2026, 5, 9, 12, 1),
          items: const [],
        ),
      );
    }

    Future<void> runSession(ProviderContainer container) async {
      final notifier = container.read(quizControllerProvider.notifier);
      await notifier.start(examId: 'e', count: 1);
      notifier.markQuestionReady(sessionId: 'sess', questionIndex: 0);
      await notifier.answer(chosenChoiceId: 'c1a');
      await notifier.next();
    }

    for (final destination in ['/lesson/other', '/quiz/inline/other']) {
      test('late quiz completion cannot reload $destination', () async {
        stubFullRun();
        final pending = Completer<Attempt>();
        final inline = _MockInline();
        when(
          () => inline(
            userId: any(named: 'userId'),
            examId: any(named: 'examId'),
            lessonId: any(named: 'lessonId'),
            now: any(named: 'now'),
          ),
        ).thenAnswer((_) async => StartInlineLessonQuizStarted(session));
        when(
          () => complete.complete(
            session: any(named: 'session'),
            now: any(named: 'now'),
            persisted: any(named: 'persisted'),
          ),
        ).thenAnswer((_) => pending.future);
        final bridge = FakeBridge();
        final updates = UpdateCoordinator(
          bridge: bridge,
          waitForWrites: () async {},
          onFailure: (error, stack) => fail('$error'),
        )..routeChanged('/quiz/inline/lesson');
        addTearDown(updates.dispose);
        final container = await makeContainer(
          extra: [
            updateCoordinatorProvider.overrideWithValue(updates),
            startInlineLessonQuizProvider.overrideWithValue(inline),
          ],
        );
        final notifier = container.read(quizControllerProvider.notifier);
        await notifier.start(examId: 'e', count: 1);
        notifier.markQuestionReady(sessionId: 'sess', questionIndex: 0);
        await notifier.answer(chosenChoiceId: 'c1a');
        final finishing = notifier.next();
        updates.routeChanged(destination);
        if (destination.startsWith('/quiz/')) {
          await notifier.startInline(examId: 'e', lessonId: 'other');
        }
        pending.complete(
          Attempt(
            id: 'sess',
            examId: 'e',
            startedAt: DateTime.utc(2026, 5, 9, 12),
            completedAt: DateTime.utc(2026, 5, 9, 12, 1),
            items: const [],
          ),
        );
        await finishing;
        await updates.check();
        expect(bridge.applies, 0);
        expect(container.read(quizControllerProvider), isA<QuizRunning>());
      });
    }

    test('inline QuizComplete applies a pending update without a route change',
        () async {
      stubFullRun();
      final inline = _MockInline();
      when(
        () => inline(
          userId: any(named: 'userId'),
          examId: any(named: 'examId'),
          lessonId: any(named: 'lessonId'),
          now: any(named: 'now'),
        ),
      ).thenAnswer(
        (_) async => StartInlineLessonQuizStarted(
          QuizSession.start(
            sessionId: 'sess',
            examId: 'e',
            questions: const [q1],
            startedAt: DateTime.utc(2026, 5, 9, 12),
            origin: SessionOrigin.inline,
          ),
        ),
      );
      final bridge = FakeBridge();
      final updates = UpdateCoordinator(
        bridge: bridge,
        waitForWrites: () async {},
        onFailure: (error, stack) => fail('$error'),
      )..routeChanged('/quiz/inline/lesson');
      addTearDown(updates.dispose);
      final container = await makeContainer(
        extra: [
          updateCoordinatorProvider.overrideWithValue(updates),
          startInlineLessonQuizProvider.overrideWithValue(inline),
        ],
      );
      final notifier = container.read(quizControllerProvider.notifier);
      await notifier.startInline(examId: 'e', lessonId: 'lesson');
      await updates.check();
      expect(bridge.applies, 0, reason: 'An open question is unsafe');
      notifier.markQuestionReady(sessionId: 'sess', questionIndex: 0);
      await notifier.answer(chosenChoiceId: 'c1a');
      await updates.check();
      expect(bridge.applies, 0, reason: 'The answer reveal is still unsafe');
      await notifier.next();
      expect(container.read(quizControllerProvider), isA<QuizComplete>());
      await Future<void>.delayed(Duration.zero);
      expect(bridge.applies, 1, reason: 'Completion must check immediately');

      // Start again on the same URL. A later version must wait for completion.
      bridge.version = 'later';
      await notifier.startInline(examId: 'e', lessonId: 'lesson');
      await updates.check();
      expect(bridge.applies, 1, reason: 'A new session clears completion');
    });

    test('a session logs one start and one finish, with exam, kind and count',
        () async {
      stubFullRun();
      final sink = RecordingTelemetry();
      final container = await makeContainer(
        extra: [
          telemetrySinkProvider.overrideWithValue(sink),
          effectiveTelemetryConsentProvider.overrideWithValue(true),
        ],
      );

      await runSession(container);
      expect(container.read(quizControllerProvider), isA<QuizComplete>());

      expect(
        sink.events,
        [TelemetryEvent.studySessionStart, TelemetryEvent.studySessionFinish],
      );
      for (final entry in sink.logged) {
        expect(entry.$2, {'exam_id': 'e', 'kind': 'drill', 'count': 1});
      }
    });

    test('answering inside a running session logs nothing more', () async {
      stubFullRun();
      final sink = RecordingTelemetry();
      final container = await makeContainer(
        extra: [
          telemetrySinkProvider.overrideWithValue(sink),
          effectiveTelemetryConsentProvider.overrideWithValue(true),
        ],
      );
      final notifier = container.read(quizControllerProvider.notifier);
      await notifier.start(examId: 'e', count: 1);
      notifier.markQuestionReady(sessionId: 'sess', questionIndex: 0);
      await notifier.answer(chosenChoiceId: 'c1a');

      expect(sink.events, [TelemetryEvent.studySessionStart]);
    });

    test('nothing is sent while usage sharing is off', () async {
      stubFullRun();
      final sink = RecordingTelemetry();
      final container = await makeContainer(
        extra: [
          telemetrySinkProvider.overrideWithValue(sink),
          effectiveTelemetryConsentProvider.overrideWithValue(false),
        ],
      );

      await runSession(container);

      expect(sink.logged, isEmpty);
    });
  });
}
