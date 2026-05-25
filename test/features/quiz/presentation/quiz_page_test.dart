import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/complete_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
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
    expect(find.text('Question 1 of 1'), findsOneWidget);
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

    expect(find.text('Quit session?'), findsOneWidget);
    expect(find.text('Your progress is saved.'), findsOneWidget);
  });
}
