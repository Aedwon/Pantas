import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'horizontal wheel follows QZE_Short metrics and keyboard $brightness',
        (tester) async {
      var selected = 1;
      var changes = 0;
      final wheel = StatefulBuilder(
        builder: (context, setState) => ValueWheel.horizontal(
          values: const ['5', '10', '15', '20', '25'],
          selectedIndex: selected,
          invalidIndices: const {4},
          label: 'Questions',
          onSelected: (v) => setState(() {
            selected = v;
            changes++;
          }),
        ),
      );
      await pumpAccessibilitySurface(
        tester,
        wheel,
        brightness: brightness,
        viewportSize: const Size(390, 844),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('wheel-cell-1'))).width,
        56,
      );
      final picked = tester.widget<Text>(find.text('10'));
      expect(picked.style!.fontSize, 19);
      expect(picked.style!.fontWeight, FontWeight.w700);
      final other = tester.widget<Text>(find.text('15'));
      expect(other.style!.fontSize, 16);
      expect(other.style!.fontWeight, FontWeight.w500);
      expect(
        tester.widget<Text>(find.text('25')).style!.decoration,
        TextDecoration.lineThrough,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selected, 2);
      expect(changes, 1);
      await tester.timedDrag(
        find.byType(ListView),
        const Offset(-56, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(selected, 3);
      expect(changes, 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selected, 3);
      expect(changes, 2);

      await expectSurvivesTextScale(
        tester,
        wheel,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      expect(
        tester.getCenter(find.byKey(ValueKey('wheel-cell-$selected'))).dx,
        closeTo(195, .1),
      );
    });
  }
}
