import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/pennant_mark.dart';
import 'package:cse_cet_reviewer/core/ui/components/progress_rule.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() {
    db.close();
  });

  final sampleQuestions = List.generate(
    10,
    (i) => Question(
      id: 'q_${i + 1}',
      version: 1,
      examIds: const ['cse_prof'],
      topicId: 'topic_1',
      language: 'en',
      stem: 'Question ${i + 1}',
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'Option A', isCorrect: true),
        Choice(id: 'c_b', label: 'B', text: 'Option B', isCorrect: false),
      ],
      explanation: 'Explanation ${i + 1}',
    ),
  );

  testWidgets('the bar counts the position, not the score', (tester) async {
    final session = QuizSession(
      sessionId: 's_1',
      examId: 'cse_prof',
      questions: sampleQuestions,
      currentIndex: 3,
      outcomes: const [],
      startedAt: DateTime.now(),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'cse_prof', mode: QuizPageMode.practice),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        quizControllerProvider.overrideWith(
          (ref) => _FakeQuizController(
            ref,
            QuizRunning(session: session, questionShownAt: DateTime.now()),
          ),
        ),
      ],
    );

    expect(find.text('4 of 10'), findsOneWidget);
  });

  testWidgets('the flag sits outermost', (tester) async {
    final session = QuizSession(
      sessionId: 's_1',
      examId: 'cse_prof',
      questions: sampleQuestions,
      currentIndex: 3,
      outcomes: const [],
      startedAt: DateTime.now(),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'cse_prof', mode: QuizPageMode.practice),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        quizControllerProvider.overrideWith(
          (ref) => _FakeQuizController(
            ref,
            QuizRunning(session: session, questionShownAt: DateTime.now()),
          ),
        ),
      ],
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final actions = appBar.actions!;
    expect(actions.last, isA<Consumer>());
  });

  testWidgets('the counter opens the grid', (tester) async {
    final session = QuizSession(
      sessionId: 's_1',
      examId: 'cse_prof',
      questions: sampleQuestions,
      currentIndex: 3,
      outcomes: const [],
      startedAt: DateTime.now(),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'cse_prof', mode: QuizPageMode.practice),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        quizControllerProvider.overrideWith(
          (ref) => _FakeQuizController(
            ref,
            QuizRunning(session: session, questionShownAt: DateTime.now()),
          ),
        ),
      ],
    );

    await tester.tap(find.text('4 of 10'));
    await tester.pumpAndSettle();
  });

  testWidgets('the rail is one continuous fill', (tester) async {
    final session = QuizSession(
      sessionId: 's_1',
      examId: 'cse_prof',
      questions: sampleQuestions,
      currentIndex: 3,
      outcomes: const [],
      startedAt: DateTime.now(),
    );

    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'cse_prof', mode: QuizPageMode.practice),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        quizControllerProvider.overrideWith(
          (ref) => _FakeQuizController(
            ref,
            QuizRunning(session: session, questionShownAt: DateTime.now()),
          ),
        ),
      ],
    );

    expect(find.byType(ProgressRule), findsOneWidget);
  });
}

class _FakeQuizController extends QuizController {
  _FakeQuizController(Ref ref, this._initialState) : super(ref);

  final QuizControllerState _initialState;

  @override
  QuizControllerState get state => _initialState;
}
