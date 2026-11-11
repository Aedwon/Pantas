import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

import '../../../helpers/ds_matrix.dart';

BoxDecoration _fill(WidgetTester tester) => tester
    .widget<AnimatedContainer>(find.byKey(const ValueKey('selectable-tile')))
    .decoration! as BoxDecoration;

BoxDecoration? _ring(WidgetTester tester) => tester
    .widget<AnimatedContainer>(find.byKey(const ValueKey('selectable-tile')))
    .foregroundDecoration as BoxDecoration?;

Widget _tile({bool selected = false, VoidCallback? onTap}) => SizedBox(
      width: 200,
      child: SelectableTile(
        name: 'UPCAT',
        sub: 'University of the Philippines',
        selected: selected,
        onTap: onTap ?? () {},
      ),
    );

void main() {
  dsMatrix(
    'SelectableTile at rest: card fill, 1 control ring, radius 14, 64 high',
    (context) => _tile(),
    check: (tester, cell) async {
      final c = tester.element(find.byType(SelectableTile)).colors;
      expect(_fill(tester).color, c.surfaceCard);
      expect(_fill(tester).borderRadius, BorderRadius.circular(14));
      final border = _ring(tester)!.border! as Border;
      expect(border.top.color, c.borderControl);
      expect(border.top.width, 1);
      expect(
        tester.getSize(find.byKey(const ValueKey('selectable-tile'))).height,
        greaterThanOrEqualTo(64),
      );
      final name = tester.widget<Text>(find.text('UPCAT'));
      expect(name.style!.fontSize, 16);
      expect(name.style!.fontWeight, FontWeight.w600);
      final sub =
          tester.widget<Text>(find.text('University of the Philippines'));
      expect(sub.style!.color, c.textSecondary);
    },
  );

  dsMatrix(
    'selected SelectableTile is accent-tint with a 2 accent ring',
    (context) => _tile(selected: true),
    check: (tester, cell) async {
      final c = tester.element(find.byType(SelectableTile)).colors;
      expect(_fill(tester).color, c.accentTint);
      final border = _ring(tester)!.border! as Border;
      expect(border.top.color, c.accent);
      expect(border.top.width, 2);
      final sub =
          tester.widget<Text>(find.text('University of the Philippines'));
      expect(sub.style!.color, c.textOnTintSecondary);
    },
  );

  dsMatrix(
    'disabled SelectableTile uses fill and text-disabled with no ring',
    (context) => const SizedBox(
      width: 200,
      child: SelectableTile(name: 'DCAT', selected: true, onTap: null),
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(SelectableTile)).colors;
      expect(_fill(tester).color, c.fill);
      expect(_ring(tester), isNull);
      expect(
        tester.widget<Text>(find.text('DCAT')).style!.color,
        c.textDisabled,
      );
    },
  );

  testWidgets('hover shows a 1 text-secondary ring and press scales to 0.98',
      (tester) async {
    await pumpDs(tester, dsCells.first, _tile());
    final c = tester.element(find.byType(SelectableTile)).colors;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(SelectableTile)));
    await tester.pump(const Duration(milliseconds: 200));
    final border = _ring(tester)!.border! as Border;
    expect(border.top.color, c.textSecondary);
    expect(border.top.width, 1);
    await mouse.down(tester.getCenter(find.byType(SelectableTile)));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.98,
    );
    await mouse.up();
  });

  testWidgets('keyboard focus draws an accent outline; selected uses ink',
      (tester) async {
    for (final selected in [false, true]) {
      resetWebKeyboardFocus();
      await pumpDs(tester, dsCells.first, _tile(selected: selected));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final c = tester.element(find.byType(SelectableTile)).colors;
      final ring = tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('selectable-tile-focus')),
          )
          .decoration as BoxDecoration;
      final side = (ring.border! as Border).top;
      expect(side.width, 2);
      expect(side.color, selected ? c.textPrimary : c.accent);
    }
  });

  testWidgets('Space and Enter activate the tile, and it reads as checked',
      (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    resetWebKeyboardFocus();
    await pumpDs(
      tester,
      dsCells.first,
      _tile(selected: true, onTap: () => taps++),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 2);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('selectable-tile')))
          .flagsCollection
          .isChecked,
      isNotNull,
    );
    handle.dispose();
  });

  group('tag slot', () {
    Widget grid() => const SelectableTileGrid(
          children: [
            SelectableTile(
              name: 'Monthly',
              sub: 'Cancel any time',
              tag: '7 Days Free',
              selected: false,
              onTap: _noop,
            ),
            SelectableTile(
              name: 'Yearly',
              sub: 'Best value',
              selected: false,
              onTap: _noop,
            ),
          ],
        );

    dsMatrix(
      'the tag sits on the top edge 16 from the left and titles share a line',
      (context) => SizedBox(width: 380, child: grid()),
      check: (tester, cell) async {
        final tag =
            tester.getRect(find.byKey(const ValueKey('selectable-tile-tag')));
        final tiles = find.byKey(const ValueKey('selectable-tile'));
        final first = tester.getRect(tiles.at(0));
        expect(tag.left, first.left + 16);
        // Centered on the tile's top edge.
        expect(tag.center.dy, closeTo(first.top, 1));
        // Both titles start on one line whatever the text size.
        if (cell.scale == 1) {
          expect(
            tester.getTopLeft(find.text('Monthly')).dy,
            tester.getTopLeft(find.text('Yearly')).dy,
          );
        }
        // The title stays below the tag at any text size.
        expect(
          tester.getTopLeft(find.text('Monthly')).dy,
          greaterThanOrEqualTo(tag.bottom),
        );
      },
    );

    testWidgets('slot height is zero at default text and grows with the tag',
        (tester) async {
      late double normal;
      late double large;
      await pumpDs(
        tester,
        dsCells[0],
        Builder(
          builder: (context) {
            normal = SelectableTile.slotHeight(context);
            return const SizedBox();
          },
        ),
      );
      await pumpDs(
        tester,
        dsCells[2],
        Builder(
          builder: (context) {
            large = SelectableTile.slotHeight(context);
            return const SizedBox();
          },
        ),
      );
      expect(normal, 0);
      expect(large, greaterThan(0));
      expect(PantasTag.heightFor(24), greaterThan(PantasTag.heightFor(12)));
    });
  });

  dsMatrix(
    'the grid drops to one column at large text',
    (context) => const SizedBox(
      width: 390,
      child: SelectableTileGrid(
        children: [
          SelectableTile(name: 'A', selected: false, onTap: _noop),
          SelectableTile(name: 'B', selected: false, onTap: _noop),
          SelectableTile(name: 'C', selected: false, onTap: _noop),
        ],
      ),
    ),
    check: (tester, cell) async {
      final a = tester.getTopLeft(find.text('A'));
      final b = tester.getTopLeft(find.text('B'));
      if (cell.scale > 1) {
        expect(b.dy, greaterThan(a.dy));
        expect(b.dx, a.dx);
      } else {
        expect(b.dy, a.dy);
      }
    },
  );

  dsMatrix(
    'day tiles are at least 44 by 76; selected is accent-fill with on-accent',
    (context) => const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableTile.day(
          weekday: 'Mon',
          name: '1h',
          selected: true,
          onTap: _noop,
        ),
        SizedBox(width: 10),
        SelectableTile.day(
          weekday: 'Tue',
          name: '2h',
          selected: false,
          onTap: _noop,
        ),
      ],
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(Row).first).colors;
      final tiles = find.byKey(const ValueKey('selectable-tile'));
      for (var i = 0; i < 2; i++) {
        final size = tester.getSize(tiles.at(i));
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(76));
      }
      final on = tester.widget<AnimatedContainer>(tiles.at(0)).decoration!
          as BoxDecoration;
      expect(on.color, c.accentFill);
      expect(tester.widget<Text>(find.text('1h')).style!.color, c.onAccent);
      expect(tester.widget<Text>(find.text('1h')).style!.fontSize, 20);
    },
  );
}

void _noop() {}
