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
