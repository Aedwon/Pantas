import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
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
        expect(
          find.text('Pick the month. Add the day if you know it.'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.byKey(const ValueKey('date-month-10')));
        await tester.tap(find.byKey(const ValueKey('date-month-10')));
        await tester.pumpAndSettle();
        expect(
          find.text("No day yet? We'll plan from today and ask later."),
          findsOneWidget,
        );
        await tester.ensureVisible(find.byKey(const ValueKey('date-day-3')));
        await tester.tap(find.byKey(const ValueKey('date-day-3')));
        await tester.pumpAndSettle();
        // No board draws a calm line on the date step. It is in the Days card.
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
}
