import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  final upcat = buildExam(
    id: 'exam_upcat',
    code: 'UPCAT',
    shortName: 'UPCAT',
    name: 'UP College Admissions Test',
  );
  final dost = buildExam(
    id: 'exam_dost',
    code: 'DOST',
    shortName: 'DOST',
    name: 'DOST Scholarship Exam',
  );

  List<Override> createOverrides({
    Exam? activeExam,
    bool carryOverProgress = true,
    ExamDate? examDate,
  }) {
    final exam = activeExam ?? upcat;
    final db = inMemoryDatabase();
    addTearDown(db.close);
    return [
      appDatabaseProvider.overrideWithValue(db),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(exam),
      ),
      examPickerCatalogProvider.overrideWith(
        (ref) => Stream.value([
          for (final exam in [upcat, dost])
            ExamCatalogEntry(
              id: exam.id,
              name: exam.name,
              shortName: exam.shortName,
              priceTier: 'Student',
              group: 'College entrance',
              comingSoon: false,
              publishedSittings: const [],
              hasContent: true,
            ),
        ]),
      ),
      examListProvider.overrideWith(
        (ref) async => [upcat, dost],
      ),
      userSettingsProvider.overrideWith(
        (ref) async => UserSettings(
          name: 'Student',
          dailyReminderTime: null,
          studyDays: StudyDays.all,
          examDate: examDate,
          strictMockMode: false,
          helpImproveApp: true,
          carryOverProgress: carryOverProgress,
          sessionOrdering: SessionOrdering.interleavedTail,
          retainTableOrder: true,
          updatedAt: null,
        ),
      ),
    ];
  }

  testWidgets('Count Them saves the choice before leaving the transfer screen',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        settingsCarryOverRoute(),
        GoRoute(path: '/settings/exam', builder: (_, __) => const ExamPage()),
        GoRoute(
          path: '/settings/exam/change',
          builder: (_, __) => const ChangeExamPage(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(carryOverProgress: false),
        carryableCountProvider.overrideWith((ref, id) async => 3),
      ],
    );
    await tester.pumpAndSettle();
    final container =
        ProviderScope.containerOf(tester.element(find.byType(ExamPage)));
    final repository = container.read(settingsRepositoryProvider);
    await repository.updateCarryOverProgress(enabled: false);
    await tester.tap(find.text('Exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Count Them'));
    await tester.tap(find.text('Count Them'));
    await tester.pumpAndSettle();
    expect((await repository.readUserSettings()).carryOverProgress, isTrue);
    expect(find.text("You're now studying for DOST"), findsOneWidget);
  });

  testWidgets('Start My Numbers Fresh never claims work carried over',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        settingsCarryOverRoute(),
        GoRoute(path: '/settings/exam', builder: (_, __) => const ExamPage()),
        GoRoute(
          path: '/settings/exam/change',
          builder: (_, __) => const ChangeExamPage(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(carryOverProgress: false),
        carryableCountProvider.overrideWith((ref, id) async => 3),
      ],
    );
    await tester.pumpAndSettle();
    final container =
        ProviderScope.containerOf(tester.element(find.byType(ExamPage)));
    final repository = container.read(settingsRepositoryProvider);
    await repository.updateCarryOverProgress(enabled: false);
    await tester.tap(find.text('Exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Start My Numbers Fresh'));
    await tester.tap(find.text('Start My Numbers Fresh'));
    await tester.pumpAndSettle();
    expect((await repository.readUserSettings()).carryOverProgress, isFalse);
    expect(find.text("You're now studying for DOST"), findsOneWidget);
    expect(
      find.textContaining("Everything you've done came with you"),
      findsNothing,
    );
  });

  testWidgets(
      'a switch with no overlap does not claim carried work or an unset date',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        settingsCarryOverRoute(),
        GoRoute(path: '/settings/exam', builder: (_, __) => const ExamPage()),
        GoRoute(
          path: '/settings/exam/change',
          builder: (_, __) => const ChangeExamPage(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(),
        carryableCountProvider.overrideWith((ref, id) async => 0),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pumpAndSettle();
    expect(find.text("You're now studying for DOST"), findsOneWidget);
    expect(
      find.byKey(const ValueKey('exam-confirmation-arrival')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Kept from UPCAT. Change it if DOST falls on a different day.',
      ),
      findsNothing,
    );
    expect(
      find.textContaining("Everything you've done came with you"),
      findsNothing,
    );
    expect(find.text('Count Them'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Study days'), findsOneWidget);
    expect(find.text("You're now studying for DOST"), findsNothing);
  });

  testWidgets('the exam page has the active exam and four setting rows',
      (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<ListRow>(
            find.byWidgetPredicate(
              (w) => w is ListRow && w.title == 'Exam',
              skipOffstage: false,
            ),
          )
          .value,
      'UPCAT',
    );
    expect(find.byType(ListRow), findsNWidgets(4));
    expect(find.text('Exam'), findsOneWidget);
    expect(find.text('Carry over progress'), findsOneWidget);
    expect(find.text("What's included"), findsOneWidget);
  });

  testWidgets('at 320 the study day circles scroll instead of running off',
      (tester) async {
    tester.view
      ..physicalSize = const Size(320, 800)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final saturday = find.byKey(const ValueKey('study-day-6'));
    await tester.ensureVisible(saturday);
    await tester.pumpAndSettle();
    final rect = tester.getRect(saturday);
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(320));
  });

  testWidgets('at 200% the exam date chip is as tall as its text',
      (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          textScaler: TextScaler.linear(2),
        ),
        child: UncontrolledProviderScope(
          container: ProviderContainer(
            overrides: createOverrides(
              examDate: ExamDate.onDay(DateTime(2027, 3, 14)),
            ),
          ),
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const ExamPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final text = find.text('Mar 14, 2027');
    await tester.ensureVisible(text);
    final chip = find
        .ancestor(
          of: text,
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration! as BoxDecoration).color != null,
          ),
        )
        .first;
    // The value line is 17 px at 1.35 line height, doubled: 45.9 px. A chip
    // fixed at 34 cut it.
    expect(tester.getSize(chip).height, greaterThanOrEqualTo(45.9));
  });

  testWidgets('carry over is a switch, on by default', (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PantasSwitch), findsOneWidget);
    expect(
      tester.widget<PantasSwitch>(find.byType(PantasSwitch)).value,
      isTrue,
    );
  });

  testWidgets("What's included says All subjects when nothing is left out",
      (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.text('All subjects'), findsOneWidget);
    expect(find.text('Some topics left out'), findsNothing);
  });

  testWidgets("What's included says Some topics left out for a topic",
      (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: [
        ...createOverrides(),
        trackScopeProvider.overrideWith(
          (ref, examId) async => {'topic_algebra'},
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Some topics left out'), findsOneWidget);
    expect(find.text('All subjects'), findsNothing);
  });

  testWidgets("What's included says Some topics left out for a lesson",
      (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: [
        ...createOverrides(),
        lessonScopeProvider.overrideWith(
          (ref, examId) async => {'lesson_fractions'},
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Some topics left out'), findsOneWidget);
    expect(find.text('All subjects'), findsNothing);
  });

  testWidgets('the lede states the rule that surprises people', (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Answers from your other exams count toward this one. '
        'Nothing is ever deleted.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the word migrate never appears', (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.toLowerCase().contains('migrat') ?? false, isFalse);
    }
  });

  testWidgets(
      'exam change presents carry-over once after returning to the Exam page',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        settingsCarryOverRoute(),
        GoRoute(
          path: '/settings/exam',
          builder: (_, __) => const ExamPage(),
        ),
        GoRoute(
          path: '/settings/exam/change',
          builder: (_, __) => const ChangeExamPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(),
        carryableCountProvider.overrideWith((ref, examId) async {
          expect(examId, dost.id);
          return 3;
        }),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exam'));
    await tester.pumpAndSettle();
    expect(find.byType(ChangeExamPage), findsOneWidget);

    await tester.tap(find.text('DOST'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangeExamPage), findsNothing);
    expect(find.text("You're not starting from zero"), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text("You're not starting from zero"), findsOneWidget);
  });

  testWidgets(
      'carry-over waits for the change-exam reverse transition to finish',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        settingsCarryOverRoute(),
        GoRoute(
          path: '/settings/exam',
          builder: (_, __) => const ExamPage(),
        ),
        GoRoute(
          path: '/settings/exam/change',
          pageBuilder: (_, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            child: const ChangeExamPage(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(),
        carryableCountProvider.overrideWith((ref, examId) async {
          expect(examId, dost.id);
          return 3;
        }),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ChangeExamPage), findsOneWidget);
    expect(find.text("You're not starting from zero"), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(ChangeExamPage), findsNothing);
    expect(find.text("You're not starting from zero"), findsOneWidget);
  });

  testWidgets(
      'exam focus stays stable until the change-exam transition is finished',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setSelectedExamId(upcat.id);

    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        settingsCarryOverRoute(),
        GoRoute(
          path: '/settings/exam',
          builder: (_, __) => const ExamPage(),
        ),
        GoRoute(
          path: '/settings/exam/change',
          pageBuilder: (_, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            child: const ChangeExamPage(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        examPickerCatalogProvider.overrideWith(
          (ref) => Stream.value([
            for (final exam in [upcat, dost])
              ExamCatalogEntry(
                id: exam.id,
                name: exam.name,
                shortName: exam.shortName,
                priceTier: 'Student',
                group: 'College entrance',
                comingSoon: false,
                publishedSittings: const [],
                hasContent: true,
              ),
          ]),
        ),
        examListProvider.overrideWith((ref) async => [upcat, dost]),
        userSettingsProvider.overrideWith(
          (ref) async => const UserSettings(
            name: 'Student',
            dailyReminderTime: null,
            studyDays: StudyDays.all,
            examDate: null,
            strictMockMode: false,
            helpImproveApp: true,
            carryOverProgress: true,
            sessionOrdering: SessionOrdering.interleavedTail,
            retainTableOrder: true,
            updatedAt: null,
          ),
        ),
        carryableCountProvider.overrideWith((ref, examId) async {
          expect(examId, dost.id);
          return 3;
        }),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<ListRow>(
            find.byWidgetPredicate(
              (w) => w is ListRow && w.title == 'Exam',
              skipOffstage: false,
            ),
          )
          .value,
      'UPCAT',
    );

    await tester.tap(find.text('Exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pump();

    var routeRemoved = false;
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      final changeExamMounted =
          find.byType(ChangeExamPage).evaluate().isNotEmpty;

      if (changeExamMounted) {
        expect(
          tester
              .widget<ListRow>(
                find.byWidgetPredicate(
                  (w) => w is ListRow && w.title == 'Exam',
                  skipOffstage: false,
                ),
              )
              .value,
          'UPCAT',
          reason: 'active exam changed while Change exam was still mounted',
        );
        expect(find.text("You're not starting from zero"), findsNothing);
        continue;
      }

      routeRemoved = true;
      // This is the first frame with the popped route absent. The refresh is
      // scheduled only after route.completed resolves, so this settled Exam
      // frame must still render the old focus rather than resurrecting the
      // outgoing route or changing underneath it.
      expect(
        tester
            .widget<ListRow>(
              find.byWidgetPredicate(
                (w) => w is ListRow && w.title == 'Exam',
                skipOffstage: false,
              ),
            )
            .value,
        'UPCAT',
      );
      expect(find.text("You're not starting from zero"), findsNothing);
      break;
    }

    expect(routeRemoved, isTrue, reason: 'Change exam route never completed');

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(ChangeExamPage), findsNothing);
    expect(
      tester
          .widget<ListRow>(
            find.byWidgetPredicate(
              (w) => w is ListRow && w.title == 'Exam',
              skipOffstage: false,
            ),
          )
          .value,
      'DOST',
    );
    expect(find.text("You're not starting from zero"), findsOneWidget);
  });

  testWidgets(
      'change exam hands carry-over back instead of presenting from its route',
      (tester) async {
    Object? changeResult;
    final router = GoRouter(
      initialLocation: '/settings/exam',
      routes: [
        settingsCarryOverRoute(),
        GoRoute(
          path: '/settings/exam',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () async {
                changeResult =
                    await context.push<Object?>('/settings/exam/change');
              },
              child: const Text('Open change exam'),
            ),
          ),
        ),
        GoRoute(
          path: '/settings/exam/change',
          builder: (_, __) => const ChangeExamPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        ...createOverrides(),
        carryableCountProvider.overrideWith((ref, examId) async {
          expect(examId, dost.id);
          return 3;
        }),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open change exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DOST'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangeExamPage), findsNothing);
    expect(find.text("You're not starting from zero"), findsNothing);
    expect(changeResult, isNotNull);
  });

  testWidgets('showCarryOverPrompt skips prompt when carryable count is 0',
      (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    final result = await showCarryOverPrompt(
      context: tester.element(find.byType(ExamPage)),
      examShortName: 'DOST',
      carryableCount: 0,
    );
    expect(result, isNull);
  });

  group('change exam on wide web', () {
    Future<GoRouter> pumpWide(
      WidgetTester tester, {
      bool still = false,
    }) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/settings/exam',
        routes: [
          settingsCarryOverRoute(),
          GoRoute(
            path: '/settings/exam',
            builder: (_, __) => const Scaffold(body: Text('Exam page')),
          ),
          GoRoute(
            path: '/settings/exam/change',
            builder: (_, __) => const ChangeExamPage(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...createOverrides(),
            carryableCountProvider.overrideWith((ref, examId) async => 3),
          ],
          child: MaterialApp.router(
            theme: buildLightTheme(web: true),
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: still),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      unawaited(router.push<Object?>('/settings/exam/change'));
      await tester.pumpAndSettle();
      expect(find.byType(ChangeExamPage), findsOneWidget);
      return router;
    }

    double dialogFade(WidgetTester tester) {
      var value = 1.0;
      for (final element in find
          .ancestor(
            of: find.byType(Dialog),
            matching: find.byType(Opacity),
          )
          .evaluate()) {
        value *= (element.widget as Opacity).opacity;
      }
      return value;
    }

    // The route stays on the stack until the dialog has gone.
    bool onChangePage(GoRouter router) => router.canPop();

    testWidgets('a scrim tap fades the dialog before the route pops',
        (tester) async {
      final router = await pumpWide(tester);
      expect(dialogFade(tester), 1);
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(onChangePage(router), isTrue);
      expect(find.byType(ChangeExamPage), findsOneWidget);
      expect(dialogFade(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(onChangePage(router), isFalse);
      expect(find.byType(ChangeExamPage), findsNothing);
    });

    testWidgets('system Back plays the same exit, once', (tester) async {
      final router = await pumpWide(tester);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(onChangePage(router), isTrue);
      expect(dialogFade(tester), inExclusiveRange(0, 1));
      await navigator.maybePop();
      await tester.pumpAndSettle();
      expect(onChangePage(router), isFalse);
      expect(find.byType(ChangeExamPage), findsNothing);
    });

    testWidgets('picking an exam fades the dialog, then pops with the result',
        (tester) async {
      final router = await pumpWide(tester);
      await tester.tap(find.text('DOST').first);
      var sawExit = false;
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (find.byType(ChangeExamPage).evaluate().isNotEmpty &&
            onChangePage(router)) {
          final fade = dialogFade(tester);
          if (fade > 0 && fade < 1) sawExit = true;
        }
      }
      expect(sawExit, isTrue);
      await tester.pumpAndSettle();
      expect(find.byType(ChangeExamPage), findsNothing);
    });

    testWidgets('reduced motion pops at once', (tester) async {
      final router = await pumpWide(tester, still: true);
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      expect(onChangePage(router), isFalse);
    });
  });
  group('the carry-over prompt on wide web', () {
    Future<GoRouter> pumpTransfer(
      WidgetTester tester, {
      bool still = true,
    }) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/settings/exam',
        routes: [
          settingsCarryOverRoute(),
          GoRoute(
            path: '/settings/exam',
            builder: (_, __) => const Scaffold(body: Text('Exam page')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: createOverrides(),
          child: MaterialApp.router(
            theme: buildLightTheme(web: true),
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: still),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      unawaited(
        router.push<bool>(
          '/settings/exam/transfer',
          extra: CarryOverRequest(
            exam: 'DOST',
            previous: 'UPCAT',
            count: 3,
            onCounted: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('the scrim and card cover the whole window', (tester) async {
      await pumpTransfer(tester);
      expect(find.text("You're not starting from zero"), findsOneWidget);
      final barrier = tester.getRect(find.byType(WebOverlayLayer));
      expect(barrier, const Rect.fromLTWH(0, 0, 1440, 900));
      final card = tester.getRect(find.byType(Dialog));
      expect(card.center.dx, closeTo(720, 1));
    });

    testWidgets('Start My Numbers Fresh fades the dialog, then leaves',
        (tester) async {
      final router = await pumpTransfer(tester, still: false);
      await tester.tap(find.text('Start My Numbers Fresh'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.canPop(), isTrue);
      await tester.pumpAndSettle();
      expect(router.canPop(), isFalse);
      expect(find.text("You're not starting from zero"), findsNothing);
    });
  });
}
