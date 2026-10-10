import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (var selected = 0; selected < 3; selected++) {
      testWidgets('segment $selected metrics and keyboard in $brightness',
          (tester) async {
        var result = selected;
        final widget = SegmentedSwitch(
          labels: const ['Subjects', 'Topics', 'Lessons'],
          selected: selected,
          onChanged: (next) => result = next,
        );
        await pumpAccessibilitySurface(tester, widget, brightness: brightness);
        expect(
          tester
              .getSize(find.byKey(const ValueKey('segmented-switch-track')))
              .height,
          36,
        );
        final active = tester.widget<Text>(
          find.text(['Subjects', 'Topics', 'Lessons'][selected]),
        );
        expect(active.style!.fontSize, 14);
        expect(active.style!.fontWeight, FontWeight.w600);
        expect(active.style!.height, 1.35);
        expect(active.style!.letterSpacing, 0);
        final background = tester
            .widget<DecoratedBox>(find.byKey(ValueKey('segment-$selected')))
            .decoration as BoxDecoration;
        expect(
          background.color,
          brightness == Brightness.light
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF48484A),
        );
        final luminances = [
          active.style!.color!.computeLuminance(),
          background.color!.computeLuminance(),
        ]..sort();
        expect(
          (luminances.last + .05) / (luminances.first + .05),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          tester.getSize(find.byKey(ValueKey('segment-$selected'))).height,
          32,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(result, 0);
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
}
