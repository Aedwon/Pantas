import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _Start extends Mock implements StartQuickQuiz {}

class _Submit extends Mock implements SubmitAnswer {}

const question = Question(
  id: 'q',
  version: 1,
  examIds: ['e'],
  topicId: 't',
  language: 'en',
  stem: 'Which answer?',
  explanation: 'The first answer is correct.',
  choices: [
    Choice(id: 'a', label: 'A', text: 'First', isCorrect: true),
    Choice(id: 'b', label: 'B', text: 'Second', isCorrect: false),
  ],
);
const outcome = AnswerOutcome(
  questionId: 'q',
  questionVersion: 1,
  chosenChoiceId: 'b',
  correctChoiceId: 'a',
  responseMs: 2000,
);

void main() {
  setUpAll(() => registerFallbackValue(question));
  late _Start start;
  late _Submit submit;
  late ProviderContainer container;
  late QuizController controller;
  var disposed = false;
  var now = DateTime.utc(2026, 10, 15);

  setUp(() async {
    disposed = false;
    now = DateTime.utc(2026, 10, 15);
    start = _Start();
    submit = _Submit();
    when(
      () => start(
        examId: any(named: 'examId'),
        count: any(named: 'count'),
        now: any(named: 'now'),
        randomSeed: any(named: 'randomSeed'),
      ),
    ).thenAnswer(
      (_) async => QuizSession.start(
        sessionId: 's',
        examId: 'e',
        questions: const [question],
        startedAt: now,
      ),
    );
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
    ).thenAnswer((_) async => outcome);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    container = ProviderContainer(
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
        nowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(() {
      if (!disposed) container.dispose();
    });
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    controller = container.read(quizControllerProvider.notifier);
    await controller.start(examId: 'e');
    controller.markQuestionReady(sessionId: 's', questionIndex: 0);
  });

  QuizRunning running() =>
      container.read(quizControllerProvider) as QuizRunning;

  test('picks remain changeable and write only when checked', () async {
    controller
      ..pick(chosenChoiceId: 'a')
      ..pick(chosenChoiceId: 'b');
    expect(running().selectedChoiceId, 'b');
    expect(running().session.outcomes, isEmpty);
    verifyNever(
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
    );
    now = now.add(const Duration(seconds: 2));
    await controller.check();
    expect(running().session.currentOutcome!.chosenChoiceId, 'b');
    expect(running().session.currentIndex, 0);
    verify(
      () => submit(
        question: question,
        chosenChoiceId: 'b',
        responseMs: 2000,
        now: now,
        origin: running().session.origin.storageValue,
        sessionId: any(named: 'sessionId'),
        userId: any(named: 'userId'),
        examId: any(named: 'examId'),
      ),
    ).called(1);
  });

  test('Check without a valid ready pick never writes', () async {
    controller.pick(chosenChoiceId: 'missing');
    await controller.check();
    expect(running().selectedChoiceId, isNull);
    expect(running().session.outcomes, isEmpty);
    verifyZeroInteractions(submit);
  });

  test('pending Check prevents another submission and changing the pick',
      () async {
    final pending = Completer<AnswerOutcome>();
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
    ).thenAnswer((_) => pending.future);
    controller.pick(chosenChoiceId: 'b');
    final checked = controller.check();
    expect(running().checking, isTrue);
    controller.pick(chosenChoiceId: 'a');
    await controller.check();
    expect(running().selectedChoiceId, 'b');
    pending.complete(outcome);
    await checked;
    expect(running().checking, isFalse);
    expect(running().session.outcomes, hasLength(1));
    await controller.check();
    controller.pick(chosenChoiceId: 'a');
    expect(running().session.outcomes, hasLength(1));
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
  });

  test('failed Check keeps the pick and permits retry', () async {
    var fails = true;
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
    ).thenAnswer((_) async {
      if (fails) throw StateError('private storage failure');
      return outcome;
    });
    controller.pick(chosenChoiceId: 'b');
    await expectLater(controller.check(), throwsStateError);
    expect(running().selectedChoiceId, 'b');
    expect(running().checking, isFalse);
    expect(running().session.outcomes, isEmpty);
    fails = false;
    await controller.check();
    expect(running().session.outcomes, hasLength(1));
  });

  test('late Check cannot resurrect a reset session', () async {
    final pending = Completer<AnswerOutcome>();
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
    ).thenAnswer((_) => pending.future);
    controller.pick(chosenChoiceId: 'b');
    final checked = controller.check();
    controller.reset();
    pending.complete(outcome);
    await checked;
    expect(container.read(quizControllerProvider), isA<QuizIdle>());
  });

  for (final fails in [false, true]) {
    test('disposed pending Check handles late result fails=$fails', () async {
      final pending = Completer<AnswerOutcome>();
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
      ).thenAnswer((_) => pending.future);
      controller.pick(chosenChoiceId: 'b');
      final checked = controller.check();
      container.dispose();
      disposed = true;
      if (fails) {
        final error = StateError('private submit failure');
        final expectation = expectLater(checked, throwsA(same(error)));
        pending.completeError(error);
        await expectation;
      } else {
        pending.complete(outcome);
        await expectLater(checked, completes);
      }
    });
  }
}
