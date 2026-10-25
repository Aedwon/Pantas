import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_session_end_page.dart';

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

  testWidgets('the flag sits in the floating bar before Check', (tester) async {
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

    final bar = find.byType(FloatingBar);
    final flag =
        find.descendant(of: bar, matching: find.byTooltip('Flag question'));
    expect(flag, findsOneWidget);
    expect(
      find.descendant(of: flag, matching: find.byIcon(PantasIcons.flag)),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(flag).dx,
      lessThan(tester.getTopLeft(find.text('Check')).dx),
    );
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

  testWidgets('the counter names the current question and is at least 44dp',
      (tester) async {
    final semantics = tester.ensureSemantics();
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

    final counter = find.semantics.byLabel(
      'Question 4 of 10. Open question navigator',
    );
    expect(counter, findsOne);
    expect(
      counter,
      matchesSemantics(
        label: 'Question 4 of 10. Open question navigator',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(counter.evaluate().single.rect.width, greaterThanOrEqualTo(44));
    expect(counter.evaluate().single.rect.height, greaterThanOrEqualTo(44));
    semantics.dispose();
  });

  testWidgets('the flag action names and exposes its set state',
      (tester) async {
    final semantics = tester.ensureSemantics();
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
        flaggedIdsProvider.overrideWith((_) async => {'q_4'}),
        quizControllerProvider.overrideWith(
          (ref) => _FakeQuizController(
            ref,
            QuizRunning(session: session, questionShownAt: DateTime.now()),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    final flag = find.semantics.byLabel('Remove flag from question 4');
    expect(flag, findsOne);
    expect(
      flag,
      matchesSemantics(
        label: 'Remove flag from question 4',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
      ),
    );
    expect(flag.evaluate().single.rect.width, greaterThanOrEqualTo(44));
    expect(flag.evaluate().single.rect.height, greaterThanOrEqualTo(44));
    semantics.dispose();
  });

  testWidgets('the counter opens Questions with the actual answered total',
      (tester) async {
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
    expect(find.text('Questions'), findsOneWidget);
    expect(find.text('0 of 10 answered'), findsOneWidget);
  });
  testWidgets('actual completion uses the rebuilt live session end',
      (tester) async {
    final session = QuizSession(
      sessionId: 'done',
      examId: 'cse_prof',
      questions: [sampleQuestions.first],
      currentIndex: 0,
      outcomes: [
        const AnswerOutcome(
          questionId: 'q_1',
          questionVersion: 1,
          chosenChoiceId: 'c_a',
          correctChoiceId: 'c_a',
          responseMs: 1,
        ),
      ],
      startedAt: DateTime.utc(2026),
    );
    final attempt = Attempt(
      id: 'done',
      examId: 'cse_prof',
      startedAt: session.startedAt,
      completedAt: DateTime.utc(2026, 1, 1, 0, 1),
      items: const [
        AttemptItem(
          questionId: 'q_1',
          questionVersion: 1,
          chosenChoiceId: 'c_a',
          correctChoiceId: 'c_a',
          responseMs: 1,
        ),
      ],
    );
    await tester.pumpAppWithProviders(
      const QuizPage(examId: 'cse_prof', mode: QuizPageMode.practice),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        quizControllerProvider.overrideWith(
          (ref) => _FakeQuizController(
            ref,
            QuizComplete(attempt: attempt, session: session),
          ),
        ),
      ],
    );
    expect(find.byType(QuizSessionEndPage), findsOneWidget);
  });
}

class _FakeQuizController extends QuizController {
  _FakeQuizController(super.ref, this._initialState);

  final QuizControllerState _initialState;

  @override
  QuizControllerState get state => _initialState;
}
