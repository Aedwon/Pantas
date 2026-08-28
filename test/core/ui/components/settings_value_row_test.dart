import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/core/ui/components/theme_control.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/features/settings/domain/theme_preference.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the visual box is 38 and the tappable box is 48',
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

  testWidgets('a switch row exposes one named toggled node', (tester) async {
    await tester.pumpApp(
      SettingsValueRow(
        title: 'Strict mock mode',
        control: const SettingsSwitch(value: true),
        onTap: () {},
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Strict mock mode')),
      matchesSemantics(
        label: 'Strict mock mode',
        hasToggledState: true,
        isToggled: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('a compound control keeps its actionable child semantics',
      (tester) async {
    ThemePreference? chosen;
    await tester.pumpApp(
      SettingsValueRow(
        title: 'Theme',
        control: ThemeControl(
          value: ThemePreference.system,
          onChanged: (next) => chosen = next,
        ),
      ),
    );

    final light = find.bySemanticsLabel('Light theme');
    final dark = find.bySemanticsLabel('Dark theme');
    final system = find.bySemanticsLabel('Follow my phone');

    expect(light, findsOneWidget);
    expect(dark, findsOneWidget);
    expect(system, findsOneWidget);

    expect(
      tester.getSemantics(light),
      matchesSemantics(
        label: 'Light theme',
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(dark),
      matchesSemantics(
        label: 'Dark theme',
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(system),
      matchesSemantics(
        label: 'Follow my phone',
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(system).flagsCollection.isSelected,
      Tristate.isTrue,
    );

    await tester.tap(dark);
    expect(chosen, ThemePreference.dark);

    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp(r'^Theme$'))),
      matchesSemantics(label: 'Theme'),
    );
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
