import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/dev/local_onboarding_presets.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart' show loadDsFonts;
import '../../../helpers/in_memory_database.dart';

void main() {
  // A day tile is as wide as its weekday label, so the test needs the real
  // face.
  setUpAll(loadDsFonts);
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'empty days, Sunday first, select and persist $brightness $scale',
          (tester) async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        var complete = false;
        await pumpAccessibilitySurface(
          tester,
          ProviderScope(
            overrides: [appDatabaseProvider.overrideWithValue(db)],
            child: OnboardingStudyDaysStep(
              now: DateTime(2026, 10, 3),
              onCompleted: () => complete = true,
            ),
          ),
          brightness: brightness,
          textScale: scale,
          disableAnimations: true,
          viewportSize: const Size(390, 844),
        );
        await tester.pumpAndSettle();
        expect(find.text('Which days will you study?'), findsOneWidget);
        expect(find.text('Pick at least one day to continue.'), findsOneWidget);
        expect(find.bySemanticsLabel('Sunday'), findsOneWidget);
        await tester.ensureVisible(find.byKey(const ValueKey('study-day-7')));
        await tester.tap(find.byKey(const ValueKey('study-day-7')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(
          (await DriftSettingsRepository(db).readUserSettings())
              .studyDays
              .weekdays,
          {7},
        );
        expect(complete, isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  testWidgets('wide: the hint is flush with the title, as the board has it',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: OnboardingStudyDaysStep(
          now: DateTime(2026, 10, 3),
          onCompleted: () {},
        ),
      ),
      disableAnimations: true,
      viewportSize: const Size(1440, 900),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Pick at least one day to continue.')).dx,
      tester.getTopLeft(find.text('Which days will you study?')).dx,
    );
  });
  for (final width in [320.0, 340.0, 360.0, 390.0]) {
    testWidgets('the seven days stay on one row at $width', (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: OnboardingStudyDaysStep(
            now: DateTime(2026, 10, 3),
            onCompleted: () {},
          ),
        ),
        disableAnimations: true,
        viewportSize: Size(width, 844),
      );
      await tester.pumpAndSettle();
      final tops = {
        for (var day = 1; day <= 7; day++)
          tester.getTopLeft(find.byKey(ValueKey('study-day-$day'))).dy,
      };
      expect(tops, hasLength(1), reason: 'one row at $width');
      // Under 360 the row is narrower than seven 44 tiles and their 4 gaps,
      // so it scrolls sideways (SelectableTile, D190) instead of shrinking.
      final scrolls = width < 360;
      for (var day = 1; day <= 7; day++) {
        final box = tester.getRect(find.byKey(ValueKey('study-day-$day')));
        expect(box.left, greaterThanOrEqualTo(0));
        if (!scrolls) expect(box.right, lessThanOrEqualTo(width));
        expect(box.width, greaterThanOrEqualTo(44));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('at 320 a late selected day is scrolled into view',
      (tester) async {
    allowLocalPresetSeedForTest(allowed: true);
    addTearDown(() {
      allowLocalPresetSeedForTest(allowed: false);
      localPresetSeed.value = null;
    });
    localPresetSeed.value = const LocalPresetSeed(studyDays: {6});
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: OnboardingStudyDaysStep(
          now: DateTime(2026, 10, 3),
          onCompleted: () {},
        ),
      ),
      disableAnimations: true,
      viewportSize: const Size(320, 844),
    );
    await tester.pumpAndSettle();
    final saturday = tester.getRect(find.byKey(const ValueKey('study-day-6')));
    expect(saturday.left, greaterThanOrEqualTo(0));
    expect(saturday.right, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no selected day before exam blocks Continue; today permits one',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);
    final today = DateTime(2026, 10, 3);
    await repo.updateExamDate(
      ExamDate.onDay(DateTime(2026, 10, 4)),
      today: today,
    );
    Future<void> pump() async {
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: OnboardingStudyDaysStep(now: today, onCompleted: () {}),
        ),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
    }

    await pump();
    await tester.tap(find.byKey(const ValueKey('study-day-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Saturday'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('study-day-6')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect((await repo.readUserSettings()).studyDays.weekdays, {1, 6});
    await tester.pumpWidget(const SizedBox.shrink());
  });
  // 6U-4: the days are saved the moment Continue is pressed, not at Done, so
  // a reload on the Name step resumes at Name with the days kept.
  testWidgets('Continue saves the days, so a reload resumes at Name',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final prefs = AppPreferencesRepository(db);
    final repo = DriftSettingsRepository(db);
    await prefs.setPassedAgeGate(value: true);
    await repo.recordPolicyAcceptance();
    await prefs.setSelectedExamId('cse');
    await prefs.setDeviceValue(onboardingDateAnsweredKey, 'true');
    final today = DateTime(2026, 10, 3);
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: OnboardingStudyDaysStep(now: today, onCompleted: () {}),
      ),
      disableAnimations: true,
    );
    await tester.pumpAndSettle();
    for (final day in [1, 2, 3, 4, 5]) {
      await tester.tap(find.byKey(ValueKey('study-day-$day')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());

    // A reload: a new app on the same stored data.
    final reloaded = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(reloaded.dispose);
    final progress = await reloaded.read(onboardingProgressProvider.future);
    expect(progress.resumeStep, OnboardingStep.name);
    expect((await repo.readUserSettings()).studyDays.weekdays, {1, 2, 3, 4, 5});
  });
  testWidgets('returning restores explicitly saved study days', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await DriftSettingsRepository(db).updateStudyDays(StudyDays(const [2, 4]));
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: OnboardingStudyDaysStep(onCompleted: () {}),
      ),
      disableAnimations: true,
    );
    await tester.pumpAndSettle();
    expect(
      tester
              .getSemantics(find.bySemanticsLabel('Tuesday'))
              .getSemanticsData()
              .flagsCollection
              .isSelected ==
          Tristate.isTrue,
      isTrue,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('calm line in the Days card (O_Days)', () {
    final today = DateTime(2026, 10, 3);
    const calm = "We'll focus on what matters most.";
    const usual = 'Days off stay free. '
        'Questions that come due on a day off wait for your next study day.';

    Future<void> pumpWith(
      WidgetTester tester, {
      required int day,
      ExamDate? examDate,
    }) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      if (examDate != null) {
        await DriftSettingsRepository(db).updateExamDate(
          examDate,
          today: today,
        );
      }
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: OnboardingStudyDaysStep(now: today, onCompleted: () {}),
        ),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('study-day-$day')));
      await tester.pumpAndSettle();
    }

    testWidgets('under a week with a valid day shows the real day count',
        (tester) async {
      await pumpWith(
        tester,
        examDate: ExamDate.onDay(DateTime(2026, 10, 6)),
        day: 7,
      );
      expect(find.text('Your exam is in 3 days. $calm'), findsOneWidget);
      expect(find.text(usual), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('one day away reads "1 day"', (tester) async {
      await pumpWith(
        tester,
        examDate: ExamDate.onDay(DateTime(2026, 10, 4)),
        day: 6,
      );
      expect(find.text('Your exam is in 1 day. $calm'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a week or more away keeps the usual line', (tester) async {
      await pumpWith(
        tester,
        examDate: ExamDate.onDay(DateTime(2026, 10, 10)),
        day: 7,
      );
      expect(find.text(usual), findsOneWidget);
      expect(find.textContaining('what matters most'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a month-only date shows no count', (tester) async {
      await pumpWith(
        tester,
        examDate: ExamDate.inMonth(year: 2026, month: 10),
        day: 7,
      );
      expect(find.text(usual), findsOneWidget);
      expect(find.textContaining('Your exam is in'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('exam today and no date show no count', (tester) async {
      await pumpWith(
        tester,
        examDate: ExamDate.onDay(today),
        day: 7,
      );
      expect(find.text(usual), findsOneWidget);
      expect(find.textContaining('Your exam is in'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpWith(tester, day: 7);
      expect(find.text(usual), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('no day before the exam keeps the board warning, not the line',
        (tester) async {
      await pumpWith(
        tester,
        examDate: ExamDate.onDay(DateTime(2026, 10, 4)),
        day: 1,
      );
      expect(find.text('None of these fall before your exam'), findsOneWidget);
      expect(find.textContaining('what matters most'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
