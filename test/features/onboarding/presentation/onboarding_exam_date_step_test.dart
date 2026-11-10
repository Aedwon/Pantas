import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';
import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  final today = DateTime(2026, 10, 3);
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'month then optional day, unknown and today $brightness $scale',
          (tester) async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final prefs = AppPreferencesRepository(db);
        await prefs.setSelectedExamId('exam_cse_pro');
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            examPickerCatalogProvider
                .overrideWith((ref) => Stream.value(const [])),
          ],
        );
        addTearDown(container.dispose);
        await pumpAccessibilitySurface(
          tester,
          UncontrolledProviderScope(
            container: container,
            child: OnboardingExamDateStep(
              now: today,
              onCompleted: () {},
              onBack: () {},
            ),
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        await tester.pumpAndSettle();
        // The phone step has no subtitle: the labeled field says it.
        expect(
          find.text('Pick the month. Add the day if you know it.'),
          findsNothing,
        );
        expect(find.text('Exam date'), findsOneWidget);
        // No month is chosen yet: the calendar shows this month, and Continue
        // waits. Going to next month and back chooses this month alone.
        expect(find.text('October 2026'), findsOneWidget);
        expect(find.textContaining('No day yet?'), findsNothing);
        await tester.ensureVisible(find.byTooltip('Next month'));
        await tester.tap(find.byTooltip('Next month'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Previous month'));
        await tester.pumpAndSettle();
        expect(
          find.text("No day yet? We'll plan from today and ask later."),
          findsOneWidget,
        );
        await tester.ensureVisible(find.byKey(const ValueKey('date-day-3')));
        await tester.tap(find.byKey(const ValueKey('date-day-3')));
        await tester.pumpAndSettle();
        expect(find.text('Saturday, October 3 · today'), findsNothing);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '10/03/2026',
        );
        expect(find.textContaining('what matters most'), findsNothing);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(
          (await DriftSettingsRepository(db).readUserSettings()).examDate!.day,
          today,
        );
        expect(await prefs.deviceValue(onboardingDateAnsweredKey), 'true');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  testWidgets('a month alone saves as a month and shows the plan line',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        examPickerCatalogProvider.overrideWith((ref) => Stream.value(const [])),
      ],
    );
    addTearDown(container.dispose);
    await pumpAccessibilitySurface(
      tester,
      UncontrolledProviderScope(
        container: container,
        child: OnboardingExamDateStep(now: today, onCompleted: () {}),
      ),
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Next month'));
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(
      find.text("No day yet? We'll plan from 1 November and ask later."),
      findsOneWidget,
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      (await DriftSettingsRepository(db).readUserSettings()).examDate,
      ExamDate.inMonth(year: 2026, month: 11),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'published multi-day sitting uses its first day and can be declined',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
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
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value([entry])),
        ],
        child: OnboardingExamDateStep(now: today, onCompleted: () {}),
      ),
      disableAnimations: true,
    );
    await tester.pumpAndSettle();
    expect(find.text('Is this your exam day?'), findsOneWidget);
    expect(find.text('39 days from today'), findsOneWidget);
    await tester.tap(find.text('Different Date'));
    await tester.pumpAndSettle();
    expect(find.byType(MonthFirstDatePicker), findsOneWidget);
    await tester.tap(find.text("I don't know"));
    await tester.pumpAndSettle();
    expect(
      (await DriftSettingsRepository(db).readUserSettings()).examDate,
      isNull,
    );
    expect(
      await AppPreferencesRepository(db).deviceValue(onboardingDateAnsweredKey),
      'true',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a sitting tomorrow reads "1 day from today"', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
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
          firstDay: DateTime(2026, 10, 4),
          lastDay: DateTime(2026, 10, 4),
          sourceUrl: 'https://csc.gov.ph',
        ),
      ],
    );
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value([entry])),
        ],
        child: OnboardingExamDateStep(now: today, onCompleted: () {}),
      ),
      disableAnimations: true,
    );
    await tester.pumpAndSettle();
    expect(find.text('1 day from today'), findsOneWidget);
    expect(find.text('1 days from today'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final wide in [false, true]) {
    testWidgets(
        'a published sitting names its day month first, wide web or phone, '
        'wide=$wide', (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
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
            firstDay: DateTime(2027, 3, 14),
            lastDay: DateTime(2027, 3, 14),
            sourceUrl: 'https://csc.gov.ph',
          ),
        ],
      );
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            examPickerCatalogProvider
                .overrideWith((ref) => Stream.value([entry])),
          ],
          child: OnboardingExamDateStep(now: today, onCompleted: () {}),
        ),
        disableAnimations: true,
        viewportSize: wide ? const Size(1440, 900) : const Size(390, 844),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sunday, March 14,\u00A02027'), findsOneWidget);
      expect(find.text('Sunday, 14 March 2027'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('the phone step draws no day line under the grid',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(const [])),
        ],
        child: OnboardingExamDateStep(now: today, onCompleted: () {}),
      ),
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Next month'));
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.textContaining('days from today'), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('date-day-11')));
    await tester.tap(find.byKey(const ValueKey('date-day-11')));
    await tester.pumpAndSettle();
    expect(find.textContaining('days from today'), findsNothing);
    expect(find.textContaining('Wednesday'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '11/11/2026',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the step opens with the calendar and the field is a toggle',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(const [])),
        ],
        child: OnboardingExamDateStep(now: today, onCompleted: () {}),
      ),
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('date-day-3')), findsOneWidget);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('date-day-3')), findsNothing);
    await tester.tap(find.byTooltip('Choose a date'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('date-day-3')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a past or half-typed date holds Continue; Not sure turns it on',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(const [])),
        ],
        child: OnboardingExamDateStep(now: today, onCompleted: () {}),
      ),
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    final continueButton = find.widgetWithText(OnboardingButton, 'Continue');
    bool continueOn() =>
        tester.widget<OnboardingButton>(continueButton).onPressed != null;
    expect(continueOn(), isFalse);
    await tester.ensureVisible(find.byKey(const ValueKey('date-day-20')));
    await tester.tap(find.byKey(const ValueKey('date-day-20')));
    await tester.pumpAndSettle();
    expect(continueOn(), isTrue);
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '10012026');
    await tester.pumpAndSettle();
    expect(find.text('Pick a date from October 3, 2026.'), findsOneWidget);
    expect(continueOn(), isFalse);
    await tester.tap(find.byTooltip('Choose a date'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Not sure of the day'));
    await tester.tap(find.text('Not sure of the day'));
    await tester.pumpAndSettle();
    expect(
      find.text("No day yet? We'll plan from today and ask later."),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(continueOn(), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a published sitting today says "today", not "0 days"',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
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
          firstDay: today,
          lastDay: today,
          sourceUrl: 'https://csc.gov.ph',
        ),
      ],
    );
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value([entry])),
        ],
        child: OnboardingExamDateStep(now: today, onCompleted: () {}),
      ),
      disableAnimations: true,
    );
    await tester.pumpAndSettle();
    expect(find.text('today'), findsOneWidget);
    expect(find.text('0 days from today'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  for (final width in [393.0, 720.0]) {
    testWidgets('the caption starts at the title edge at $width',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await AppPreferencesRepository(db).setSelectedExamId('exam_cse_pro');
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
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            examPickerCatalogProvider
                .overrideWith((ref) => Stream.value([entry])),
          ],
          child: OnboardingExamDateStep(now: today, onCompleted: () {}),
        ),
        viewportSize: Size(width, 844),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      final title = tester.getTopLeft(find.text('When is your exam?')).dx;
      final caption = tester.getTopLeft(find.text('Is this your exam day?')).dx;
      expect(caption, title);
    });
  }
}
