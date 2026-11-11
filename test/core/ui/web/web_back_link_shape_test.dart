import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

/// Back link A (Aedwon, Nov 7, Pantas Design System canvas): the link
/// highlights as a rounded rectangle like Sign Out, never a pill, and the
/// highlight reaches into the page margin whole while the arrow stays where it
/// was. Before, the hover was a pill cut off at the page's left edge.
void main() {
  // The page clips at x = 100, as the shell's page area does.
  Future<void> pump(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(web: true),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(left: 100, top: 50),
            child: ClipRect(
              child: Align(
                alignment: Alignment.topLeft,
                child: WebBackLink(label: 'Home', onPressed: () {}),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Finder rounded(double radius) => find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is ShapeDecoration &&
            (w.decoration as ShapeDecoration).shape is RoundedRectangleBorder &&
            ((w.decoration as ShapeDecoration).shape as RoundedRectangleBorder)
                    .borderRadius ==
                BorderRadius.circular(radius),
      );

  final pill = find.byWidgetPredicate(
    (w) =>
        w is DecoratedBox &&
        w.decoration is ShapeDecoration &&
        (w.decoration as ShapeDecoration).shape is StadiumBorder,
  );

  testWidgets('hover draws a whole rounded rectangle, radius 11',
      (tester) async {
    await pump(tester);
    expect(rounded(11), findsNothing);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Home')));
    await tester.pumpAndSettle();
    expect(rounded(11), findsOneWidget);
    expect(pill, findsNothing);
    final fill = tester.getRect(rounded(11));
    expect(fill, tester.getRect(find.byType(TextButton)));
    // It reaches 14 px into the margin, past the clip, and is drawn whole.
    expect(fill.left, 86);
    expect(fill.height, 40);
    await mouse.moveTo(const Offset(700, 600));
    await tester.pumpAndSettle();
    expect(rounded(11), findsNothing);
  });

  testWidgets('the arrow stays 6 px left of the page edge', (tester) async {
    await pump(tester);
    final arrow = tester.getRect(
      find.byIcon(PantasIcons.bold(PantasIcons.back)),
    );
    expect(arrow.left, 94);
  });

  testWidgets('the label keeps 10 px on its right', (tester) async {
    await pump(tester);
    final link = tester.getRect(find.byType(TextButton));
    final label = tester.getRect(find.text('Home'));
    expect(link.right - label.right, 10);
  });
}
