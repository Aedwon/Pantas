import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

void main() {
  testWidgets('narrow web buttons and filters inherit pressed feedback policy',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Column(
            children: [
              PantasButton(label: 'Continue', onPressed: () {}),
              PantasButton.filterChip(
                label: 'All',
                selected: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
    for (final button
        in tester.widgetList<TextButton>(find.byType(TextButton))) {
      expect(
        button.style?.overlayColor?.resolve({WidgetState.pressed}),
        Colors.transparent,
      );
    }
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('All')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    // Buttons keep no press shrink on the web build...
    for (final scale
        in tester.widgetList<AnimatedScale>(find.byType(AnimatedScale))) {
      expect(scale.scale, 1);
    }
    // ...but a chip now does (Aedwon approved it, Nov 3 item 17, demo 5).
    expect(
      tester
          .widget<Transform>(
            find.descendant(
              of: find.byType(PressScale),
              matching: find.byType(Transform),
            ),
          )
          .transform
          .entry(0, 0),
      closeTo(.96, .0001),
    );
    await gesture.up();
    await tester.pumpAndSettle();
  });
}
