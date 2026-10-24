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
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _BlockedContent extends ContentRepository {
  _BlockedContent(super.db);
  bool blocked = false;
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<List<Question>> hydrateSelectedQuestions(List<String> ids) async {
    if (blocked) {
      if (!entered.isCompleted) entered.complete();
      await release.future;
    }
    return super.hydrateSelectedQuestions(ids);
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
    test('explicit next preserves the original $change boundary', () async {
      final db = inMemoryDatabase();
      final contentDb = inMemoryContentDatabase();
      addTearDown(contentDb.close);
      addTearDown(db.close);
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'e',
        topicId: 't',
        topicName: 'Topic',
        questionIds: [for (var i = 0; i < 6; i++) 'q$i'],
      );
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
      final batches = container.read(quizReviewBatchRepositoryProvider);
      final scope = batches.capture('local', 'e')!;
      final now = DateTime.utc(2026, 10, 23);
      await batches.start(
        prepared: PreparedReviewBatch.fromReviews(
          scope: scope,
          preferences: QuizPreferences(
            sessionLength: 5,
            ordering: QuizOrdering.interleavedTail,
          ),
          localDay: now,
          orderedDueReviews: await content.hydrateSelectedQuestions(
            [for (var i = 0; i < 6; i++) 'q$i'],
          ),
        ),
        content: content,
        now: now,
        canPersist: () => true,
      );
      final controller = container.read(quizControllerProvider.notifier);
      await controller.resumeToday(examId: 'e');
      for (var i = 0; i < 5; i++) {
        final running = container.read(quizControllerProvider) as QuizRunning;
        controller
          ..markQuestionReady(
            sessionId: running.session.sessionId,
            questionIndex: running.session.currentIndex,
          )
          ..pick(
            chosenChoiceId: running.session.currentQuestion.correctChoice.id,
          );
        await controller.check();
        await controller.next();
      }
      final completed = container.read(quizControllerProvider) as QuizComplete;
      content.blocked = true;
      final next = controller.continueReviews(completed.session)..ignore();
      await content.entered.future.timeout(const Duration(seconds: 5));
      expect(container.read(quizControllerProvider), same(completed));
      switch (change) {
        case 'account':
          container.read(auth.notifier).state =
              const AuthState.anonymous(uid: 'second');
          await container.read(authStateProvider.future);
        case 'exam':
          container.read(exam.notifier).state = 'other';
          await container.read(activeExamFocusProvider.future);
        case 'token':
          // A queued token transition must prevent old publication.
          final transition = SyncActiveContextStore(db).clearStable();
          content.release.complete();
          await transition;
        case 'wipe':
          try {
            await SyncLocalStateWiper(db)
                .wipeAll()
                .timeout(const Duration(seconds: 2));
          } finally {
            content.release.complete();
          }
        case 'disposed':
          container.dispose();
          disposed = true;
        case 'stable':
          break;
      }
      if (!content.release.isCompleted) content.release.complete();
      if (change != 'stable') {
        await expectLater(next, throwsStateError);
        if (change == 'wipe') {
          expect(await db.select(db.quizSessions).get(), isEmpty);
          expect(await db.select(db.attemptsLocal).get(), isEmpty);
        }
        if (!disposed) {
          expect(container.read(quizControllerProvider), same(completed));
        }
        return;
      }
      await next;
      final running = container.read(quizControllerProvider) as QuizRunning;
      expect(running.session.reviewBatch!.ordinal, 2);
      controller.pick(
        chosenChoiceId: running.session.currentQuestion.correctChoice.id,
      );
      final picked = container.read(quizControllerProvider) as QuizRunning;
      await controller.continueReviews(completed.session);
      expect(container.read(quizControllerProvider), same(picked));
      expect((await db.select(db.quizSessions).get()).length, 2);
    });
  }
}
