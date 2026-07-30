import 'package:pantas/features/settings/domain/user_settings.dart';
import 'package:pantas/features/settings/presentation/sheets/reminder_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('the sheet renders three wheels and a Save button',
      (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showReminderSheet(
            context: context,
            current: const SettingsTime(hour: 20, minute: 0),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Daily reminder'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('saving returns the selected SettingsTime converted to 24-hour',
      (tester) async {
    SettingsTime? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showReminderSheet(
              context: context,
              current: const SettingsTime(hour: 20, minute: 0),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, const SettingsTime(hour: 20, minute: 0));
  });
}
