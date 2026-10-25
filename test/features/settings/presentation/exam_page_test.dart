import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
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
          examDate: null,
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
    expect(find.text('You pick up where you are'), findsOneWidget);
  });

  testWidgets('a switch with no overlap confirms the kept date and study days',
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
      find.text(
        'Kept from UPCAT. Change it if DOST falls on a different day.',
      ),
      findsOneWidget,
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
}
