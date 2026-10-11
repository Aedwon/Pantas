import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final value in [false, true]) {
      testWidgets('switch $value metrics and keyboard in $brightness',
          (tester) async {
        var result = value;
        final widget = PantasSwitch(
          value: value,
          label: 'Daily reminder',
          onChanged: (next) => result = next,
        );
        await pumpAccessibilitySurface(tester, widget, brightness: brightness);
        final track = find.byKey(const ValueKey('pantas-switch-track'));
        expect(tester.getSize(track), const Size(51, 31));
        final knob = find.byKey(const ValueKey('pantas-switch-knob'));
        expect(tester.getSize(knob), const Size(27, 27));
        expect(
          tester.getTopLeft(knob) - tester.getTopLeft(track),
          Offset(value ? 22 : 2, 2),
        );
        final decoration =
            tester.widget<DecoratedBox>(knob).decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFFFFFFF));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        expect(result, !value);
        await expectSurvivesTextScale(
          tester,
          widget,
          brightness: brightness,
          disableAnimations: true,
        );
      });
    }
    testWidgets('switch reaches the board overshoot at 175ms in $brightness',
        (tester) async {
      var value = false;
      late StateSetter change;
      await pumpAccessibilitySurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            change = setState;
            return PantasSwitch(
              value: value,
              label: 'Reminder',
              onChanged: (_) {},
            );
          },
        ),
        brightness: brightness,
      );
      change(() => value = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 175));
      final track =
          tester.getTopLeft(find.byKey(const ValueKey('pantas-switch-track')));
      final knob =
          tester.getTopLeft(find.byKey(const ValueKey('pantas-switch-knob')));
      // CSS cubic-bezier(.34,1.56,.64,1) at t=.5 is 1.0874.
      expect(knob.dx - track.dx, closeTo(23.748, .03));
      await tester.pump(const Duration(milliseconds: 175));
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('pantas-switch-knob'))).dx -
            track.dx,
        22,
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
    testWidgets('switch track fades for 250ms in $brightness', (tester) async {
      var value = false;
      late StateSetter change;
      await pumpAccessibilitySurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            change = setState;
            return PantasSwitch(
              value: value,
              label: 'Reminder',
              onChanged: (_) {},
            );
          },
        ),
        brightness: brightness,
      );
      change(() => value = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));
      final box = tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('pantas-switch-track')),
          )
          .decoration as BoxDecoration;
      // CSS ease at .5 is .8024. Literal channels rounded to the nearest byte.
      final expected = brightness == Brightness.light
          ? const Color(0xFF368F81)
          : const Color(0xFF248877);
      expect(box.color!.r, closeTo(expected.r, .005));
      expect(box.color!.g, closeTo(expected.g, .005));
      expect(box.color!.b, closeTo(expected.b, .005));
    });
  }
}
