import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

void main() {
  testWidgets('a value sits at the row end and a board row is 71 px',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: SizedBox(
            width: 618,
            child: WebRow(
              boardMetrics: true,
              title: 'Reviews',
              subtitle: 'Questions due today',
              value: '0 of 18',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    final row = find.byType(WebRow);
    // Value right edge = row right edge less the 20 px padding.
    expect(tester.getTopRight(find.text('0 of 18')).dx, 618 - 20);
    // 13 + 22.1 + 18.2 + 13 + one device pixel for the hairline.
    expect(tester.getSize(row).height, closeTo(67.3, .5));
  });

  testWidgets('the hover chevron is hidden until the row is hovered',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: WebRow(
            title: 'Reviews',
            value: '0 of 18',
            chevron: WebRowChevron.hover,
            onPressed: () {},
          ),
        ),
      ),
    );
    // The chevron fades (160 ms), so read where it is going and how far it is.
    double target() => tester
        .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .singleWhere((o) => o.child is WebChevron)
        .opacity;
    double shown() => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byType(WebChevron),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;
    expect(target(), 0);
    expect(shown(), 0);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(WebRow)));
    await tester.pump();
    expect(target(), 1);
    await tester.pumpAndSettle();
    expect(shown(), 1);
  });

  testWidgets('pressing a row keeps the tint that hovering gave it',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: WebRow(title: 'Practice', onPressed: () {}),
        ),
      ),
    );
    final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
    final background = style.backgroundColor!;
    final hovered = background.resolve({WidgetState.hovered});
    expect(hovered, isNot(Colors.transparent));
    expect(
      background.resolve({WidgetState.hovered, WidgetState.pressed}),
      hovered,
    );
    // A press on its own is at least as strong as hovering.
    expect(background.resolve({WidgetState.pressed}), hovered);
    expect(background.resolve({}), Colors.transparent);
  });

  testWidgets('a maths title shows no dollar signs and stays on one line',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: const Scaffold(
          body: SizedBox(
            width: 400,
            child: WebRow(
              mathTitle: true,
              title: r'Find $x^2$ when $8$ liters hold a $50\%$ mix of the '
                  'solution that the student adds to a very long tank',
            ),
          ),
        ),
      ),
    );
    final text = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((r) => r.text.toPlainText())
        .join();
    expect(text.contains(r'$'), isFalse);
    expect(tester.getSize(find.byType(WebRow)).height, lessThan(80));
  });
}
