import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/legacy_theme_shim.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

void main() {
  test('every curve is exactly the approved CSS cubic', () {
    expect(PantasCurves.house, const Cubic(0.3, 0.9, 0.3, 1));
    expect(PantasCurves.enter, const Cubic(0.2, 0.9, 0.3, 1));
    expect(PantasCurves.scroll, const Cubic(0.22, 1, 0.36, 1));
    expect(PantasCurves.gauge, const Cubic(0.2, 0.8, 0.25, 1));
    expect(PantasCurves.slide, const Cubic(0.2, 1, 0.35, 1));
    expect(PantasCurves.move, const Cubic(0.32, 0.72, 0, 1));
    expect(PantasCurves.move, const Cubic(0.32, 0.72, 0, 1));
    expect(LegacyCurves.popA, const Cubic(0.3, 1.4, 0.5, 1));
    expect(PantasCurves.popB, const Cubic(0.3, 1.5, 0.5, 1));
    expect(PantasCurves.spring, const Cubic(0.34, 1.56, 0.64, 1));
    expect(PantasCurves.draw, const Cubic(0.6, 0, 0.3, 1));
    expect(LegacyCurves.shake, const Cubic(0.36, 0.07, 0.19, 0.97));
    expect(PantasCurves.burst, const Cubic(0.15, 0.7, 0.35, 1));
    expect(PantasCurves.liquid, const Cubic(0.45, 0, 0.25, 1));
    expect(PantasCurves.fade, const Cubic(0.25, 0.1, 0.25, 1));
    expect(LegacyCurves.easeOut, const Cubic(0, 0, 0.58, 1));
    expect(LegacyCurves.easeInOut, const Cubic(0.42, 0, 0.58, 1));
    expect(PantasCurves.linear, Curves.linear);
  });
  test('steps divides time into equal jump-end steps', () {
    for (final count in [1, 4, 20]) {
      final curve = LegacyCurves.steps(count);
      for (var i = 0; i < count; i++) {
        expect(curve.transform((i + 0.5) / count), i / count);
      }
      expect(curve.transform(1), 1);
    }
    expect(() => LegacyCurves.steps(0), throwsAssertionError);
  });
}
