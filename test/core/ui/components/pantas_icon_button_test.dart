import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/ds_matrix.dart';

PantasColors _colors(DsCell cell) =>
    cell.dark ? PantasColors.dark : PantasColors.light;

ButtonStyle _style(WidgetTester tester, [int index = 0]) =>
    tester.widget<IconButton>(find.byType(IconButton).at(index)).style!;

void main() {
  dsMatrix(
    'three sizes with the radius rule, 20 and 18 px icons',
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in PantasIconButtonSize.values)
          PantasIconButton(
            tooltip: 'Close ${s.name}',
            glyph: PantasIcons.close,
            size: s,
            onPressed: () {},
          ),
      ],
    ),
    check: (tester, cell) async {
      final wide = cell.width >= 1024;
      final sizes = [44.0, 40.0, 32.0];
      final radii = [12.0, 12.0, 8.0];
      final icons = [20.0, 20.0, 18.0];
      for (var i = 0; i < 3; i++) {
        final button = find.byType(IconButton).at(i);
        expect(tester.getSize(button), Size.square(sizes[i]));
        final shape = _style(tester, i).shape!.resolve({})!;
        expect(
          (shape as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(radii[i]),
          reason: 'radius of size $i',
        );
        expect(
          tester
              .widget<Icon>(
                find.descendant(of: button, matching: find.byType(Icon)),
              )
              .size,
          icons[i],
        );
      }
      // The 32 px button reaches 44 on a touched layout (the phone) and stays
      // 32 where a pointer drives.
      final small = tester.getSize(find.byType(PantasIconButton).at(2));
      expect(small, wide ? const Size.square(32) : const Size.square(44));
      // The highlight is a rounded rectangle, never a circle.
      expect(_style(tester).shape!.resolve({}), isNot(isA<CircleBorder>()));
      expect(_style(tester).shape!.resolve({}), isNot(isA<StadiumBorder>()));
      // Colors: text-secondary at rest, text-primary under hover.
      final c = _colors(cell);
      expect(_style(tester).foregroundColor!.resolve({}), c.textSecondary);
      expect(
        _style(tester).foregroundColor!.resolve({WidgetState.hovered}),
        c.textPrimary,
      );
      expect(
        _style(tester).backgroundColor!.resolve({WidgetState.hovered}),
        c.textPrimary.withValues(alpha: .08),
      );
    },
  );

  dsMatrix(
    'accent, toggled and disabled colors',
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PantasIconButton(
          tooltip: 'Teal',
          glyph: PantasIcons.search,
          accent: true,
          onPressed: () {},
        ),
        PantasIconButton(
          tooltip: 'Flag off',
          glyph: PantasIcons.flag,
          toggled: false,
          onPressed: () {},
        ),
        PantasIconButton(
          tooltip: 'Flag on',
          glyph: PantasIcons.flag,
          toggled: true,
          onPressed: () {},
        ),
        PantasIconButton(
          tooltip: 'Off',
          glyph: PantasIcons.close,
          onPressed: null,
        ),
      ],
    ),
    check: (tester, cell) async {
      final c = _colors(cell);
      Color fg(int i, [Set<WidgetState> s = const {}]) =>
          _style(tester, i).foregroundColor!.resolve(s)!;
      expect(fg(0), c.accent);
      expect(fg(0, {WidgetState.hovered}), c.accentHover);
      expect(fg(1), c.textSecondary);
      expect(fg(2), c.accent);
      expect(fg(2, {WidgetState.hovered}), c.accentHover);
      expect(fg(3, {WidgetState.disabled}), c.textDisabled);
      // No hover wash on a disabled button.
      expect(
        _style(tester, 3).backgroundColor!.resolve({WidgetState.disabled}),
        Colors.transparent,
      );
      // The toggle changes the glyph too, so color is never the only cue.
      IconData glyph(int i) => tester
          .widget<Icon>(
            find.descendant(
              of: find.byType(IconButton).at(i),
              matching: find.byType(Icon),
            ),
          )
          .icon!;
      expect(glyph(1), PantasIcons.flag);
      expect(glyph(1).fontFamily, 'Phosphor');
      expect(glyph(2).fontFamily, 'PhosphorFill');
      expect(glyph(2).codePoint, PantasIcons.flag.codePoint);
      // A toggle is announced as pressed or not; a plain button is not.
      bool? toggled(int i) => tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(PantasIconButton).at(i),
              matching: find.byType(Semantics),
            ),
          )
          .map((w) => w.properties.toggled)
          .firstWhere((t) => t != null, orElse: () => null);
      expect(toggled(0), isNull);
      expect(toggled(1), isFalse);
      expect(toggled(2), isTrue);
    },
  );

  testWidgets('press scales to 0.97 and a disabled button holds still',
      (tester) async {
    await pumpDs(
      tester,
      dsCells[4],
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PantasIconButton(
            tooltip: 'Menu',
            glyph: PantasIcons.contents,
            onPressed: () {},
          ),
          PantasIconButton(
            tooltip: 'Off',
            glyph: PantasIcons.close,
            onPressed: null,
          ),
        ],
      ),
    );
    double scale(int i) => tester
        .widget<Transform>(
          find
              .descendant(
                of: find.byType(PressScale).at(i),
                matching: find.byType(Transform),
              )
              .first,
        )
        .transform
        .entry(0, 0);
    final press = await tester.startGesture(
      tester.getCenter(find.byType(IconButton).first),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(scale(0), closeTo(.97, .001));
    await press.up();
    final off = await tester.startGesture(
      tester.getCenter(find.byType(IconButton).last),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(scale(1), 1);
    await off.up();
    await tester.pumpAndSettle();
  });

  testWidgets('keyboard focus rings the button 2 px outside, Enter activates',
      (tester) async {
    resetWebKeyboardFocus();
    var calls = 0;
    await pumpDs(
      tester,
      dsCells[4],
      PantasIconButton(
        tooltip: 'Menu',
        glyph: PantasIcons.contents,
        onPressed: () => calls++,
      ),
    );
    expect(find.byKey(const ValueKey('focus-ring')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final ring = find.byKey(const ValueKey('focus-ring'));
    expect(ring, findsOneWidget);
    expect(
      tester.getRect(ring),
      tester.getRect(find.byType(IconButton)).inflate(4),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(calls, 1);
  });

  testWidgets('hover washes the hovered icon color as a rounded rectangle',
      (tester) async {
    await pumpDs(
      tester,
      dsCells[4],
      PantasIconButton(
        tooltip: 'Menu',
        glyph: PantasIcons.contents,
        onPressed: () {},
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(IconButton)));
    await tester.pumpAndSettle();
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(IconButton),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(
      material.color,
      PantasColors.light.textPrimary.withValues(alpha: .08),
    );
  });

  dsMatrix(
    'a top bar button is a 44 px icon button',
    (context) => WebTopBarButton(
      tooltip: 'Leave',
      icon: const Icon(Icons.close),
      onPressed: () {},
    ),
    check: (tester, cell) async {
      expect(tester.getSize(find.byType(IconButton)), const Size.square(44));
      expect(find.byType(PantasIconButton), findsOneWidget);
    },
  );
}
