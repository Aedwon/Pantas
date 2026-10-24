import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final kind in TodayQuestionKind.values) {
    test('actual $kind launch keeps Reviews and New separate', () async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      addTearDown(content.close);
      addTearDown(db.close);
      final reviews = List.generate(6, (i) => 'r$i');
      final news = ['n0', 'n1'];
      await seedContentTopicWithQuestions(
        content,
        examId: 'e',
        topicId: 't',
        topicName: 'Topic',
        lessonIds: ['a', 'b'],
        questionIds: [...reviews, ...news],
        questionLessonMap: {'n0': 'a', 'n1': 'b'},
      );
      await db.into(db.accountPrefs).insert(
            AccountPrefsCompanion.insert(
              key: 'quiz_session_length',
              value: '5',
            ),
          );
      await SyncActiveContextStore(db).clearStable();
      final plan = DayPlan(
        day: DateTime(2026, 10, 23),
        lessonIds: const ['a', 'b'],
        reviewQuestionIds: reviews,
        newQuestionIds: news,
        isMockDay: false,
        advancedIds: const {},
      );
      final today = RoadmapToday(
        snapshot: DaySnapshot(
          plan: plan,
          digest: RoadmapDigest(
            examId: 'e',
            examDate: '',
            scopeTopicIds: const ['t'],
            contentRevision: 'test',
            assessmentCompleted: true,
            recordedMockCount: 0,
          ),
          topicOrderHead: const ['t'],
        ),
        remaining: plan,
        originalDone: false,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          authStateProvider.overrideWith(
            (_) => Stream.value(const AuthState.anonymous(uid: 'test')),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          roadmapTodayProvider('e').overrideWith((_) async => today),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authStateProvider.future);
      await container.read(activeExamFocusProvider.future);
      await container.read(lessonProgressRepositoryProvider).markRead('b');
      final launcher = container.read(todayQuestionLauncherProvider);
      final work = await launcher.load('e');
      expect(work.preparedReviews.chunks.map((c) => c.length), [5, 1]);
      expect(work.newQuestions.map((q) => q.id), ['n1', 'n0']);
      final session =
          await launcher.start(work, kind: kind, isAlive: () => true);
      expect(
        session.questions.map((q) => q.id).toSet(),
        kind == TodayQuestionKind.reviews
            ? reviews.take(5).toSet()
            : news.toSet(),
      );
      expect(
        session.reviewBatch?.total,
        kind == TodayQuestionKind.reviews ? 2 : null,
      );
      expect(
        session.origin,
        kind == TodayQuestionKind.newQuestions
            ? SessionOrigin.newQuestions
            : SessionOrigin.todayInterleaved,
      );
      expect(
        (await QuizSessionRepository(db)
                .activeFor(userId: 'local', examId: 'e'))
            ?.id,
        session.sessionId,
      );

      final panel = await container.read(sessionPanelProvider('e').future)
          as SessionPanelInProgress;
      expect(
        panel.reviewSession?.ordinal,
        kind == TodayQuestionKind.reviews ? 1 : null,
      );
      final controller = container.read(quizControllerProvider.notifier);
      await controller.resumeToday(examId: 'e');
      for (var i = 0; i < session.questions.length; i++) {
        final running = container.read(quizControllerProvider) as QuizRunning;
        controller.markQuestionReady(
          sessionId: session.sessionId,
          questionIndex: i,
        );
        await controller.answer(
          chosenChoiceId: running.session.currentQuestion.correctChoice.id,
        );
        await controller.next();
      }
      final complete = container.read(quizControllerProvider) as QuizComplete;
      expect(complete.attempt.items, hasLength(session.questions.length));
      expect(complete.attempt.origin, session.origin.storageValue);
      expect(session.origin.isStreakEligible, isTrue);
      if (kind == TodayQuestionKind.reviews) {
        await db.customStatement(
          "UPDATE account_prefs SET value = '20' "
          "WHERE key = 'quiz_session_length'",
        );
        final retained = await launcher.load('e');
        expect(retained.reviewSizes, [5, 1]);
        expect(retained.reviewProgress, [5, 0]);
        final next =
            await launcher.start(retained, kind: kind, isAlive: () => true);
        expect(next.reviewBatch!.ordinal, 2);
        expect(next.questions.single.id, 'r5');
      }
    });
  }
  for (final stale in ['wipe', 'page', 'paused', 'version', 'missing-review']) {
    test('Today launch rejects $stale without replacing progress', () async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      addTearDown(content.close);
      addTearDown(db.close);
      await seedContentTopicWithQuestions(
        content,
        examId: 'e',
        topicId: 't',
        topicName: 'Topic',
        questionIds: ['n'],
      );
      await SyncActiveContextStore(db).clearStable();
      final plan = DayPlan(
        day: DateTime(2026, 10, 23),
        lessonIds: const [],
        reviewQuestionIds: stale == 'missing-review' ? ['missing'] : [],
        newQuestionIds: const ['n'],
        isMockDay: false,
        advancedIds: const {},
      );
      final today = RoadmapToday(
        snapshot: DaySnapshot(
          plan: plan,
          digest: RoadmapDigest(
            examId: 'e',
            examDate: '',
            scopeTopicIds: const ['t'],
            contentRevision: 'test',
            assessmentCompleted: true,
            recordedMockCount: 0,
          ),
          topicOrderHead: const ['t'],
        ),
        remaining: plan,
        originalDone: false,
      );
      final c = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          authStateProvider.overrideWith(
            (_) => Stream.value(const AuthState.anonymous(uid: 'test')),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          roadmapTodayProvider('e').overrideWith((_) async => today),
        ],
      );
      addTearDown(c.dispose);
      await c.read(authStateProvider.future);
      await c.read(activeExamFocusProvider.future);
      final launch = c.read(todayQuestionLauncherProvider);
      if (stale == 'missing-review') {
        await expectLater(launch.load('e'), throwsStateError);
        expect(await db.select(db.quizSessions).get(), isEmpty);
        return;
      }
      final work = await launch.load('e');
      if (stale == 'version') {
        await content
            .customStatement('UPDATE content_questions SET version = 2');
      }
      if (stale == 'wipe') await SyncLocalStateWiper(db).wipeAll();
      if (stale == 'paused') {
        await QuizSessionRepository(db).create(
          sessionId: 'paused',
          userId: 'local',
          examId: 'e',
          origin: SessionOrigin.drill,
          questionIds: ['n'],
          startedAt: DateTime(2026),
        );
      }
      await expectLater(
        launch.start(
          work,
          kind: TodayQuestionKind.newQuestions,
          isAlive: () => stale != 'page',
        ),
        throwsStateError,
      );
      final rows = await db.select(db.quizSessions).get();
      expect(rows, stale == 'paused' ? hasLength(1) : isEmpty);
      if (stale == 'paused') expect(rows.single.quitAt, isNull);
    });
  }
}
