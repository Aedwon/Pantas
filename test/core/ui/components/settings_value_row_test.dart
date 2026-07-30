import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the visual box is 38 and the tappable box is 44',
      (tester) async {
    await tester.pumpApp(
      SettingsValueRow(title: 'Exam', value: 'UPCAT', onTap: () {}),
    );

    expect(
      tester.getSize(find.byType(SettingsValueRow)).height,
      SettingsValueRow.tapHeight,
    );
    expect(
      tester.getSize(find.byKey(const Key('settingsRowContent'))).height,
      SettingsValueRow.contentHeight,
    );
  });

  testWidgets(
      'a row without a chevron still reserves the chevron column, '
      'so values land on one right edge', (tester) async {
    await tester.pumpApp(
      const Column(
        children: [
          SettingsValueRow(title: 'Name', value: 'Aedwon'),
          SettingsValueRow(title: 'Exam', value: 'UPCAT', showChevron: true),
        ],
      ),
    );

    final withoutChevron = tester.getBottomRight(find.text('Aedwon')).dx;
    final withChevron = tester.getBottomRight(find.text('UPCAT')).dx;

    expect(withoutChevron, withChevron);
  });

  testWidgets('a muted value is inkMuted and an on value is ink',
      (tester) async {
    await tester.pumpApp(
      const Column(
        children: [
          SettingsValueRow(title: 'Strict mock mode', value: 'Off'),
          SettingsValueRow(
            title: 'Remember table order',
            value: 'On',
            valueIsInk: true,
          ),
        ],
      ),
    );

    expect(
      tester.widget<Text>(find.text('Off')).style!.color,
      AppColors.light.inkMuted,
    );
    expect(
      tester.widget<Text>(find.text('On')).style!.color,
      AppColors.light.ink,
    );
  });

  testWidgets('a control replaces the value and the whole row taps it',
      (tester) async {
    var taps = 0;
    await tester.pumpApp(
      SettingsValueRow(
        title: 'Strict mock mode',
        control: const SettingsSwitch(value: false),
        onTap: () => taps++,
      ),
    );

    expect(find.byType(SettingsSwitch), findsOneWidget);

    await tester.tap(find.text('Strict mock mode'));
    expect(taps, 1);
  });

  testWidgets('a row with no onTap does not respond to a tap', (tester) async {
    await tester.pumpApp(
      const SettingsValueRow(title: 'Name', value: 'Aedwon'),
    );

    await tester.tap(find.text('Name'));
    // No exception, and nothing to assert beyond surviving the tap.
    expect(find.byType(SettingsValueRow), findsOneWidget);
  });
}
