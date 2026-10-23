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
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
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
    test('custom launch keeps its original $change boundary', () async {
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
      await sessions.create(
        sessionId: 'previous',
        userId: 'local',
        examId: 'e',
        origin: SessionOrigin.drill,
        questionIds: ['q'],
        startedAt: DateTime.utc(2026),
      );
      await QuestionFlagsRepository(db).flag('q');
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
      final launch =
          container.read(quizControllerProvider.notifier).startPractice(
                examId: 'e',
                units: const [PracticeUnit(topicId: 't')],
                perUnit: 1,
              );
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
          'previous',
        );
        expect(await db.select(db.quizSessions).get(), hasLength(1));
        return;
      }
      await launch;
      final state = container.read(quizControllerProvider);
      if (change == 'stable') {
        expect(state, isA<QuizRunning>());
        expect((state as QuizRunning).session.origin, SessionOrigin.drill);
        expect(
          (await sessions.activeFor(userId: 'local', examId: 'e'))?.origin,
          'drill',
        );
      } else {
        expect(state, isNot(isA<QuizRunning>()));
        if (change == 'wipe') {
          expect(await db.select(db.quizSessions).get(), isEmpty);
        } else {
          expect(
            (await sessions.activeFor(userId: 'local', examId: 'e'))?.id,
            'previous',
          );
          expect(await db.select(db.quizSessions).get(), hasLength(1));
        }
      }
    });
  }
}
