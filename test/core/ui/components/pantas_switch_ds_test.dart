import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

import '../../../helpers/ds_matrix.dart';

Color _track(WidgetTester tester) => (tester
        .widget<DecoratedBox>(find.byKey(const ValueKey('pantas-switch-track')))
        .decoration as BoxDecoration)
    .color!;

BoxDecoration _trackDecoration(WidgetTester tester) => tester
    .widget<DecoratedBox>(find.byKey(const ValueKey('pantas-switch-track')))
    .decoration as BoxDecoration;

void main() {
  dsMatrix(
    'Switch off: switch-off track with a 1.5 border-control ring',
    (context) =>
        PantasSwitch(value: false, label: 'Reminders', onChanged: (_) {}),
    check: (tester, cell) async {
      final c = tester.element(find.byType(PantasSwitch)).colors;
      expect(
        tester.getSize(find.byKey(const ValueKey('pantas-switch-track'))),
        const Size(51, 31),
      );
      final deco = _trackDecoration(tester);
      expect(deco.color, c.switchOff);
      final border = deco.border! as Border;
      expect(border.top.color, c.borderControl);
      expect(border.top.width, 1.5);
      expect(tester.getSize(find.byType(PantasSwitch)).height, 44);
      final knob = tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('pantas-switch-knob')),
          )
          .decoration as BoxDecoration;
      expect(knob.color, c.switchThumb);
      expect(knob.boxShadow, hasLength(1));
      expect(knob.boxShadow!.first.blurRadius, 4);
    },
  );

  dsMatrix(
    'Switch on: accent-fill track, no ring, thumb 20 to the right',
    (context) =>
        PantasSwitch(value: true, label: 'Reminders', onChanged: (_) {}),
    check: (tester, cell) async {
      final c = tester.element(find.byType(PantasSwitch)).colors;
      final deco = _trackDecoration(tester);
      expect(deco.color, c.accentFill);
      expect(deco.border, isNull);
      final track =
          tester.getTopLeft(find.byKey(const ValueKey('pantas-switch-track')));
      final knob =
          tester.getTopLeft(find.byKey(const ValueKey('pantas-switch-knob')));
      expect(knob - track, const Offset(22, 2));
    },
  );

  dsMatrix(
    'Switch disabled uses opacity-disabled and ignores taps',
    (context) =>
        const PantasSwitch(value: false, label: 'Reminders', onChanged: null),
    check: (tester, cell) async {
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(PantasSwitch),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.4);
      await tester.tap(find.byType(PantasSwitch));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
      'hover darkens the track: off divider-strong, on accent-fill-hover',
      (tester) async {
    for (final on in [false, true]) {
      await pumpDs(
        tester,
        dsCells[4],
        PantasSwitch(value: on, label: 'Reminders', onChanged: (_) {}),
      );
      final c = tester.element(find.byType(PantasSwitch)).colors;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(PantasSwitch)));
      await tester.pumpAndSettle();
      expect(_track(tester), on ? c.accentFillHover : c.dividerStrong);
      await mouse.removePointer();
    }
  });

  testWidgets('press shrinks the thumb to 96 percent', (tester) async {
    await pumpDs(
      tester,
      dsCells[0],
      PantasSwitch(value: false, label: 'Reminders', onChanged: (_) {}),
    );
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(PantasSwitch)));
    await tester.pump(const Duration(milliseconds: 100));
    final scale = tester.widget<Transform>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('pantas-switch-knob')),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(scale.transform.storage[0], closeTo(0.96, 0.001));
    await gesture.up();
  });

  testWidgets(
      'keyboard focus draws a 2 accent ring; Space toggles, Enter does not',
      (tester) async {
    resetWebKeyboardFocus();
    var value = false;
    await pumpDs(
      tester,
      dsCells[4],
      StatefulBuilder(
        builder: (context, setState) => PantasSwitch(
          value: value,
          label: 'Reminders',
          onChanged: (next) => setState(() => value = next),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final c = tester.element(find.byType(PantasSwitch)).colors;
    final ring = tester
        .widget<DecoratedBox>(find.byKey(const ValueKey('pantas-switch-focus')))
        .decoration as BoxDecoration;
    final side = (ring.border! as Border).top;
    expect(side.width, 2);
    expect(side.color, c.accent);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets(
      'reduced motion keeps the thumb in place and fades the track 150ms',
      (tester) async {
    var value = false;
    late StateSetter change;
    await pumpDs(
      tester,
      dsCells[0],
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: StatefulBuilder(
            builder: (context, setState) {
              change = setState;
              return PantasSwitch(value: value, label: 'R', onChanged: (_) {});
            },
          ),
        ),
      ),
    );
    final c = tester.element(find.byType(PantasSwitch)).colors;
    change(() => value = true);
    await tester.pump();
    final track =
        tester.getTopLeft(find.byKey(const ValueKey('pantas-switch-track')));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('pantas-switch-knob'))).dx -
          track.dx,
      22,
    );
    await tester.pump(const Duration(milliseconds: 160));
    expect(_track(tester), c.accentFill);
  });
}
