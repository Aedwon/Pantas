import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';

import 'preview_curves.dart';

// Item 17, demo 8: a tile shrinks to 98% while held, 120 ms down, 180 ms up,
// on the shared ease. Scale only.
Widget _tile({
  bool reduced = false,
  bool enabled = true,
  double scale = .98,
  VoidCallback? onTap,
}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: Center(
            child: PressScale(
              scale: scale,
              enabled: enabled,
              child: GestureDetector(
                onTap: onTap,
                child:
                    const SizedBox(width: 200, height: 100, child: Text('x')),
              ),
            ),
          ),
        ),
      ),
    );

double _scale(WidgetTester tester) => tester
    .widget<Transform>(
      find.descendant(
        of: find.byType(PressScale),
        matching: find.byType(Transform),
      ),
    )
    .transform
    .entry(0, 0);

void main() {
  testWidgets('holding shrinks to 98% over 120 ms, letting go takes 180 ms',
      (tester) async {
    await tester.pumpWidget(_tile());
    expect(_scale(tester), 1);
    final press = await tester.startGesture(tester.getCenter(find.text('x')));
    await tester.pump();
    for (final ms in [30, 30, 30, 30]) {
      await tester.pump(Duration(milliseconds: ms));
    }
    expect(_scale(tester), closeTo(.98, .0001));

    // Sample the way down again from the start.
    await press.up();
    await tester.pumpAndSettle();
    final again = await tester.startGesture(tester.getCenter(find.text('x')));
    await tester.pump();
    var elapsed = 0;
    for (final ms in [30, 30]) {
      await tester.pump(Duration(milliseconds: ms));
      elapsed += ms;
      expect(
        _scale(tester),
        closeTo(1 - .02 * previewShared(elapsed / 120), .0005),
        reason: 'down at $elapsed ms',
      );
    }
    await tester.pump(const Duration(milliseconds: 60));
    expect(_scale(tester), closeTo(.98, .0001));

    await again.up();
    await tester.pump();
    elapsed = 0;
    for (final ms in [45, 45]) {
      await tester.pump(Duration(milliseconds: ms));
      elapsed += ms;
      expect(
        _scale(tester),
        closeTo(.98 + .02 * previewShared(elapsed / 180), .0005),
        reason: 'up at $elapsed ms',
      );
    }
    await tester.pump(const Duration(milliseconds: 90));
    expect(_scale(tester), 1);
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the tap still reaches the child', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_tile(onTap: () => taps++));
    await tester.tap(find.text('x'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('a quick tap still dips before it springs back', (tester) async {
    await tester.pumpWidget(_tile());
    final press = await tester.startGesture(tester.getCenter(find.text('x')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final dipped = _scale(tester);
    expect(dipped, lessThan(1));
    await press.up();
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
  });

  testWidgets('dragging away lets the tile go, as a scroll would',
      (tester) async {
    await tester.pumpWidget(_tile());
    final press = await tester.startGesture(tester.getCenter(find.text('x')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(_scale(tester), closeTo(.98, .0001));
    await press.moveBy(const Offset(0, 60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(_scale(tester), 1);
    await press.up();
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion never shrinks the tile', (tester) async {
    await tester.pumpWidget(_tile(reduced: true));
    final press = await tester.startGesture(tester.getCenter(find.text('x')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.descendant(
        of: find.byType(PressScale),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    await press.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a tile that cannot be pressed does not shrink', (tester) async {
    await tester.pumpWidget(_tile(enabled: false));
    final press = await tester.startGesture(tester.getCenter(find.text('x')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_scale(tester), 1);
    await press.up();
    await tester.pumpAndSettle();
  });
}
