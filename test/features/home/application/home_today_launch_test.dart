import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _PendingContent extends ContentRepository {
  _PendingContent(super.db);
  bool blocked = false;
  bool fail = false;
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<List<Question>> hydrateSelectedQuestions(List<String> ids) async {
    if (fail) throw StateError('Content temporarily unavailable');
    if (blocked) {
      if (!entered.isCompleted) entered.complete();
      await release.future;
    }
    return super.hydrateSelectedQuestions(ids);
  }
}

void main() {
  for (final kind in TodayQuestionKind.values) {
    for (final exit in [
      'start',
      'dark-large',
      'dismiss',
      'page',
      'wipe',
      'paused',
    ]) {
      testWidgets('Home row actual $kind exit=$exit', (tester) async {
        final completes = exit == 'start' || exit == 'dark-large';
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = inMemoryDatabase();
        final content = inMemoryContentDatabase();
        addTearDown(content.close);
        addTearDown(db.close);
        final reviews = List.generate(6, (i) => 'r$i');
        final news = ['n0', 'n1'];
        late RoadmapToday today;
        await tester.runAsync(() async {
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
          today = RoadmapToday(
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
        });
        final pending = _PendingContent(content);
        final container = ProviderContainer(
          overrides: [
            homeTodayLoaderProvider.overrideWith(
              (ref) => (examId, guard) async => HomeTodayData(
                    today: today,
                    lessons: const [
                      HomeTodayLesson(
                        id: 'a',
                        title: 'Lesson a',
                        subject: 'Topic',
                        minutes: 8,
                        read: false,
                      ),
                      HomeTodayLesson(
                        id: 'b',
                        title: 'Lesson b',
                        subject: 'Topic',
                        minutes: 8,
                        read: false,
                      ),
                    ],
                    questionWork: await ref
                        .read(todayQuestionLauncherProvider)
                        .load(examId, originalGuard: guard),
                    canAdvance: false,
                  ),
            ),
            contentRepositoryProvider.overrideWithValue(pending),
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
        await tester.runAsync(() => container.read(authStateProvider.future));
        await tester
            .runAsync(() => container.read(activeExamFocusProvider.future));

        final router = GoRouter(
          initialLocation: '/quiz',
          routes: [
            GoRoute(
              path: '/quiz',
              builder: (_, __) => HomeTodayScreen(
                examId: 'e',
                pageBuilder: (today) =>
                    Scaffold(body: SingleChildScrollView(child: today)),
              ),
            ),
            GoRoute(
              path: '/quiz/resume/e',
              builder: (_, __) =>
                  const Scaffold(body: Text('Actual run opened')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme:
                  exit == 'dark-large' ? buildDarkTheme() : buildLightTheme(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(exit == 'dark-large' ? 2 : 1),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              routerConfig: router,
            ),
          ),
        );
        for (var i = 0;
            i < 80 && find.text('Reviews').evaluate().isEmpty;
            i++) {
          await tester.pump(const Duration(milliseconds: 20));
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 2)),
          );
        }
        await tester.tap(
          find.text(
            kind == TodayQuestionKind.reviews ? 'Reviews' : 'New questions',
          ),
        );
        for (var i = 0;
            i < 80 &&
                find
                    .text(
                      kind == TodayQuestionKind.reviews
                          ? 'Start Reviews'
                          : 'Start New Questions',
                    )
                    .evaluate()
                    .isEmpty;
            i++) {
          await tester.pump(const Duration(milliseconds: 20));
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 2)),
          );
        }
        expect(
          find.text(
            kind == TodayQuestionKind.reviews
                ? 'Start Reviews'
                : 'Start New Questions',
          ),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 600));
        if (!completes && exit != 'paused') pending.blocked = true;
        if (exit == 'paused') {
          await tester.runAsync(
            () => QuizSessionRepository(db).create(
              sessionId: 'paused',
              userId: 'local',
              examId: 'e',
              origin: SessionOrigin.drill,
              questionIds: ['n0'],
              startedAt: DateTime(2026),
            ),
          );
        }
        await tester.tap(
          find.text(
            kind == TodayQuestionKind.reviews
                ? 'Start Reviews'
                : 'Start New Questions',
          ),
        );

        if (exit == 'paused') {
          for (var i = 0;
              i < 80 &&
                  find.text('Could not start your quiz.').evaluate().isEmpty;
              i++) {
            await tester.pump(const Duration(milliseconds: 20));
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 2)),
            );
          }
          expect(find.text('Could not start your quiz.'), findsOneWidget);
          final paused = await tester.runAsync(
            () => QuizSessionRepository(db)
                .activeFor(userId: 'local', examId: 'e'),
          );
          expect(paused!.id, 'paused');
          expect(paused.quitAt, isNull);
          await tester.runAsync(
            () => QuizSessionRepository(db).quitAllOpen(
              userId: 'local',
              examId: 'e',
              quitAt: DateTime(2026, 10, 23),
            ),
          );
          await tester.tap(find.text('Try Again'));
        }
        if (!completes && exit != 'paused') {
          for (var i = 0; i < 80 && !pending.entered.isCompleted; i++) {
            await tester.pump(const Duration(milliseconds: 20));
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 2)),
            );
          }
          expect(pending.entered.isCompleted, isTrue);
          if (exit == 'wipe') {
            await tester.runAsync(
              () => SyncLocalStateWiper(db)
                  .wipeAll()
                  .timeout(const Duration(seconds: 2)),
            );
          } else {
            if (exit == 'page') {
              await tester.pumpWidget(const SizedBox());
            } else {
              await tester.tapAt(const Offset(5, 5));
            }
            await tester.pump(const Duration(milliseconds: 600));
            await tester.runAsync(
              () => QuizSessionRepository(db).create(
                sessionId: 'newer',
                userId: 'local',
                examId: 'e',
                origin: SessionOrigin.drill,
                questionIds: ['n0'],
                startedAt: DateTime(2026),
              ),
            );
          }
          pending.release.complete();
          for (var i = 0; i < 80; i++) {
            await tester.pump(const Duration(milliseconds: 20));
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 2)),
            );
          }
          final rows =
              await tester.runAsync(() => db.select(db.quizSessions).get());
          expect(rows, exit == 'wipe' ? isEmpty : hasLength(1));
          if (exit != 'wipe') {
            expect(rows!.single.id, 'newer');
            expect(rows.single.quitAt, isNull);
          }
          expect(find.text('Actual run opened'), findsNothing);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
          return;
        }
        for (var i = 0;
            i < 80 && find.text('Actual run opened').evaluate().isEmpty;
            i++) {
          await tester.pump(const Duration(milliseconds: 20));
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 2)),
          );
        }
        expect(find.text('Actual run opened'), findsOneWidget);
        final row = await tester.runAsync(
          () =>
              QuizSessionRepository(db).activeFor(userId: 'local', examId: 'e'),
        );
        expect(
          row!.questionIds.toSet(),
          kind == TodayQuestionKind.reviews
              ? reviews.take(5).toSet()
              : news.toSet(),
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
  }
}
