import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_tooltip.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

import '../../../helpers/ds_matrix.dart';

Widget _anchor() => Padding(
      padding: const EdgeInsets.only(top: 200),
      child: _bare(),
    );

Widget _bare() => PantasTooltip(
      message: 'Flag',
      shortcut: 'F',
      anchorHeight: 48,
      child: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.flag),
      ),
    );

void main() {
  tearDown(resetWebKeyboardFocus);

  // The tests run as android, which is touch, unless a platform is given.
  Widget on(TargetPlatform platform, Widget child) => Builder(
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(platform: platform),
          child: child,
        ),
      );

  dsMatrix(
    'Tooltip anchor fits every width, theme and text scale',
    (context) => on(TargetPlatform.macOS, _anchor()),
    check: (tester, cell) async {
      expect(find.text('Flag (F)'), findsNothing);
    },
  );

  for (final cell in [dsCells[0], dsCells[1], dsCells[6]]) {
    testWidgets(
        'Tooltip shows after 500ms of hover and matches the recipe '
        '($cell)', (tester) async {
      await pumpDs(tester, cell, on(TargetPlatform.macOS, _anchor()));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(IconButton)));
      await tester.pump(PantasDurations.tooltip ~/ 2);
      expect(find.text('Flag (F)'), findsNothing);
      await tester.pump(PantasDurations.tooltip);
      await tester.pump(PantasDurations.short2);
      expect(find.text('Flag (F)'), findsOneWidget);
      final colors = cell.dark ? PantasColors.dark : PantasColors.light;
      final shadows = cell.dark ? PantasShadow.dark : PantasShadow.light;
      final text = tester.widget<Text>(find.text('Flag (F)'));
      expect(text.style!.color, colors.toastText);
      expect(text.style!.fontSize, PantasType.webCaption.fontSize);
      final box = tester
          .widgetList<Container>(
            find.ancestor(
              of: find.text('Flag (F)'),
              matching: find.byType(Container),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .first;
      expect(box.color, colors.toastBg);
      expect(box.borderRadius, BorderRadius.circular(PantasRadius.sm));
      expect(box.boxShadow, shadows.toast);
      expect(
        tester.getSize(find.text('Flag (F)')).width,
        lessThanOrEqualTo(PantasSize.tooltipMax),
      );
      // Above the anchor, 8 away.
      final anchor = tester.getRect(find.byType(IconButton));
      final tip = tester.getRect(
        find
            .ancestor(
              of: find.text('Flag (F)'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(tip.bottom, lessThanOrEqualTo(anchor.top));
      expect(anchor.top - tip.bottom, closeTo(8, .01));
      await mouse.moveTo(const Offset(5, 500));
      await tester.pump(PantasDurations.short2 * 4);
    });
  }

  testWidgets('Keyboard focus shows it at once and Esc hides it',
      (tester) async {
    await pumpDs(tester, dsCells.first, on(TargetPlatform.macOS, _anchor()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.pump(PantasDurations.short2);
    expect(find.text('Flag (F)'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Flag (F)'), findsNothing);
    // Focus did not move: the anchor still has it.
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<IconButton>(),
      isNotNull,
    );
  });

  testWidgets('Tab away hides the focus tooltip', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      on(
        TargetPlatform.macOS,
        Column(
          children: [
            _anchor(),
            TextButton(onPressed: () {}, child: const Text('Next')),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.pump(PantasDurations.short2);
    expect(find.text('Flag (F)'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Flag (F)'), findsNothing);
  });

  testWidgets('A long press on touch shows nothing', (tester) async {
    await pumpDs(tester, dsCells.first, on(TargetPlatform.android, _anchor()));
    await tester.longPress(find.byType(IconButton));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Flag (F)'), findsNothing);
  });

  testWidgets('The name alone is shown when there is no shortcut',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      on(
        TargetPlatform.macOS,
        const PantasTooltip(
          message: 'Hide questions',
          child: SizedBox(width: 44, height: 44),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(SizedBox).last));
    await tester.pump(PantasDurations.tooltip + PantasDurations.short2);
    expect(find.text('Hide questions'), findsOneWidget);
    await mouse.moveTo(const Offset(5, 500));
    await tester.pump(PantasDurations.short2 * 4);
  });

  // The drawn box, without its transparent bridge margin.
  Finder tipBox() => find
      .ancestor(of: find.text('Flag (F)'), matching: find.byType(DecoratedBox))
      .first;

  Future<TestGesture> hoverOpen(WidgetTester tester, DsCell cell) async {
    await pumpDs(tester, cell, on(TargetPlatform.macOS, _anchor()));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(IconButton)));
    await tester.pump(PantasDurations.tooltip + PantasDurations.short2);
    expect(find.text('Flag (F)'), findsOneWidget);
    return mouse;
  }

  for (final cell in [dsCells[0], dsCells[3], dsCells[4], dsCells[7]]) {
    testWidgets(
        'The pointer crosses the 8 point bridge onto the tooltip and it '
        'stays ($cell)', (tester) async {
      final mouse = await hoverOpen(tester, cell);
      final anchor = tester.getRect(find.byType(IconButton));
      final tip = tester.getRect(tipBox());
      // The bridge is the empty 8 points between anchor and tooltip.
      expect(anchor.top - tip.bottom, closeTo(8, .01));
      await mouse.moveTo(Offset(anchor.center.dx, anchor.top - 1));
      await tester.pump(PantasDurations.short2);
      await mouse.moveTo(Offset(anchor.center.dx, anchor.top - 4));
      await tester.pump(PantasDurations.short2);
      await mouse.moveTo(Offset(anchor.center.dx, anchor.top - 7));
      await tester.pump(PantasDurations.short2);
      expect(find.text('Flag (F)'), findsOneWidget);
      await mouse.moveTo(tip.center);
      // Well past any exit delay: it stays while the pointer is on it.
      await tester.pump(PantasDurations.tooltip * 4);
      expect(find.text('Flag (F)'), findsOneWidget);
      // Leaving both closes it.
      await mouse.moveTo(const Offset(5, 500));
      await tester.pump(PantasDurations.short2 * 4);
      await tester.pump(PantasDurations.short2 * 4);
      expect(find.text('Flag (F)'), findsNothing);
    });
  }

  testWidgets('Esc closes a tooltip the pointer is holding open',
      (tester) async {
    await hoverOpen(tester, dsCells.first);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Flag (F)'), findsNothing);
  });

  testWidgets('Esc is left to the page when no tooltip is open',
      (tester) async {
    var escapes = 0;
    await pumpDs(
      tester,
      dsCells.first,
      on(
        TargetPlatform.macOS,
        Focus(
          autofocus: true,
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              escapes++;
            }
            return KeyEventResult.ignored;
          },
          child: _anchor(),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(escapes, 1);
  });
}
