import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';

void main() {
  Future<void> pumpWith(
    WidgetTester tester,
    Brightness brightness,
    Color color,
    List<Color> seen,
  ) =>
      tester.pumpWidget(
        MaterialApp(
          themeAnimationDuration: Duration.zero,
          theme: ThemeData(brightness: brightness),
          home: FadingColor(
            color: color,
            builder: (context, shown, _) {
              seen.add(shown);
              return ColoredBox(color: shown);
            },
          ),
        ),
      );

  testWidgets('a selection fades to its new color', (tester) async {
    final seen = <Color>[];
    await pumpWith(tester, Brightness.light, Colors.white, seen);
    await pumpWith(tester, Brightness.light, Colors.black, seen);
    await tester.pump(const Duration(milliseconds: 40));
    expect(seen.last, isNot(Colors.black));
    expect(seen.last, isNot(Colors.white));
    await tester.pumpAndSettle();
    expect(seen.last, Colors.black);
  });

  // 7W-15: a theme switch is one step. A card that faded over it showed the
  // old theme's color on the new page.
  testWidgets('a switch between light and dark changes at once',
      (tester) async {
    final seen = <Color>[];
    await pumpWith(tester, Brightness.light, Colors.white, seen);
    await pumpWith(tester, Brightness.dark, Colors.black, seen);
    expect(seen.last, Colors.black);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
