import 'dart:ui' show Tristate;

import 'package:pantas/core/ui/components/theme_control.dart';
import 'package:pantas/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the control is 90 by 22, three segments of 30', (tester) async {
    await tester.pumpApp(
      ThemeControl(value: ThemePreference.system, onChanged: (_) {}),
    );

    expect(
      tester.getSize(find.byType(ThemeControl)),
      const Size(ThemeControl.segmentWidth * 3, ThemeControl.height),
    );
  });

  testWidgets(
      'every segment carries a semantics label, since the marks '
      'carry no text', (tester) async {
    await tester.pumpApp(
      ThemeControl(value: ThemePreference.system, onChanged: (_) {}),
    );

    expect(find.bySemanticsLabel('Light theme'), findsOneWidget);
    expect(find.bySemanticsLabel('Dark theme'), findsOneWidget);
    expect(find.bySemanticsLabel('Follow my phone'), findsOneWidget);
  });

  testWidgets('tapping a segment reports that preference', (tester) async {
    ThemePreference? chosen;
    await tester.pumpApp(
      ThemeControl(
        value: ThemePreference.system,
        onChanged: (next) => chosen = next,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Dark theme'));

    expect(chosen, ThemePreference.dark);
  });

  testWidgets('the live segment is the only one that reports as selected',
      (tester) async {
    await tester.pumpApp(
      ThemeControl(value: ThemePreference.dark, onChanged: (_) {}),
    );

    final dark = tester.getSemantics(find.bySemanticsLabel('Dark theme'));
    final light = tester.getSemantics(find.bySemanticsLabel('Light theme'));

    expect(dark.flagsCollection.isSelected, Tristate.isTrue);
    expect(light.flagsCollection.isSelected, isNot(Tristate.isTrue));
  });
}
