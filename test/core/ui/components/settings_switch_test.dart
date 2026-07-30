import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';

import '../../../helpers/pump_app.dart';

BoxDecoration _decorationAt(WidgetTester tester, int index) {
  final boxes = tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .toList(growable: false);
  return boxes[index].decoration as BoxDecoration;
}

void main() {
  testWidgets('the switch is 32 by 18 in both states', (tester) async {
    await tester.pumpApp(const SettingsSwitch(value: false));
    expect(
      tester.getSize(find.byType(SettingsSwitch)),
      const Size(SettingsSwitch.width, SettingsSwitch.height),
    );

    await tester.pumpApp(const SettingsSwitch(value: true));
    expect(
      tester.getSize(find.byType(SettingsSwitch)),
      const Size(SettingsSwitch.width, SettingsSwitch.height),
    );
  });

  testWidgets('off is entirely hollow: no fill on the box or the knob',
      (tester) async {
    await tester.pumpApp(const SettingsSwitch(value: false));

    final box = _decorationAt(tester, 0);
    final knob = _decorationAt(tester, 1);

    expect(box.color, isNull);
    expect(knob.color, isNull);
    expect(box.border!.top.color, AppColors.light.rule);
    expect(knob.border!.top.color, AppColors.light.rule);
  });

  testWidgets('on is entirely solid: box filled ink, knob filled background',
      (tester) async {
    await tester.pumpApp(const SettingsSwitch(value: true));

    final box = _decorationAt(tester, 0);
    final knob = _decorationAt(tester, 1);

    expect(box.color, AppColors.light.ink);
    expect(box.border!.top.color, AppColors.light.ink);
    expect(knob.color, AppColors.light.background);
    expect(knob.border, isNull);
  });

  testWidgets('the knob sits left when off and right when on', (tester) async {
    await tester.pumpApp(const SettingsSwitch(value: false));
    final offAlign = tester.widget<Align>(find.byType(Align));
    expect(offAlign.alignment, Alignment.centerLeft);

    await tester.pumpApp(const SettingsSwitch(value: true));
    final onAlign = tester.widget<Align>(find.byType(Align));
    expect(onAlign.alignment, Alignment.centerRight);
  });
}
