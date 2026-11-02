import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/dev/local_onboarding_presets.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

/// A local run hands each step its answers through a seed. The real guard is a
/// compile-time constant that is false here, so these tests open it.
void main() {
  setUp(() => allowLocalPresetSeedForTest(allowed: true));
  tearDown(() {
    allowLocalPresetSeedForTest(allowed: false);
    localPresetSeed.value = null;
  });

  group('age step', () {
    Future<void> pumpAge(WidgetTester tester, {int passed = 0}) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: OnboardingAgeGateStep(
            currentYear: 2026,
            onAgeGatePassed: () {},
          ),
        ),
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a submitted year 2020 shows the blocked screen',
        (tester) async {
      localPresetSeed.value =
          const LocalPresetSeed(birthYearText: '2020', submit: true);
      await pumpAge(tester);
      expect(find.text("Pantas isn't available yet"), findsOneWidget);
      expect(localPresetSeed.value, isNull);
    });

    testWidgets('an unsubmitted year only fills the field', (tester) async {
      localPresetSeed.value = const LocalPresetSeed(birthYearText: '2020');
      await pumpAge(tester);
      expect(find.text('When were you born?'), findsOneWidget);
      final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
      expect(wheel.values[wheel.selectedIndex], '2020');
    });

    testWidgets('without a seed the field keeps its own default',
        (tester) async {
      await pumpAge(tester);
      final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
      expect(wheel.values[wheel.selectedIndex], '2012');
    });
  });

  group('custom exam name step', () {
    testWidgets('shows the seeded text', (tester) async {
      localPresetSeed.value =
          const LocalPresetSeed(customName: 'Nursing Board');
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const CustomTrackNameStep(),
        ),
      );
      await tester.pump();
      expect(find.text('Nursing Board'), findsOneWidget);
      expect(localPresetSeed.value, isNull);
    });

    testWidgets("a submitted name runs the step's own Continue",
        (tester) async {
      localPresetSeed.value =
          const LocalPresetSeed(customName: 'Nursing Board', submit: true);
      final names = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: CustomTrackNameStep(onContinue: names.add),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(names, ['Nursing Board']);
    });

    testWidgets('a submitted name opens the subjects screen on its own',
        (tester) async {
      localPresetSeed.value =
          const LocalPresetSeed(customName: 'Nursing Board', submit: true);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const CustomTrackNameStep(),
          ),
          GoRoute(
            path: '/onboarding/custom/subjects',
            builder: (_, state) =>
                Text('subjects ${state.uri.queryParameters['name']}'),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
      );
      await tester.pumpAndSettle();
      expect(find.text('subjects Nursing Board'), findsOneWidget);
    });

    testWidgets('empty without a seed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const CustomTrackNameStep(),
        ),
      );
      await tester.pump();
      expect(find.text('Nursing Board'), findsNothing);
    });
  });

  group('exam date step', () {
    final today = DateTime(2026, 10, 3);
    final entry = ExamCatalogEntry(
      id: 'exam_cse_pro',
      name: 'Civil Service Exam',
      shortName: 'CSE Professional',
      priceTier: 'Civil Service',
      group: 'Civil service',
      comingSoon: false,
      hasContent: true,
      publishedSittings: [
        PublishedExamSitting(
          firstDay: DateTime(2026, 11, 11),
          lastDay: DateTime(2026, 11, 12),
          sourceUrl: 'https://csc.gov.ph',
        ),
      ],
    );

    Future<DriftSettingsRepository> pumpDate(
      WidgetTester tester, {
      List<ExamCatalogEntry> catalog = const [],
    }) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            examPickerCatalogProvider
                .overrideWith((ref) => Stream.value(catalog)),
          ],
          child: OnboardingExamDateStep(now: today, onCompleted: () {}),
        ),
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      return DriftSettingsRepository(db);
    }

    Future<ExamDate?> continueAndRead(
      WidgetTester tester,
      DriftSettingsRepository repo,
    ) async {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      return (await repo.readUserSettings()).examDate;
    }

    testWidgets('different date opens the picker over a known date',
        (tester) async {
      localPresetSeed.value = const LocalPresetSeed(differentDate: true);
      await pumpDate(tester, catalog: [entry]);
      expect(find.text('Is this your exam day?'), findsNothing);
      expect(
        find.text('Pick the month. Add the day if you know it.'),
        findsOneWidget,
      );
    });

    testWidgets('nothing picked leaves Continue off', (tester) async {
      localPresetSeed.value = const LocalPresetSeed(differentDate: true);
      await pumpDate(tester);
      expect(
        tester
            .widget<PantasButton>(find.widgetWithText(PantasButton, 'Continue'))
            .onPressed,
        isNull,
      );
    });

    for (final (name, seed, expected) in [
      (
        'month December',
        const LocalPresetSeed(differentDate: true, year: 2026, month: 12),
        ExamDate.inMonth(year: 2026, month: 12),
      ),
      (
        'December 15',
        const LocalPresetSeed(
          differentDate: true,
          year: 2026,
          month: 12,
          day: 15,
        ),
        ExamDate.onDay(DateTime(2026, 12, 15)),
      ),
      (
        'February next year',
        const LocalPresetSeed(differentDate: true, year: 2027, month: 2),
        ExamDate.inMonth(year: 2027, month: 2),
      ),
      (
        'this month',
        const LocalPresetSeed(differentDate: true, year: 2026, month: 10),
        ExamDate.inMonth(year: 2026, month: 10),
      ),
      (
        'today',
        const LocalPresetSeed(
          differentDate: true,
          year: 2026,
          month: 10,
          day: 3,
        ),
        ExamDate.onDay(DateTime(2026, 10, 3)),
      ),
    ]) {
      testWidgets('the picker opens on $name', (tester) async {
        localPresetSeed.value = seed;
        final repo = await pumpDate(tester);
        final saved = await continueAndRead(tester, repo);
        expect(saved!.storageValue, expected.storageValue);
        expect(saved.precision, expected.precision);
      });
    }

    testWidgets('without a seed the known date card shows', (tester) async {
      await pumpDate(tester, catalog: [entry]);
      expect(find.text('Is this your exam day?'), findsOneWidget);
    });
  });

  group('study days step', () {
    Future<DriftSettingsRepository> pumpDays(
      WidgetTester tester, {
      required DateTime today,
      DateTime? exam,
    }) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final repo = DriftSettingsRepository(db);
      if (exam != null) {
        await repo.updateExamDate(ExamDate.onDay(exam), today: today);
      }
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: OnboardingStudyDaysStep(now: today, onCompleted: () {}),
        ),
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      return repo;
    }

    bool selected(WidgetTester tester, String day) =>
        tester
            .getSemantics(find.bySemanticsLabel(day))
            .getSemanticsData()
            .flagsCollection
            .isSelected
            .name ==
        'isTrue';

    // Wednesday 14 October 2026, the exam three days later.
    final wednesday = DateTime(2026, 10, 14);
    final friday = DateTime(2026, 10, 17);

    testWidgets('Mon to Sat are picked', (tester) async {
      localPresetSeed.value =
          const LocalPresetSeed(studyDays: {1, 2, 3, 4, 5, 6});
      await pumpDays(tester, today: wednesday);
      for (final day in [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ]) {
        expect(selected(tester, day), isTrue, reason: day);
      }
      expect(selected(tester, 'Sunday'), isFalse);
    });

    testWidgets('Sun to Tue with an exam in 3 days shows the too late card',
        (tester) async {
      localPresetSeed.value = const LocalPresetSeed(studyDays: {7, 1, 2});
      await pumpDays(tester, today: wednesday, exam: friday);
      expect(selected(tester, 'Sunday'), isTrue);
      expect(find.textContaining('Wednesday'), findsWidgets);
      expect(find.text('Pick at least one day to continue.'), findsNothing);
    });

    testWidgets('Wed to Fri with an exam in 3 days is allowed', (tester) async {
      localPresetSeed.value = const LocalPresetSeed(studyDays: {3, 4, 5});
      await pumpDays(tester, today: wednesday, exam: friday);
      expect(selected(tester, 'Wednesday'), isTrue);
      expect(find.textContaining('Your exam is in 3 days'), findsOneWidget);
    });

    testWidgets('no seed leaves every day off', (tester) async {
      await pumpDays(tester, today: wednesday, exam: friday);
      expect(selected(tester, 'Monday'), isFalse);
      expect(find.text('Pick at least one day to continue.'), findsOneWidget);
    });
  });
}
