import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';

/// Gauge README, text scaling: the number sits inside the arc. At 200% the
/// whole dial grows with the text, so the number keeps its place inside the
/// arc and never runs through the stroke.
void main() {
  setUpAll(loadDsFonts);

  Future<({double dial, double number})> measure(
    WidgetTester tester,
    Widget gauge,
    double scale,
    String numberText,
  ) async {
    await pumpAccessibilitySurface(
      tester,
      SizedBox(width: 358, child: gauge),
      textScale: scale,
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    expect(tester.takeException(), isNull);
    final dial = tester.getRect(find.byKey(const ValueKey('half-ring-paint')));
    final number = tester.getRect(find.text(numberText));
    return (dial: dial.width, number: number.width);
  }

  for (final (name, gauge, text) in <(String, Widget, String)>[
    (
      'mock',
      const HalfRingGauge.mock(fraction: .612, label: '171 correct'),
      '61.2',
    ),
    (
      'quiz count',
      HalfRingGauge.quizCount(correct: 18, total: 20),
      '/20',
    ),
  ]) {
    testWidgets('the $name dial grows with the text and keeps its number',
        (tester) async {
      final one = await measure(tester, gauge, 1, text);
      final two = await measure(tester, gauge, 2, text);
      expect(two.dial, greaterThan(one.dial));
      // The number takes the same share of the dial, so it cannot reach the
      // stroke at 200% when it did not at 100%.
      expect(
        two.number / two.dial,
        closeTo(one.number / one.dial, .01),
      );
    });
  }

  testWidgets('the dial does not outgrow a narrow screen', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const SizedBox(
        width: 288,
        child: HalfRingGauge.mock(fraction: .612, label: '171 correct'),
      ),
      textScale: 2,
      disableAnimations: true,
      viewportSize: const Size(320, 640),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const ValueKey('half-ring-paint'))).width,
      lessThanOrEqualTo(288),
    );
  });
}
