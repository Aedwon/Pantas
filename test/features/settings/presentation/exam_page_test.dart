import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/carry_over_prompt.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/exam_page.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  final upcat = buildExam(
    code: 'UPCAT',
    shortName: 'UPCAT',
    name: 'UP College Admissions Test',
  );
  final dost = buildExam(
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
      examListProvider.overrideWith(
        (ref) async => [upcat, dost],
      ),
      userSettingsProvider.overrideWith(
        (ref) async => UserSettings(
          name: 'Student',
          dailyReminderTime: null,
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

  testWidgets('the heading is the exam name and there are three rows',
      (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<SettingsGroup>(find.byType(SettingsGroup)).title,
      'UPCAT',
    );
    expect(find.byType(SettingsValueRow), findsNWidgets(3));
    expect(find.text('Change exam'), findsOneWidget);
    expect(find.text('Carry over progress'), findsOneWidget);
    expect(find.text("What's included"), findsOneWidget);
  });

  testWidgets('carry over is a switch, on by default', (tester) async {
    await tester.pumpAppWithProviders(
      const ExamPage(),
      overrides: createOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsSwitch), findsOneWidget);
    expect(
      tester.widget<SettingsSwitch>(find.byType(SettingsSwitch)).value,
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
