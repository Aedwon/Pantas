import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

class _MockStart extends Mock implements StartQuickQuiz {}

class _MockSubmit extends Mock implements SubmitAnswer {}

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

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        startQuickQuizProvider.overrideWithValue(start),
        submitAnswerProvider.overrideWithValue(submit),
        quizCompletionCoordinatorProvider.overrideWithValue(complete),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 5, 9, 12)),
      ],
    );
    addTearDown(container.dispose);
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

    final container = makeContainer();
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

    final container = makeContainer();
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
      ),
    ).called(1);

    await notifier.next();
    expect(container.read(quizControllerProvider), isA<QuizComplete>());
  });
}
