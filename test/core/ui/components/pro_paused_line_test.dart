import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('paused line matches body style with no action in $brightness',
        (tester) async {
      const widget = ProPausedLine();
      await pumpAccessibilitySurface(
        tester,
        widget,
        brightness: brightness,
        disableAnimations: true,
      );
      final text =
          tester.widget<Text>(find.text('Connect once to keep using Pro.'));
      expect(text.style!.fontFamily, 'Geist');
      expect(text.style!.fontSize, 17);
      expect(text.style!.fontWeight, FontWeight.w400);
      expect(text.style!.height, 1.35);
      expect(text.style!.letterSpacing, -.204);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      final background = brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF1F1F1F);
      final luminances = [
        text.style!.color!.computeLuminance(),
        background.computeLuminance(),
      ]..sort();
      expect(
        (luminances.last + .05) / (luminances.first + .05),
        greaterThanOrEqualTo(4.5),
      );
      await expectSurvivesTextScale(
        tester,
        widget,
        viewportSize: const Size(390, 844),
        brightness: brightness,
        disableAnimations: true,
      );
    });
  }
}
