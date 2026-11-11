import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';

Future<void> _mount(WidgetTester tester) async {
  resetWebKeyboardFocus();
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(web: true),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WebButton(label: 'First', onPressed: () {}),
                WebButton(label: 'Second', onPressed: () {}),
                WebRow(title: 'Row', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The button's keyboard ring: `border-focus` in `accent`, drawn 2 px outside
/// the button (design system 4.0). A width of 0 when none is drawn.
BorderSide _side(WidgetTester tester, String label) {
  final ring = find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(WebButton)),
    matching: find.byKey(const ValueKey('focus-ring')),
  );
  if (ring.evaluate().isEmpty) return BorderSide.none;
  final box = tester.widget<DecoratedBox>(ring).decoration as BoxDecoration;
  return box.border!.top;
}

/// The row's ring is its own rounded layer inside the row (3K-6): its width,
/// or 0 when none is drawn.
double _rowRing(WidgetTester tester) {
  final rings = find.descendant(
    of: find.byType(WebRow),
    matching: find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).border != null &&
          (w.decoration as BoxDecoration).borderRadius ==
              BorderRadius.circular(12),
    ),
  );
  if (rings.evaluate().isEmpty) return 0;
  final box =
      tester.widget<DecoratedBox>(rings.first).decoration as BoxDecoration;
  return box.border!.top.width;
}

void main() {
  testWidgets('a mouse click shows no focus ring', (tester) async {
    await _mount(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('First')));
    await mouse.down(tester.getCenter(find.text('First')));
    await mouse.up();
    await tester.pump();
    final node = FocusManager.instance.rootScope.descendants.firstWhere(
      (n) =>
          n.context?.findAncestorWidgetOfExactType<TextButton>() != null &&
          n.context!.findAncestorWidgetOfExactType<WebButton>() != null &&
          (n.context!.findAncestorWidgetOfExactType<WebButton>()!).label ==
              'First',
    );
    // ignore: cascade_invocations
    node.requestFocus();
    await tester.pump();
    expect(node.hasPrimaryFocus, isTrue);
    expect(_side(tester, 'First').width, isNot(2));
    expect(_rowRing(tester), 0);
  });

  testWidgets('Tab shows a 2 px accent ring on a button and on a row',
      (tester) async {
    await _mount(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final first = _side(tester, 'First');
    expect(first.width, 2);
    expect(first.color, PantasColors.light.accent);
    expect(_side(tester, 'Second').width, isNot(2));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_rowRing(tester), 2);
    expect(_side(tester, 'First').width, isNot(2));
  });

  testWidgets('a click then Tab shows the ring on the next control',
      (tester) async {
    await _mount(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('First')));
    await mouse.down(tester.getCenter(find.text('First')));
    await mouse.up();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      _side(tester, 'First').width == 2 || _side(tester, 'Second').width == 2,
      isTrue,
    );
  });

  // 3K-11: the plain buttons a page uses (a back link, a segmented control, a
  // text button, an icon button) showed nothing at a Tab stop. The theme now
  // gives every one of them the same keyboard-only ring.
  testWidgets('Tab rings every plain button and segment, a click does not',
      (tester) async {
    resetWebKeyboardFocus();
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WebBackLink(label: 'Home', onPressed: () {}),
                  WebSegmentedControl(
                    labels: const ['Subjects', 'Topics', 'Lessons'],
                    selected: 0,
                    onChanged: (_) {},
                  ),
                  TextButton(onPressed: () {}, child: const Text('Plain')),
                  WebTextLink(label: 'See more', onPressed: () {}),
                  WebKeyboardRing(
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {},
                      child: const SizedBox(
                        key: ValueKey('ink'),
                        width: 100,
                        height: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    BorderSide sideOf(Finder f) {
      // A system button or link draws its ring outside (OffsetFocusRing); a
      // plain Material button keeps the theme's ring on its own shape.
      final outside = find.descendant(
        of: find.ancestor(of: f, matching: find.byType(WebTextLink)),
        matching: find.byKey(const ValueKey('focus-ring')),
      );
      if (find
          .ancestor(of: f, matching: find.byType(WebTextLink))
          .evaluate()
          .isNotEmpty) {
        if (outside.evaluate().isEmpty) return BorderSide.none;
        final box =
            tester.widget<DecoratedBox>(outside).decoration as BoxDecoration;
        return box.border!.top;
      }
      final button = find.ancestor(of: f, matching: find.byType(TextButton));
      final material = tester.widget<Material>(
        find.descendant(of: button, matching: find.byType(Material)).first,
      );
      return (material.shape! as OutlinedBorder).side;
    }

    // The segmented control is one Tab stop: only the selected segment.
    final stops = [
      find.text('Home'),
      find.text('Subjects'),
      find.text('Plain'),
      find.text('See more'),
    ];
    final backRing = find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is ShapeDecoration &&
          // Back link A: the ghost buttons' rounded rectangle, not a pill.
          (w.decoration as ShapeDecoration).shape is RoundedRectangleBorder &&
          ((w.decoration as ShapeDecoration).shape as RoundedRectangleBorder)
                  .side
                  .width ==
              2,
    );
    for (final stop in stops) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      if (stop == stops.first) {
        // The back link is nudged out of the page's clip, so its ring is
        // drawn above the page (5Q-11), not on its button.
        expect(backRing, findsOneWidget);
        continue;
      }
      expect(backRing, findsNothing);
      expect(sideOf(stop).width, 2, reason: 'ring on $stop');
      expect(sideOf(stop).color, PantasColors.light.accent);
    }
    // The next stop is the bare tap target, which the ring widget draws.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    BoxDecoration ringBox() => tester
        .widget<DecoratedBox>(
          find.byWidgetPredicate(
            (w) =>
                w is DecoratedBox &&
                w.position == DecorationPosition.foreground &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).borderRadius ==
                    BorderRadius.circular(8),
          ),
        )
        .decoration as BoxDecoration;
    expect(ringBox().border, isNotNull);
    expect(ringBox().border!.top.width, 2);
    // Pointing at a control and pressing it takes the ring away.
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Plain')));
    await mouse.down(tester.getCenter(find.text('Plain')));
    await mouse.up();
    await tester.pump();
    expect(sideOf(find.text('Plain')).width, isNot(2));
    expect(ringBox().border, isNull);
  });

  testWidgets('a row at the corner of a card rings inside the corner (3K-6)',
      (tester) async {
    resetWebKeyboardFocus();
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              child: WebCard(
                child: Column(
                  children: [
                    WebRow(title: 'Top', onPressed: () {}),
                    WebRow(title: 'Bottom', divider: false, onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final row = tester.getRect(find.byType(WebRow).first);
    final ring = tester.getRect(
      find
          .descendant(
            of: find.byType(WebRow).first,
            matching: find.byWidgetPredicate(
              (w) =>
                  w is DecoratedBox &&
                  w.decoration is BoxDecoration &&
                  (w.decoration as BoxDecoration).borderRadius ==
                      BorderRadius.circular(12),
            ),
          )
          .first,
    );
    // The card's own corner is 18 px, so a ring on the row's edge was cut.
    expect(ring.left - row.left, 3);
    expect(ring.top - row.top, 3);
    expect(row.right - ring.right, 3);
  });
}
