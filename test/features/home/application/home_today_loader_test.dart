import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

/// A launcher whose question preparation waits until the test lets it go.
class _HeldLauncher extends TodayQuestionLauncher {
  _HeldLauncher(super.ref, super.alive);
  final gate = Completer<void>();
  int loads = 0;
  @override
  Future<TodayQuestionWork> load(
    String examId, {
    Future<Future<bool> Function()>? originalGuard,
  }) async {
    loads++;
    await gate.future;
    return super.load(examId, originalGuard: originalGuard);
  }
}

class _Fixture {
  _Fixture(this.container, this.launcher, this.today);
  final ProviderContainer container;
  final _HeldLauncher launcher;
  final RoadmapToday today;
}

Future<_Fixture> _fixture(
  WidgetTester? tester, {
  Future<RoadmapToday>? roadmap,
}) async {
  final db = inMemoryDatabase();
  final content = inMemoryContentDatabase();
  addTearDown(content.close);
  addTearDown(db.close);
  final reviews = List.generate(6, (i) => 'r$i');
  final news = ['n0', 'n1'];
  late RoadmapToday today;
  Future<T?> real<T>(Future<T> Function() body) =>
      tester == null ? body() : tester.runAsync(body);
  await real(() async {
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
          AccountPrefsCompanion.insert(key: 'quiz_session_length', value: '5'),
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
  Map<String, Object?> dayPlan() => {
        'day': '2026-10-23',
        'lessonIds': ['a', 'b'],
        'reviewQuestionIds': reviews,
        'newQuestionIds': news,
        'advancedIds': <String>[],
        'isMockDay': false,
        'isRestDay': false,
      };
  final serverRoadmap = StudyRoadmap.decode(
    {
      'examId': 'e',
      'serverNow': 100,
      'accessRecheckAt': null,
      'proCovered': false,
      'revision': 'test',
      'state': 'planning',
      'today': dayPlan(),
      'remaining': dayPlan(),
      'originalDone': false,
      'canAdvance': false,
      'todayTopicOrder': ['t'],
      'weekDays': [
        for (var i = 0; i < 7; i++) {'state': i == 6 ? 'today' : 'unknown'},
      ],
    },
    examId: 'e',
  );
  late _HeldLauncher launcher;
  final container = ProviderContainer(
    overrides: [
      todayQuestionLauncherProvider.overrideWith(
        (ref) => launcher = _HeldLauncher(ref, () => true),
      ),
      appDatabaseProvider.overrideWithValue(db),
      contentDatabaseProvider.overrideWithValue(content),
      authStateProvider.overrideWith(
        (_) => Stream.value(const AuthState.anonymous(uid: 'test')),
      ),
      activeExamFocusProvider.overrideWith(
        (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
      ),
      studyUsesServerProvider.overrideWithValue(true),
      userSettingsProvider.overrideWith((_) async => UserSettings.defaults()),
      serverStudyRoadmapProvider('e')
          .overrideWith((_) => Stream.value(serverRoadmap)),
      roadmapTodayProvider('e')
          .overrideWith((_) => roadmap ?? Future.value(today)),
    ],
  );
  addTearDown(container.dispose);
  container.read(todayQuestionLauncherProvider);
  await real(() => container.read(authStateProvider.future));
  await real(() => container.read(activeExamFocusProvider.future));
  return _Fixture(container, launcher, today);
}

Future<void> _settle(WidgetTester tester, [int rounds = 40]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.pump(const Duration(milliseconds: 20));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2)),
    );
  }
}

void main() {
  test('Home data is ready while question preparation is pending',
      timeout: const Timeout(Duration(seconds: 30)), () async {
    final f = await _fixture(null);
    {
      final guard = f.launcher.captureGuard('e', isAlive: () => true);
      final data = await f.container
          .read(homeTodayLoaderProvider)('e', guard)
          .timeout(const Duration(seconds: 5));
      expect(data.questionWork, isNull);
      expect(data.questionCounts?.reviewsTotal, 6);
      expect(data.questionCounts?.reviewsDone, 0);
      expect(data.questionCounts?.newTotal, 2);
      expect(data.lessons.map((l) => l.id), ['a', 'b']);
      expect(f.launcher.loads, 1);

      f.launcher.gate.complete();
      final work = await data.questionPreparation!;
      // Counts and order are the same once the bodies are ready.
      expect(work.reviewsTotal, data.questionCounts!.reviewsTotal);
      expect(work.reviewsDone, data.questionCounts!.reviewsDone);
      expect(work.newTotal, data.questionCounts!.newTotal);
      expect(work.reviewSizes, [5, 1]);
      expect(work.newQuestions.map((q) => q.id), ['n0', 'n1']);
      expect(f.launcher.loads, 1);
    }
  });

  test('an owner change during preparation still aborts it',
      timeout: const Timeout(Duration(seconds: 30)), () async {
    final f = await _fixture(null);
    {
      var owner = true;
      final guard = Future.value(() async => owner);
      final data = await f.container.read(homeTodayLoaderProvider)('e', guard);
      owner = false;
      f.launcher.gate.complete();
      await expectLater(
        data.questionPreparation,
        throwsA(
          isA<StateError>()
              .having((e) => e.message, 'message', 'Quiz owner changed'),
        ),
      );
    }
  });

  test('an owner change while the plan loads aborts Home',
      timeout: const Timeout(Duration(seconds: 30)), () async {
    final plan = Completer<RoadmapToday>();
    final f = await _fixture(null, roadmap: plan.future);
    {
      var owner = true;
      final guard = Future.value(() async => owner);
      final request = f.container.read(homeTodayLoaderProvider)('e', guard);
      final failure = expectLater(
        request,
        throwsA(
          isA<StateError>()
              .having((e) => e.message, 'message', 'Home owner changed'),
        ),
      );
      owner = false;
      plan.complete(f.today);
      f.launcher.gate.complete();
      await failure;
    }
  });

  Future<void> pumpHome(WidgetTester tester, _Fixture f) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
          path: '/quiz/resume/e',
          builder: (_, __) => const Scaffold(body: Text('Actual run opened')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: f.container,
        child: MaterialApp.router(
          theme: buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets(
      'Home draws its plan before the questions are ready, then the exact '
      'session line replaces the plain one', (tester) async {
    final f = await _fixture(tester);
    await pumpHome(tester, f);
    await _settle(tester);
    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('Lesson a'), findsOneWidget);
    expect(find.text('Questions due today'), findsOneWidget);
    expect(find.textContaining('sessions of'), findsNothing);

    f.launcher.gate.complete();
    await _settle(tester);
    expect(find.text('6 due · 2 sessions of 5'), findsOneWidget);
    expect(find.text('Questions due today'), findsNothing);
    expect(f.launcher.loads, 1);
  });

  testWidgets('opening New questions early waits for the same preparation',
      (tester) async {
    final f = await _fixture(tester);
    await pumpHome(tester, f);
    await _settle(tester);
    await tester.tap(find.text('New questions'));
    await _settle(tester, 10);
    expect(find.text('Start New Questions'), findsNothing);

    f.launcher.gate.complete();
    await _settle(tester);
    expect(find.text('Start New Questions'), findsOneWidget);
    expect(f.launcher.loads, 1);
  });
}
