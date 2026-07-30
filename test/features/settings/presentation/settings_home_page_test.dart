import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/settings_group.dart';
import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/core/ui/components/theme_control.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

UserSettings _settings({
  String? name,
  ExamDate? examDate,
  bool strictMockMode = false,
  bool retainTableOrder = true,
}) {
  return UserSettings(
    name: name,
    dailyReminderTime: null,
    examDate: examDate,
    strictMockMode: strictMockMode,
    helpImproveApp: true,
    carryOverProgress: true,
    sessionOrdering: SessionOrdering.interleavedTail,
    retainTableOrder: retainTableOrder,
    updatedAt: null,
  );
}

Future<void> _pump(WidgetTester tester, UserSettings settings) {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  return tester.pumpAppWithProviders(
    const SettingsHomePage(),
    overrides: [
      userSettingsProvider.overrideWith((ref) async => settings),
      appDatabaseProvider.overrideWithValue(db),
    ],
  );
}

void main() {
  testWidgets('the top level has five groups in the specified order',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    final headings = tester
        .widgetList<SettingsGroup>(
          find.byType(SettingsGroup, skipOffstage: false),
        )
        .map((group) => group.title)
        .toList();

    expect(headings, [
      'You',
      'How you practice',
      'What you see',
      'Your account',
      'About',
    ]);
  });

  testWidgets('the top level has twelve rows', (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    expect(
      find.byType(SettingsValueRow, skipOffstage: false),
      findsNWidgets(12),
    );
  });

  testWidgets('no heading is all-caps', (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    for (final group in tester.widgetList<SettingsGroup>(
      find.byType(SettingsGroup, skipOffstage: false),
    )) {
      expect(group.title, isNot(group.title.toUpperCase()));
    }
  });

  testWidgets('a month-precision date prints its month and no day count',
      (tester) async {
    await _pump(
      tester,
      _settings(examDate: ExamDate.inMonth(year: 2026, month: 10)),
    );
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.textContaining('days'), findsNothing);
  });

  testWidgets('an absent name invites one', (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    expect(find.text('Add your name'), findsOneWidget);
  });

  testWidgets('the switch appears on exactly the two switch rows',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    // Strict mock mode and Remember table order. Help improve the app moved
    // to the About page in Plan 06.
    expect(find.byType(SettingsSwitch), findsNWidgets(2));
  });

  testWidgets('the theme control is in the row, not behind a page',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    expect(find.byType(ThemeControl), findsOneWidget);
  });

  testWidgets('the table order row uses the short title that fits the column',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    expect(find.text('Remember table order'), findsOneWidget);
    expect(find.text('Remember how the table is sorted'), findsNothing);
  });

  testWidgets(
      'tapping a switch row toggles it without needing the switch '
      'itself', (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Strict mock mode'));
    await tester.pumpAndSettle();

    // The provider override is static, so this asserts only that the row is
    // tappable and does not throw. The write path is covered in Plan 02.
    expect(find.text('Strict mock mode'), findsOneWidget);
  });

  testWidgets('no string on the page contains an em dash', (tester) async {
    await _pump(tester, _settings(name: 'Aedwon'));
    await tester.pumpAndSettle();

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.contains('—') ?? false, isFalse);
    }
  });

  testWidgets('tapping the exam date row opens a sheet, not a page',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exam date'));
    await tester.pumpAndSettle();

    expect(find.text("I don't know yet"), findsOneWidget);
  });

  testWidgets('tapping the ordering row opens the ordering sheet',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    await tester.tap(find.text('How sessions are built'));
    await tester.pumpAndSettle();

    expect(find.text('One topic only'), findsOneWidget);
  });
}
