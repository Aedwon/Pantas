import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/complete_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockStart extends Mock implements StartQuickQuiz {}

class _MockSubmit extends Mock implements SubmitAnswer {}

class _MockComplete extends Mock implements CompleteQuiz {}

void main() {
  late _MockStart start;
  late _MockSubmit submit;
  late _MockComplete complete;

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

  setUpAll(() {
    registerFallbackValue(q1);
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
    complete = _MockComplete();
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
        completeQuizProvider.overrideWithValue(complete),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Stem One'), findsOneWidget);
    expect(find.text('AlphaText'), findsOneWidget);
    expect(find.text('1 of 1'), findsOneWidget);
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
        completeQuizProvider.overrideWithValue(complete),
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
        completeQuizProvider.overrideWithValue(complete),
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
        completeQuizProvider.overrideWithValue(complete),
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
}
