import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/local_onboarding_preset_apply.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/dev/local_onboarding_presets.dart';
import 'package:pantas/core/dev/local_panel_bridge.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../helpers/in_memory_database.dart';

const _ids = [
  'welcome',
  'birthYear',
  'terms',
  'picker',
  'dateKnown',
  'days',
  'name',
  'under13',
  'customName',
  'customSubjects',
  'dateNone',
  'dateMonth',
  'dateDay',
  'dateNextYear',
  'dateThisMonth',
  'dateToday',
  'daysNone',
  'daysTooLate',
  'daysSoon',
];

void main() {
  // Wednesday 14 October 2026, the day the panel board was drawn on.
  final now = DateTime(2026, 10, 14);

  group('seed', () {
    tearDown(() {
      allowLocalPresetSeedForTest(allowed: false);
      localPresetSeed.value = null;
    });

    test('a normal build never hands out a seed', () {
      localPresetSeed.value = const LocalPresetSeed(birthYearText: '2020');
      expect(takeSeededBirthYear(() {}), isNull);
      expect(localPresetSeed.value, isNotNull);
    });

    test('a step takes only its own answer and leaves the seed in place', () {
      allowLocalPresetSeedForTest(allowed: true);
      localPresetSeed.value = const LocalPresetSeed(studyDays: {1, 2});
      expect(takeSeededCustomName(() {}), isNull);
      expect(localPresetSeed.value, isNotNull);
      expect(takeSeededStudyDays(), {1, 2});
      // A second step built in the same window still reads the seed.
      expect(localPresetSeed.value, isNotNull);
      expect(takeSeededStudyDays(), {1, 2});
    });

    test('the picked date holds year, month and day', () {
      const seed = LocalPresetSeed(year: 2026, month: 12, day: 15);
      expect(seed.pickedDate!.year, 2026);
      expect(seed.pickedDate!.month, 12);
      expect(seed.pickedDate!.day, 15);
      expect(const LocalPresetSeed().pickedDate, isNull);
    });
  });

  group('applyOnboardingPreset', () {
    late AppDatabase db;
    late GoRouter router;
    late ProviderContainer container;

    GoRouter buildRouter() => GoRouter(
          initialLocation: '/onboarding',
          routes: [
            for (final path in const [
              '/onboarding',
              '/onboarding/custom/name',
            ])
              GoRoute(path: path, builder: (_, __) => const SizedBox()),
          ],
        );

    setUp(() {
      db = inMemoryDatabase();
      router = buildRouter();
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routerProvider.overrideWithValue(router),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(const [])),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      localPresetSeed.value = null;
      await db.close();
    });

    /// The seed the applier held while it ran. It clears the seed itself once
    /// the screen has settled, so the value is read inside that window.
    LocalPresetSeed? seen;

    Future<LocalPresetSeed?> applyAndSee(
      ProviderContainer target,
      String id, {
      DateTime? at,
    }) async {
      LocalPresetSeed? held;
      var done = false;
      final run = applyOnboardingPreset(target, id, now: at ?? now)
          .whenComplete(() => done = true);
      while (!done) {
        held ??= localPresetSeed.value;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await run;
      return held;
    }

    Future<void> apply(WidgetTester tester, String id) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      seen = null;
      await tester.runAsync(() async {
        seen = await applyAndSee(container, id);
        // The applier leaves nothing behind.
        expect(localPresetSeed.value, isNull);
      });
    }

    String where() => router.routerDelegate.currentConfiguration.uri.path;

    testWidgets('knows exactly the 19 panel ids', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.runAsync(() async {
        for (final id in _ids) {
          await applyOnboardingPreset(container, id, now: now);
          expect(localPresetSeed.value, isNot(isA<String>()));
        }
        await applyOnboardingPreset(container, 'nothing', now: now);
      });
      expect(_ids, hasLength(19));
    });

    testWidgets('welcome writes nothing and stays put', (tester) async {
      await apply(tester, 'welcome');
      expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
      expect(where(), '/onboarding');
      expect(localPresetSeed.value, isNull);
    });

    testWidgets('terms passes the age gate only', (tester) async {
      await apply(tester, 'terms');
      final settings = await DriftSettingsRepository(db).readUserSettings();
      expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
      expect(settings.acceptedTermsAt, isNull);
      expect(where(), '/onboarding');
      expect(localPresetSeed.value, isNull);
    });

    testWidgets('picker accepts the policy but picks no exam', (tester) async {
      await apply(tester, 'picker');
      final settings = await DriftSettingsRepository(db).readUserSettings();
      expect(settings.acceptedTermsAt, isNotNull);
      expect(await AppPreferencesRepository(db).selectedExamId(), isNull);
    });

    testWidgets('dateKnown picks CSE Professional and no date', (tester) async {
      await apply(tester, 'dateKnown');
      expect(
        await AppPreferencesRepository(db).selectedExamId(),
        'exam_cse_pro',
      );
      final settings = await DriftSettingsRepository(db).readUserSettings();
      expect(settings.examDate, isNull);
      final progress = (await tester.runAsync(
        () => container.read(onboardingProgressProvider.future),
      ))!;
      expect(progress.resumeStep, OnboardingStep.examDate);
    });

    testWidgets('days answers the date and seeds Mon to Sat', (tester) async {
      await apply(tester, 'days');
      final prefs = AppPreferencesRepository(db);
      expect(await prefs.deviceValue(onboardingDateAnsweredKey), 'true');
      expect(seen!.studyDays, {1, 2, 3, 4, 5, 6});
      final progress = (await tester.runAsync(
        () => container.read(onboardingProgressProvider.future),
      ))!;
      expect(progress.resumeStep, OnboardingStep.studyDays);
    });

    testWidgets('a second step built in the window still reads the seed',
        (tester) async {
      allowLocalPresetSeedForTest(allowed: true);
      addTearDown(() => allowLocalPresetSeedForTest(allowed: false));
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.runAsync(() async {
        var done = false;
        final run = applyOnboardingPreset(container, 'days', now: now)
            .whenComplete(() => done = true);
        Set<int>? first;
        Set<int>? second;
        while (!done) {
          first ??= takeSeededStudyDays();
          if (first != null) second ??= takeSeededStudyDays();
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        await run;
        expect(first, {1, 2, 3, 4, 5, 6});
        expect(second, {1, 2, 3, 4, 5, 6});
        expect(localPresetSeed.value, isNull);
        expect(takeSeededStudyDays(), isNull);
      });
    });

    testWidgets('name saves Mon to Sat through the settings action',
        (tester) async {
      await apply(tester, 'name');
      final settings = await DriftSettingsRepository(db).readUserSettings();
      expect(settings.studyDays.weekdays, {1, 2, 3, 4, 5, 6});
      final progress = (await tester.runAsync(
        () => container.read(onboardingProgressProvider.future),
      ))!;
      expect(progress.resumeStep, OnboardingStep.name);
      expect(localPresetSeed.value, isNull);
    });

    testWidgets('under13 seeds year 2020 to be submitted', (tester) async {
      await apply(tester, 'under13');
      expect(seen!.birthYearText, '2020');
      expect(seen!.submit, isTrue);
      expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
    });

    testWidgets('customName opens the custom name screen with no text',
        (tester) async {
      await apply(tester, 'customName');
      expect(where(), '/onboarding/custom/name');
      expect(localPresetSeed.value, isNull);
    });

    testWidgets('customSubjects seeds the name to be submitted',
        (tester) async {
      await apply(tester, 'customSubjects');
      expect(where(), '/onboarding/custom/name');
      expect(seen!.customName, 'Nursing Board');
      expect(seen!.submit, isTrue);
    });

    for (final (id, differentDate, year, month, day) in [
      ('dateNone', true, null, null, null),
      ('dateMonth', true, 2026, 12, null),
      ('dateDay', true, 2026, 12, 15),
      ('dateNextYear', true, 2027, 2, null),
      ('dateThisMonth', true, 2026, 10, null),
      ('dateToday', true, 2026, 10, 14),
    ]) {
      testWidgets('$id seeds the date picker', (tester) async {
        await apply(tester, id);
        final seed = seen!;
        expect(seed.differentDate, differentDate);
        expect(seed.year, year);
        expect(seed.month, month);
        expect(seed.day, day);
        final progress = (await tester.runAsync(
          () => container.read(onboardingProgressProvider.future),
        ))!;
        expect(progress.resumeStep, OnboardingStep.examDate);
      });
    }

    for (final (id, days) in [
      ('daysNone', null),
      ('daysTooLate', <int>{7, 1, 2}),
      ('daysSoon', <int>{3, 4, 5}),
    ]) {
      testWidgets('$id writes an exam date 3 days out', (tester) async {
        await apply(tester, id);
        final settings = await DriftSettingsRepository(db).readUserSettings();
        expect(settings.examDate!.day, DateTime(2026, 10, 17));
        expect(seen?.studyDays, days);
        final progress = (await tester.runAsync(
          () => container.read(onboardingProgressProvider.future),
        ))!;
        expect(progress.resumeStep, OnboardingStep.studyDays);
      });
    }

    testWidgets('a test clock on another weekday moves the days with it',
        (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      // Monday 2 November 2026.
      final held = await tester.runAsync(
        () => applyAndSee(container, 'daysTooLate', at: DateTime(2026, 11, 2)),
      );
      expect(held!.studyDays, {5, 6, 7});
    });

    testWidgets('gives up when the app never becomes ready', (tester) async {
      final stuck = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routerProvider.overrideWithValue(router),
          onboardingProgressProvider
              .overrideWith((ref) => Completer<OnboardingProgress>().future),
        ],
      );
      addTearDown(stuck.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.runAsync(() async {
        await expectLater(
          applyOnboardingPreset(
            stuck,
            'terms',
            now: now,
            wait: const Duration(milliseconds: 50),
          ),
          throwsA(isA<TimeoutException>()),
        );
      });
      expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
      expect(localPresetSeed.value, isNull);
    });
  });

  test('registering does nothing in a normal build', () {
    applyLocalPreset = null;
    registerLocalOnboardingPresets();
    expect(applyLocalPreset, isNull);
  });
}
