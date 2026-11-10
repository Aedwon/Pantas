import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/hold_to_repeat.dart';

void main() {
  Future<({TestGesture gesture, List<int> steps})> hold(
    WidgetTester tester, {
    bool Function(int step)? more,
    void Function({required bool wasHold})? onReleased,
  }) async {
    final steps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: HoldToRepeat(
            onStep: () {
              steps.add(steps.length + 1);
              return more?.call(steps.length) ?? true;
            },
            onReleased: onReleased,
            builder: (context, onPressed) => const SizedBox.square(
              key: ValueKey('target'),
              dimension: 80,
            ),
          ),
        ),
      ),
    );
    final gesture = await tester
        .startGesture(tester.getCenter(find.byKey(const ValueKey('target'))));
    await tester.pump();
    return (gesture: gesture, steps: steps);
  }

  testWidgets('first repeat at 400 ms, then every 140 ms', (tester) async {
    final h = await hold(tester);
    expect(h.steps.length, 1);
    await tester.pump(const Duration(milliseconds: 399));
    expect(h.steps.length, 1);
    await tester.pump(const Duration(milliseconds: 1));
    expect(h.steps.length, 2);
    await tester.pump(const Duration(milliseconds: 139));
    expect(h.steps.length, 2);
    await tester.pump(const Duration(milliseconds: 1));
    expect(h.steps.length, 3);
    await h.gesture.up();
  });

  testWidgets('every 70 ms once held 1.2 s, every 35 ms once held 2.4 s',
      (tester) async {
    final h = await hold(tester);
    // Repeats at 400, 540, ... 1240: seven repeats, 8 steps in all.
    await tester.pump(const Duration(milliseconds: 1240));
    expect(h.steps.length, 8);
    await tester.pump(const Duration(milliseconds: 69));
    expect(h.steps.length, 8);
    await tester.pump(const Duration(milliseconds: 1));
    expect(h.steps.length, 9);
    // 70 ms repeats up to 2430, the first one past 2.4 s.
    await tester.pump(const Duration(milliseconds: 2430 - 1310));
    expect(h.steps.length, 9 + (2430 - 1310) ~/ 70);
    final atFast = h.steps.length;
    await tester.pump(const Duration(milliseconds: 34));
    expect(h.steps.length, atFast);
    await tester.pump(const Duration(milliseconds: 1));
    expect(h.steps.length, atFast + 1);
    await tester.pump(const Duration(milliseconds: 35));
    expect(h.steps.length, atFast + 2);
    await h.gesture.up();
  });

  testWidgets('stops on release and on cancel', (tester) async {
    final h = await hold(tester);
    await tester.pump(const Duration(milliseconds: 400));
    await h.gesture.up();
    final count = h.steps.length;
    await tester.pump(const Duration(seconds: 2));
    expect(h.steps.length, count);

    final c = await hold(tester);
    await tester.pump(const Duration(milliseconds: 400));
    await c.gesture.cancel();
    final after = c.steps.length;
    await tester.pump(const Duration(seconds: 2));
    expect(c.steps.length, after);
  });

  testWidgets('stops when the step says it cannot move', (tester) async {
    final h = await hold(tester, more: (step) => step < 3);
    await tester.pump(const Duration(seconds: 3));
    expect(h.steps.length, 3);
    await h.gesture.up();
  });

  testWidgets('reports a tap and a hold on release', (tester) async {
    final released = <bool>[];
    final tap = await hold(
      tester,
      onReleased: ({required wasHold}) => released.add(wasHold),
    );
    await tester.pump(const Duration(milliseconds: 399));
    await tap.gesture.up();
    await tester.pump();
    expect(released, [false]);
    final held = await hold(
      tester,
      onReleased: ({required wasHold}) => released.add(wasHold),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await held.gesture.up();
    await tester.pump();
    expect(released, [false, true]);
  });
}
