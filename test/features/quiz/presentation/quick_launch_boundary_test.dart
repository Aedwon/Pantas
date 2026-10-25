import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _BlockedContent extends ContentRepository {
  _BlockedContent(super.db);
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<List<Question>> questionsByTopic(String topicId) async {
    if (!entered.isCompleted) entered.complete();
    await release.future;
    return super.questionsByTopic(topicId);
  }
}

void main() {
  for (final change in [
    'stable',
    'account',
    'exam',
    'token',
    'wipe',
    'disposed',
  ]) {
    test('Quick launch keeps its original $change boundary', () async {
      final db = inMemoryDatabase();
      final contentDb = inMemoryContentDatabase();
      addTearDown(contentDb.close);
      addTearDown(db.close);
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'e',
        topicId: 't',
        topicName: 'Topic',
        questionIds: ['q'],
      );
      final sessions = QuizSessionRepository(db);
      await SyncActiveContextStore(db).clearStable();
      final content = _BlockedContent(contentDb);
      final auth = StateProvider<AuthState>(
        (_) => const AuthState.anonymous(uid: 'first'),
      );
      final exam = StateProvider<String>((_) => 'e');
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          contentRepositoryProvider.overrideWithValue(content),
          quizSessionRepositoryProvider.overrideWithValue(sessions),
          authStateProvider
              .overrideWith((ref) => Stream.value(ref.watch(auth))),
          activeExamFocusProvider.overrideWith(
            (ref) async =>
                ActiveExamFocus.selected(buildExam(id: ref.watch(exam))),
          ),
        ],
      );
      var disposed = false;
      addTearDown(() {
        if (!disposed) container.dispose();
      });
      await container.read(authStateProvider.future);
      await container.read(activeExamFocusProvider.future);
      final launch = container
          .read(quizControllerProvider.notifier)
          .start(examId: 'e', topicId: 't', count: 1);
      await content.entered.future;
      switch (change) {
        case 'account':
          container.read(auth.notifier).state =
              const AuthState.anonymous(uid: 'second');
          await container.read(authStateProvider.future);
        case 'exam':
          container.read(exam.notifier).state = 'other';
          await container.read(activeExamFocusProvider.future);
        case 'token':
          await SyncActiveContextStore(db).clearStable();
        case 'wipe':
          await SyncLocalStateWiper(db).wipeAll();
        case 'disposed':
          container.dispose();
          disposed = true;
        case 'stable':
          break;
      }
      content.release.complete();
      if (disposed) {
        await expectLater(launch, completes);
        expect(
          (await sessions.activeFor(userId: 'local', examId: 'e'))?.id,
          isNull,
        );
        expect(await db.select(db.quizSessions).get(), isEmpty);
        return;
      }
      await launch;
      final state = container.read(quizControllerProvider);
      if (change == 'stable') {
        expect(state, isA<QuizRunning>());
        expect((state as QuizRunning).persisted, isTrue);
        expect(state.session.origin, SessionOrigin.todayTopic);
        expect(
          (await sessions.activeFor(userId: 'local', examId: 'e'))?.origin,
          'today_topic',
        );
      } else {
        expect(state, isNot(isA<QuizRunning>()));
        if (change == 'wipe') {
          expect(await db.select(db.quizSessions).get(), isEmpty);
        } else {
          expect(
            (await sessions.activeFor(userId: 'local', examId: 'e'))?.id,
            isNull,
          );
          expect(await db.select(db.quizSessions).get(), isEmpty);
        }
      }
    });
  }

  test('Quick checked answer survives reset and ordinary resume', () async {
    final db = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      questionIds: ['q', 'q2'],
    );
    final sessions = QuizSessionRepository(db);
    await SyncActiveContextStore(db).clearStable();
    final content = _BlockedContent(contentDb);
    final auth = StateProvider<AuthState>(
      (_) => const AuthState.anonymous(uid: 'first'),
    );
    final exam = StateProvider<String>((_) => 'e');
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentRepositoryProvider.overrideWithValue(content),
        quizSessionRepositoryProvider.overrideWithValue(sessions),
        authStateProvider.overrideWith((ref) => Stream.value(ref.watch(auth))),
        activeExamFocusProvider.overrideWith(
          (ref) async =>
              ActiveExamFocus.selected(buildExam(id: ref.watch(exam))),
        ),
      ],
    );
    const disposed = false;
    addTearDown(() {
      if (!disposed) container.dispose();
    });
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    content.release.complete();

    final controller = container.read(quizControllerProvider.notifier);
    await controller.start(examId: 'e', topicId: 't', count: 2);
    final started = container.read(quizControllerProvider) as QuizRunning;
    controller
      ..markQuestionReady(
        sessionId: started.session.sessionId,
        questionIndex: 0,
      )
      ..pick(
        chosenChoiceId: started.session.currentQuestion.choices
            .firstWhere((c) => c.isCorrect)
            .id,
      );
    await controller.check();
    final row = await sessions.activeFor(userId: 'local', examId: 'e');
    expect(row, isNotNull);
    expect(row!.outcomes, hasLength(1));
    controller.reset();
    await controller.resumeToday(examId: 'e');
    final resumed = container.read(quizControllerProvider) as QuizRunning;
    expect(resumed.session.sessionId, started.session.sessionId);
    expect(resumed.session.outcomes, hasLength(1));
    expect(resumed.session.currentIndex, 1);
    expect(await db.select(db.attemptsLocal).get(), isEmpty);
  });
  test('Quick launch preserves a different paused quiz', () async {
    final db = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      questionIds: ['q', 'q2'],
    );
    final sessions = QuizSessionRepository(db);
    await SyncActiveContextStore(db).clearStable();
    final content = _BlockedContent(contentDb);
    final auth = StateProvider<AuthState>(
      (_) => const AuthState.anonymous(uid: 'first'),
    );
    final exam = StateProvider<String>((_) => 'e');
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentRepositoryProvider.overrideWithValue(content),
        quizSessionRepositoryProvider.overrideWithValue(sessions),
        authStateProvider.overrideWith((ref) => Stream.value(ref.watch(auth))),
        activeExamFocusProvider.overrideWith(
          (ref) async =>
              ActiveExamFocus.selected(buildExam(id: ref.watch(exam))),
        ),
      ],
    );
    const disposed = false;
    addTearDown(() {
      if (!disposed) container.dispose();
    });
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    content.release.complete();

    await sessions.create(
      sessionId: 'paused',
      userId: 'local',
      examId: 'e',
      origin: SessionOrigin.drill,
      questionIds: ['q'],
      startedAt: DateTime.utc(2026),
    );
    await container
        .read(quizControllerProvider.notifier)
        .start(examId: 'e', topicId: 't', count: 1);
    expect(container.read(quizControllerProvider), isA<QuizFailure>());
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'e'))?.id,
      'paused',
    );
    expect(await db.select(db.quizSessions).get(), hasLength(1));
  });
}
