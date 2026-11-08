import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

import '../../../helpers/ds_matrix.dart';

BoxDecoration _mark(WidgetTester tester) => tester
    .widget<Container>(find.byKey(const ValueKey('selection-mark')))
    .decoration! as BoxDecoration;

void main() {
  for (final radio in [false, true]) {
    final name = radio ? 'Radio' : 'Checkbox';
    Widget row({
      bool selected = false,
      bool mixed = false,
      bool enabled = true,
    }) =>
        SizedBox(
          width: 380,
          child: radio
              ? RadioRow(
                  title: 'Share usage data',
                  selected: selected,
                  onTap: enabled ? () {} : null,
                )
              : CheckboxRow(
                  title: 'Share usage data',
                  selected: selected,
                  mixed: mixed,
                  onTap: enabled ? () {} : null,
                ),
        );

    dsMatrix(
      '$name unchecked: 24 mark, 1.5 border-control ring, 44 row',
      (context) => row(),
      check: (tester, cell) async {
        final c = tester.element(find.byType(TextButton)).colors;
        expect(
          tester.getSize(find.byKey(const ValueKey('selection-mark'))),
          const Size(24, 24),
        );
        final deco = _mark(tester);
        expect(deco.color, isNull);
        expect(deco.borderRadius, BorderRadius.circular(radio ? 9999 : 8));
        final border = deco.border! as Border;
        expect(border.top.color, c.borderControl);
        expect(border.top.width, 1.5);
        expect(
          tester.getSize(find.byType(TextButton)).height,
          greaterThanOrEqualTo(44),
        );
        final label = tester.widget<Text>(find.text('Share usage data'));
        expect(label.style!.fontSize, 16);
        expect(label.style!.color, c.textPrimary);
      },
    );

    dsMatrix(
      '$name checked: accent-fill, no ring, a 14 on-accent check',
      (context) => row(selected: true),
      check: (tester, cell) async {
        final c = tester.element(find.byType(TextButton)).colors;
        final deco = _mark(tester);
        expect(deco.color, c.accentFill);
        expect(deco.border, isNull);
        expect(
          tester.getSize(
            find.descendant(
              of: find.byKey(const ValueKey('selection-mark')),
              matching: find.byType(CustomPaint),
            ),
          ),
          const Size(14, 14),
        );
      },
    );

    dsMatrix(
      '$name disabled uses opacity-disabled and gives no hover',
      (context) => row(enabled: false),
      check: (tester, cell) async {
        final opacity = tester.widget<Opacity>(
          find
              .descendant(
                of: find.byType(TextButton),
                matching: find.byType(Opacity),
              )
              .first,
        );
        expect(opacity.opacity, 0.4);
        final button = tester.widget<TextButton>(find.byType(TextButton));
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('$name hover turns a checked mark accent-fill-hover',
        (tester) async {
      await pumpDs(tester, dsCells[4], row(selected: true));
      final c = tester.element(find.byType(TextButton)).colors;
      expect(_mark(tester).color, c.accentFill);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(
        location: tester.getCenter(find.byType(TextButton)),
      );
      addTearDown(mouse.removePointer);
      await tester.pump();
      expect(_mark(tester).color, c.accentFillHover);
    });

    testWidgets('$name keyboard focus draws the 2 accent ring', (tester) async {
      resetWebKeyboardFocus();
      await pumpDs(tester, dsCells[4], row());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final c = tester.element(find.byType(TextButton)).colors;
      final button = tester.widget<TextButton>(find.byType(TextButton));
      final side = button.style!.side!.resolve({WidgetState.focused})!;
      expect(side.width, 2);
      expect(side.color, c.accent);
    });
  }

  dsMatrix(
    'Checkbox mixed draws the dash on accent-fill',
    (context) => SizedBox(
      width: 380,
      child: CheckboxRow(
        title: 'Math',
        selected: false,
        mixed: true,
        onTap: () {},
      ),
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(TextButton)).colors;
      expect(_mark(tester).color, c.accentFill);
    },
  );

  testWidgets(
      'the check pops in over 420ms on motion-enter, still when reduced',
      (tester) async {
    var selected = false;
    late StateSetter change;
    await pumpDs(
      tester,
      dsCells[0],
      StatefulBuilder(
        builder: (context, setState) {
          change = setState;
          return CheckboxRow(title: 'A', selected: selected, onTap: () {});
        },
      ),
    );
    change(() => selected = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 210));
    final scale = tester
        .widget<Transform>(find.byKey(const ValueKey('selection-scale')))
        .transform
        .storage[0];
    expect(scale, inExclusiveRange(0.4, 1.1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('selection-scale')))
          .transform
          .storage[0],
      1,
    );
  });
}
