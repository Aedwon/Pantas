import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hover_shape.dart';

// Each new check must be able to fail, so each runs once on a sample that is
// broken on purpose.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: child))),
      );

  testWidgets('expectHitArea fails on a 32 square and passes on 44',
      (tester) async {
    await pump(
      tester,
      const Column(
        children: [
          SizedBox.square(key: ValueKey('small'), dimension: 32),
          SizedBox.square(key: ValueKey('ok'), dimension: 44),
        ],
      ),
    );
    expect(
      () => expectHitArea(tester, find.byKey(const ValueKey('small'))),
      throwsA(isA<TestFailure>()),
    );
    expectHitArea(tester, find.byKey(const ValueKey('ok')));
    expectHitArea(
      tester,
      find.byKey(const ValueKey('small')),
      min: const Size.square(32),
      reason: 'a README that sets 32',
    );
  });

  testWidgets('expectDisabledInert fails on an enabled button', (tester) async {
    await pump(
      tester,
      Column(
        children: [
          TextButton(
            key: const ValueKey('on'),
            onPressed: () {},
            child: const Text('On'),
          ),
          const TextButton(
            key: ValueKey('off'),
            onPressed: null,
            child: Text('Off'),
          ),
        ],
      ),
    );
    await expectLater(
      expectDisabledInert(tester, find.byKey(const ValueKey('on'))),
      throwsA(isA<TestFailure>()),
    );
    await expectDisabledInert(tester, find.byKey(const ValueKey('off')));
  });

  testWidgets('expectDisabledInert fails when a disabled button washes',
      (tester) async {
    await pump(
      tester,
      TextButton(
        key: const ValueKey('washy'),
        onPressed: null,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? Colors.red
                : Colors.transparent,
          ),
        ),
        child: const Text('Washy'),
      ),
    );
    await expectLater(
      expectDisabledInert(tester, find.byKey(const ValueKey('washy'))),
      throwsA(isA<TestFailure>()),
    );
  });

  testWidgets('expectTapAreaInert fails when a tap still lands',
      (tester) async {
    var taps = 0;
    await pump(
      tester,
      GestureDetector(
        key: const ValueKey('live'),
        behavior: HitTestBehavior.opaque,
        onTap: () => taps++,
        child: const SizedBox.square(dimension: 60),
      ),
    );
    await expectLater(
      expectTapAreaInert(
        tester,
        find.byKey(const ValueKey('live')),
        () => taps,
      ),
      throwsA(isA<TestFailure>()),
    );
  });
}
