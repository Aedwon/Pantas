import 'package:cse_cet_reviewer/features/settings/presentation/widgets/ios_switch.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/widgets/settings_row.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/widgets/settings_section.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/widgets/theme_segmented_control.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('settings row renders title subtitle and chevron',
      (tester) async {
    await tester.pumpApp(
      SettingsRow(
        title: 'Backup',
        subtitle: 'Your progress is saved',
        onTap: () {},
      ),
    );

    expect(find.text('Backup'), findsOneWidget);
    expect(find.text('Your progress is saved'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('settings row invokes tap callback', (tester) async {
    var tapped = false;
    await tester
        .pumpApp(SettingsRow(title: 'Account', onTap: () => tapped = true));

    await tester.tap(find.text('Account'));

    expect(tapped, isTrue);
  });

  testWidgets('ios switch calls changed callback', (tester) async {
    bool? value;
    await tester.pumpApp(
      IosSettingsSwitch(value: false, onChanged: (next) => value = next),
    );

    await tester.tap(find.byType(IosSettingsSwitch));

    expect(value, isTrue);
  });

  testWidgets('theme segmented control shows modes and calls selection',
      (tester) async {
    ThemePreference? selected;
    await tester.pumpApp(
      ThemeSegmentedControl(
        value: ThemePreference.system,
        onChanged: (value) => selected = value,
      ),
    );

    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    expect(selected, ThemePreference.dark);
  });

  testWidgets('section renders sentence-case header and children',
      (tester) async {
    await tester.pumpApp(
      const SettingsSection(
        title: 'Preferences',
        children: [Text('Theme')],
      ),
    );

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
  });
}
