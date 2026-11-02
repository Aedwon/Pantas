import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _Content extends ContentRepository {
  _Content(super.db);
  bool fail = false;
  bool blocked = false;
  int hydrations = 0;
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<List<Question>> hydrateSelectedQuestions(List<String> ids) async {
    hydrations++;
    if (fail) throw StateError('Content temporarily unavailable');
    if (blocked) {
      if (!entered.isCompleted) entered.complete();
      await release.future;
    }
    return super.hydrateSelectedQuestions(ids);
  }
}

int lessonOpens = 0;

class _Rig {
  _Rig(this.db, this.content);
  final AppDatabase db;
  final _Content content;
}

Future<void> settle(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 80 && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 20));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2)),
    );
  }
}

void main() {
  for (final wide in [false, true]) {
    final layout = wide ? 'wide' : 'phone';
    Future<_Rig> pump(
      WidgetTester tester, {
      bool reviewsDue = true,
      bool newDue = true,
      bool lessonsRead = true,
    }) async {
      tester.view.physicalSize =
          wide ? const Size(1440, 900) : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      lessonOpens = 0;
      final db = inMemoryDatabase();
      final contentDb = inMemoryContentDatabase();
      addTearDown(contentDb.close);
      addTearDown(db.close);
      final reviews = reviewsDue ? List.generate(6, (i) => 'r$i') : <String>[];
      final news = newDue ? ['n0', 'n1'] : <String>[];
      late RoadmapToday today;
      await tester.runAsync(() async {
        await seedContentTopicWithQuestions(
          contentDb,
          examId: 'e',
          topicId: 't',
          topicName: 'Topic',
          lessonIds: ['a', 'b'],
          questionIds: [...List.generate(6, (i) => 'r$i'), 'n0', 'n1'],
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
      final content = _Content(contentDb);
      final container = ProviderContainer(
        overrides: [
          homeTodayLoaderProvider.overrideWith(
            (ref) => (examId, guard) async => HomeTodayData(
                  today: today,
                  lessons: [
                    for (final id in ['a', 'b'])
                      HomeTodayLesson(
                        id: id,
                        title: 'Lesson $id',
                        subject: 'Topic',
                        minutes: 8,
                        read: lessonsRead,
                      ),
                  ],
                  questionWork: await ref
                      .read(todayQuestionLauncherProvider)
                      .load(examId, originalGuard: guard),
                  canAdvance: false,
                ),
          ),
          contentRepositoryProvider.overrideWithValue(content),
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
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
              pageBuilder: (today, _) =>
                  Scaffold(body: SingleChildScrollView(child: today)),
            ),
          ),
          GoRoute(
            path: '/lesson/:id',
            builder: (_, state) {
              lessonOpens++;
              return Scaffold(
                body: Text('Lesson ${state.pathParameters['id']} opened'),
              );
            },
          ),
          GoRoute(
            path: '/quiz/resume/e',
            builder: (_, __) => const Scaffold(body: Text('Actual run opened')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: wide ? buildLightTheme(web: true) : buildLightTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            routerConfig: router,
          ),
        ),
      );
      await settle(tester, () => find.text('Reviews').evaluate().isNotEmpty);
      return _Rig(db, content);
    }

    testWidgets('$layout: Start Reviews goes straight to the session',
        (tester) async {
      await pump(tester);
      expect(find.text('Start Reviews'), findsOneWidget);
      await tester.tap(find.text('Start Reviews'));
      await settle(
        tester,
        () => find.text('Actual run opened').evaluate().isNotEmpty,
      );
      expect(find.text('Actual run opened'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    testWidgets('$layout: Start New Questions goes straight to the session',
        (tester) async {
      await pump(tester, reviewsDue: false);
      expect(find.text('Start New Questions'), findsOneWidget);
      await tester.tap(find.text('Start New Questions'));
      await settle(
        tester,
        () => find.text('Actual run opened').evaluate().isNotEmpty,
      );
      expect(find.text('Actual run opened'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    testWidgets('$layout: the Reviews row still opens the panel',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text('Reviews'));
      await settle(
        tester,
        () => find.text('Session 1').evaluate().isNotEmpty,
      );
      expect(find.text('Session 1'), findsOneWidget);
      expect(find.text('Actual run opened'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    testWidgets('$layout: Continue Lesson opens the lesson with no panel',
        (tester) async {
      await pump(tester, lessonsRead: false);
      if (wide) {
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      } else {
        await tester.tap(find.text('Continue Lesson'));
      }
      await settle(
        tester,
        () => find.text('Lesson a opened').evaluate().isNotEmpty,
      );
      expect(find.text('Lesson a opened'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    testWidgets('$layout: a second lesson press is ignored while opening',
        (tester) async {
      await pump(tester, lessonsRead: false);
      await tester.tap(find.text('Continue Lesson'));
      await tester.tap(find.text('Continue Lesson'), warnIfMissed: false);
      await settle(
        tester,
        () => find.text('Lesson a opened').evaluate().isNotEmpty,
      );
      expect(find.text('Lesson a opened'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    if (wide) {
      testWidgets('a held Enter on Home opens the lesson once', (tester) async {
        await pump(tester, lessonsRead: false);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
        await settle(
          tester,
          () => find.text('Lesson a opened').evaluate().isNotEmpty,
        );
        expect(find.text('Lesson a opened'), findsOneWidget);
        expect(lessonOpens, 1);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
    testWidgets('$layout: unread lessons keep the lesson button',
        (tester) async {
      await pump(tester, lessonsRead: false);
      expect(find.text('Continue Lesson'), findsOneWidget);
      expect(find.text('Start Reviews'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    testWidgets('$layout: nothing left shows no start button', (tester) async {
      await pump(tester, reviewsDue: false, newDue: false);
      expect(find.text('Start Reviews'), findsNothing);
      expect(find.text('Start New Questions'), findsNothing);
      expect(find.text('Continue Reviews'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    testWidgets('$layout: busy while starting, and a second press is ignored',
        (tester) async {
      final rig = await pump(tester);
      rig.content.blocked = true;
      await tester.tap(find.text('Start Reviews'));
      await settle(tester, () => rig.content.entered.isCompleted);
      await tester.pump();
      final busy = wide
          ? tester.widget<WebButton>(find.byType(WebButton)).busy
          : tester.widget<PantasButton>(find.byType(PantasButton)).busy;
      expect(busy, isTrue);
      final before = rig.content.hydrations;
      await tester.tap(find.text('Start Reviews'), warnIfMissed: false);
      await tester.pump();
      expect(rig.content.hydrations, before);
      rig.content.release.complete();
      await settle(
        tester,
        () => find.text('Actual run opened').evaluate().isNotEmpty,
      );
      expect(find.text('Actual run opened'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    testWidgets('$layout: a failed start shows the message and retry',
        (tester) async {
      final rig = await pump(tester);
      rig.content.fail = true;
      await tester.tap(find.text('Start Reviews'));
      await settle(
        tester,
        () => find.text('Could not start your quiz.').evaluate().isNotEmpty,
      );
      expect(find.text('Could not start your quiz.'), findsOneWidget);
      expect(find.text('Actual run opened'), findsNothing);
      rig.content.fail = false;
      await tester.tap(find.text('Try Again'));
      await settle(
        tester,
        () => find.text('Actual run opened').evaluate().isNotEmpty,
      );
      expect(find.text('Actual run opened'), findsOneWidget);
      final row = await tester.runAsync(
        () => QuizSessionRepository(rig.db)
            .activeFor(userId: 'local', examId: 'e'),
      );
      expect(row!.questionIds, hasLength(5));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }
}
