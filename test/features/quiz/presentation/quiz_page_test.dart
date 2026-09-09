import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/pump_app.dart';

class _MockStart extends Mock implements StartQuickQuiz {}

class _MockSubmit extends Mock implements SubmitAnswer {}

class _MockLaunchCoordinator extends Mock implements QuizLaunchCoordinator {}

void main() {
  late _MockStart start;
  late _MockSubmit submit;
  late _MockLaunchCoordinator launchCoordinator;

  const q1 = Question(
    id: 'q1',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 'Stem One',
    choices: [
      Choice(id: 'c1a', label: 'A', text: 'AlphaText', isCorrect: true),
      Choice(id: 'c1b', label: 'B', text: 'BetaText', isCorrect: false),
    ],
    explanation: 'e',
  );
  const q2 = Question(
    id: 'q2',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 'Stem Two',
    choices: [
      Choice(id: 'c2a', label: 'A', text: 'GammaText', isCorrect: false),
      Choice(id: 'c2b', label: 'B', text: 'DeltaText', isCorrect: true),
    ],
    explanation: 'e',
  );

  const passageQuestion = Question(
    id: 'qp',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 'Passage stem',
    passageId: 'passage-1',
    choices: [
      Choice(
        id: 'pa',
        label: 'A',
        text: 'Passage answer A',
        isCorrect: true,
      ),
      Choice(id: 'pb', label: 'B', text: 'Passage answer B', isCorrect: false),
    ],
    explanation: 'e',
  );

  setUpAll(() {
    registerFallbackValue(q1);
    registerFallbackValue(
      const QuizPreparationRequest(
        userId: quizLocalUserId,
        examId: 'e',
        topicId: 't',
      ),
    );
    registerFallbackValue(
      QuizSession.start(
        sessionId: 'fallback',
        examId: 'e',
        questions: const [q1],
        startedAt: DateTime.utc(2026, 5, 9, 12),
      ),
    );
  });

  setUp(() {
    start = _MockStart();
    submit = _MockSubmit();
    launchCoordinator = _MockLaunchCoordinator();
  });

  testWidgets('renders the first question once start completes',
      (tester) async {
    when(
      () => start(
        examId: any(named: 'examId'),
        topicId: any(named: 'topicId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).thenAnswer(
      (_) async => QuizSession.start(
        sessionId: 'sess',
        examId: 'e',
        questions: const [q1],
        startedAt: DateTime.utc(2026, 5, 9, 12),
      ),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'e'),
      overrides: [
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Stem One'), findsOneWidget);
    expect(find.text('AlphaText'), findsOneWidget);
    expect(find.text('1 of 1'), findsOneWidget);
  });

  testWidgets(
      'required passage does not expose answer actions while unresolved',
      (tester) async {
    when(
      () => start(
        examId: any(named: 'examId'),
        topicId: any(named: 'topicId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).thenAnswer(
      (_) async => QuizSession.start(
        sessionId: 'passage-session',
        examId: 'e',
        questions: const [passageQuestion],
        startedAt: DateTime.utc(2026, 5, 9, 12),
      ),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'e'),
      overrides: [
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Passage answer A'), findsNothing);
    expect(find.text('Passage answer B'), findsNothing);
  });

  testWidgets('passes topicId to quick quiz start when provided',
      (tester) async {
    when(
      () => start(
        examId: any(named: 'examId'),
        topicId: any(named: 'topicId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).thenAnswer(
      (_) async => QuizSession.start(
        sessionId: 'sess',
        examId: 'e',
        questions: const [q1],
        startedAt: DateTime.utc(2026, 5, 9, 12),
      ),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'e', topicId: 't'),
      overrides: [
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    await tester.pumpAndSettle();

    verify(
      () => start(
        examId: 'e',
        topicId: 't',
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).called(1);
  });

  testWidgets('quit button shows confirmation while a session is running',
      (tester) async {
    when(
      () => start(
        examId: any(named: 'examId'),
        topicId: any(named: 'topicId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).thenAnswer(
      (_) async => QuizSession.start(
        sessionId: 'sess',
        examId: 'e',
        questions: const [q1],
        startedAt: DateTime.utc(2026, 5, 9, 12),
      ),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'e'),
      overrides: [
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quit session'));
    await tester.pumpAndSettle();

    // Leaving no longer quits: the session stays open so the tab can offer
    // to resume it, and the copy says so.
    expect(find.text('Leave this session?'), findsOneWidget);
    expect(find.textContaining('already saved'), findsOneWidget);
  });

  testWidgets('submitting an answer reveals the answer in place',
      (tester) async {
    when(
      () => start(
        examId: any(named: 'examId'),
        topicId: any(named: 'topicId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).thenAnswer(
      (_) async => QuizSession.start(
        sessionId: 'sess',
        examId: 'e',
        questions: const [q1, q2],
        startedAt: DateTime.utc(2026, 5, 9, 12),
      ),
    );
    when(
      () => submit(
        question: any(named: 'question'),
        chosenChoiceId: any(named: 'chosenChoiceId'),
        responseMs: any(named: 'responseMs'),
        now: any(named: 'now'),
        sessionId: any(named: 'sessionId'),
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
        origin: any(named: 'origin'),
      ),
    ).thenAnswer(
      (_) async => const AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'c1a',
        correctChoiceId: 'c1a',
        responseMs: 1000,
        nextReviewIntervalDays: 4,
      ),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'e'),
      overrides: [
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('AlphaText'));
    await tester.pumpAndSettle();

    // The reveal says all of this and stays on screen. A toast said it
    // once, over the top, on every single answer.
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('back in 4 days'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Next'), findsOneWidget);
  });
  testWidgets('Retry preserves Today mode and topic scope', (tester) async {
    when(
      () => launchCoordinator.launchToday(
        any(),
        prepared: any(named: 'prepared'),
      ),
    ).thenAnswer((_) async => const QuizLaunchNoQuestions('No questions'));

    await tester.pumpAppWithProviders(
      const QuizPage(
        examId: 'e',
        topicId: 't',
        mode: QuizPageMode.today,
      ),
      overrides: [
        quizLaunchCoordinatorProvider.overrideWithValue(launchCoordinator),
        startQuickQuizProvider.overrideWithValue(start),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    final requests = verify(
      () => launchCoordinator.launchToday(
        captureAny(),
        prepared: any(named: 'prepared'),
      ),
    ).captured.cast<QuizPreparationRequest>();
    expect(requests, hasLength(2));
    expect(requests.map((request) => request.examId), everyElement('e'));
    expect(requests.map((request) => request.topicId), everyElement('t'));
    verifyNever(
      () => start(
        examId: any(named: 'examId'),
        topicId: any(named: 'topicId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    );
  });
}
