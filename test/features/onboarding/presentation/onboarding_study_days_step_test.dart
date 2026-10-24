import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
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
}
