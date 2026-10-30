import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
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
    await tester.pump(const Duration(milliseconds: 160));
    for (final scale
        in tester.widgetList<AnimatedScale>(find.byType(AnimatedScale))) {
      expect(scale.scale, 1);
    }
    await gesture.up();
  });
}
