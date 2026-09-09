import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

class _MockLaunchCoordinator extends Mock implements QuizLaunchCoordinator {}

class _MockSubmitAnswer extends Mock implements SubmitAnswer {}

void main() {
  test('startToday launches through the single coordinator owner', () async {
    final coordinator = _MockLaunchCoordinator();
    final session = QuizSession.start(
      sessionId: 'today-1',
      examId: 'exam',
      questions: const [_question],
      startedAt: DateTime.utc(2026, 9, 9, 8),
    );
    const request = QuizPreparationRequest(userId: 'local', examId: 'exam');
    when(() => coordinator.launchToday(request)).thenAnswer(
      (_) async => QuizLaunchStarted(session),
    );
    final container = ProviderContainer(
      overrides: [
        quizLaunchCoordinatorProvider.overrideWithValue(coordinator),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 9, 9, 8)),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(quizControllerProvider.notifier)
        .startToday(examId: 'exam');

    final state = container.read(quizControllerProvider);
    expect(state, isA<QuizRunning>());
    expect((state as QuizRunning).session.sessionId, 'today-1');
    expect(state.persisted, isTrue);
    verify(() => coordinator.launchToday(request)).called(1);
  });

  test('Today does not start response timing before UI readiness', () async {
    final coordinator = _MockLaunchCoordinator();
    final session = QuizSession.start(
      sessionId: 'today-ready',
      examId: 'exam',
      questions: const [_question],
      startedAt: DateTime.utc(2026, 9, 9, 8),
    );
    const request = QuizPreparationRequest(userId: 'local', examId: 'exam');
    when(() => coordinator.launchToday(request)).thenAnswer(
      (_) async => QuizLaunchStarted(session),
    );
    final container = ProviderContainer(
      overrides: [
        quizLaunchCoordinatorProvider.overrideWithValue(coordinator),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 9, 9, 8, 5)),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(quizControllerProvider.notifier)
        .startToday(examId: 'exam');

    final state = container.read(quizControllerProvider) as QuizRunning;
    expect(state.questionShownAt, isNull);
  });

  test('readiness is keyed, idempotent, and resets for Next', () async {
    final coordinator = _MockLaunchCoordinator();
    final submit = _MockSubmitAnswer();
    final session = QuizSession.start(
      sessionId: 'today-next',
      examId: 'exam',
      questions: const [_question, _questionTwo],
      startedAt: DateTime.utc(2026, 9, 9, 8),
    );
    const request = QuizPreparationRequest(userId: 'local', examId: 'exam');
    when(() => coordinator.launchToday(request)).thenAnswer(
      (_) async => QuizLaunchStarted(session),
    );
    var now = DateTime.utc(2026, 9, 9, 8, 5);
    final container = ProviderContainer(
      overrides: [
        quizLaunchCoordinatorProvider.overrideWithValue(coordinator),
        submitAnswerProvider.overrideWithValue(submit),
        nowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(quizControllerProvider.notifier);

    await controller.startToday(examId: 'exam');
    controller.markQuestionReady(
      sessionId: 'today-next',
      questionIndex: 0,
    );
    expect(
      (container.read(quizControllerProvider) as QuizRunning).questionShownAt,
      now,
    );

    final firstReadyAt = now;
    now = DateTime.utc(2026, 9, 9, 8, 5, 30);
    controller.markQuestionReady(
      sessionId: 'today-next',
      questionIndex: 0,
    );
    expect(
      (container.read(quizControllerProvider) as QuizRunning).questionShownAt,
      firstReadyAt,
    );

    now = DateTime.utc(2026, 9, 9, 8, 6);
    when(
      () => submit(
        question: _question,
        chosenChoiceId: 'a',
        responseMs: 60000,
        now: now,
        sessionId: 'today-next',
        userId: quizLocalUserId,
        examId: 'exam',
        origin: 'today_topic',
      ),
    ).thenAnswer(
      (_) async => const AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'a',
        correctChoiceId: 'a',
        responseMs: 60000,
      ),
    );
    await controller.answer(chosenChoiceId: 'a');
    await controller.next();

    var running = container.read(quizControllerProvider) as QuizRunning;
    expect(running.session.currentIndex, 1);
    expect(running.questionShownAt, isNull);

    controller.markQuestionReady(
      sessionId: 'today-next',
      questionIndex: 0,
    );
    expect(
      (container.read(quizControllerProvider) as QuizRunning).questionShownAt,
      isNull,
    );

    now = DateTime.utc(2026, 9, 9, 8, 7);
    controller.markQuestionReady(
      sessionId: 'today-next',
      questionIndex: 1,
    );
    running = container.read(quizControllerProvider) as QuizRunning;
    expect(running.questionShownAt, now);
  });
}

const _question = Question(
  id: 'q1',
  version: 1,
  examIds: ['exam'],
  topicId: 'topic',
  language: 'en',
  stem: 'Stem',
  choices: [
    Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
    Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
  ],
  explanation: 'Because.',
);

const _questionTwo = Question(
  id: 'q2',
  version: 1,
  examIds: ['exam'],
  topicId: 'topic',
  language: 'en',
  stem: 'Second stem',
  choices: [
    Choice(id: 'c', label: 'A', text: 'C', isCorrect: true),
    Choice(id: 'd', label: 'B', text: 'D', isCorrect: false),
  ],
  explanation: 'Because.',
);
