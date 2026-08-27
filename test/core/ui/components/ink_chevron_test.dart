import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

Widget harness(Widget child, {bool disableAnimations = false}) => MaterialApp(
      theme: buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('a chevron paints at its given size', (tester) async {
    await tester.pumpWidget(harness(const InkChevron()));

    expect(tester.getSize(find.byType(InkChevron)), const Size(12, 12));
  });

  testWidgets('a downward chevron is a quarter turn from a right one',
      (tester) async {
    await tester.pumpWidget(harness(const InkChevron(pointsDown: true)));
    await tester.pumpAndSettle();

    final rotation = tester.widget<AnimatedRotation>(
      find.byType(AnimatedRotation),
    );
    expect(rotation.turns, 0.25);
  });

  testWidgets('a right chevron has no rotation', (tester) async {
    await tester.pumpWidget(harness(const InkChevron()));
    await tester.pumpAndSettle();

    final rotation = tester.widget<AnimatedRotation>(
      find.byType(AnimatedRotation),
    );
    expect(rotation.turns, 0);
  });

  testWidgets('reduced motion makes disclosure rotation instant', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(const InkChevron(pointsDown: true), disableAnimations: true),
    );

    final rotation = tester.widget<AnimatedRotation>(
      find.byType(AnimatedRotation),
    );
    expect(rotation.duration, Duration.zero);
  });
}
