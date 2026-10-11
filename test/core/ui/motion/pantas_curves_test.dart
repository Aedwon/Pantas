import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

void main() {
  test('every curve is exactly the approved CSS cubic', () {
    expect(PantasCurves.houseOut, const Cubic(0.3, 0.9, 0.3, 1));
    expect(PantasCurves.riseIn, const Cubic(0.2, 0.9, 0.3, 1));
    expect(PantasCurves.slideA, const Cubic(0.22, 1, 0.36, 1));
    expect(PantasCurves.slideB, const Cubic(0.2, 0.8, 0.25, 1));
    expect(PantasCurves.slideC, const Cubic(0.2, 1, 0.35, 1));
    expect(PantasCurves.edgeGrow, const Cubic(0.32, 0.72, 0, 1));
    expect(PantasCurves.popA, const Cubic(0.3, 1.4, 0.5, 1));
    expect(PantasCurves.popB, const Cubic(0.3, 1.5, 0.5, 1));
    expect(PantasCurves.popC, const Cubic(0.34, 1.56, 0.64, 1));
    expect(PantasCurves.checkDraw, const Cubic(0.6, 0, 0.3, 1));
    expect(PantasCurves.shake, const Cubic(0.36, 0.07, 0.19, 0.97));
    expect(PantasCurves.burst, const Cubic(0.15, 0.7, 0.35, 1));
    expect(PantasCurves.liquid, const Cubic(0.45, 0, 0.25, 1));
    expect(PantasCurves.ease, const Cubic(0.25, 0.1, 0.25, 1));
    expect(PantasCurves.easeOut, const Cubic(0, 0, 0.58, 1));
    expect(PantasCurves.easeInOut, const Cubic(0.42, 0, 0.58, 1));
    expect(PantasCurves.linear, Curves.linear);
  });
  test('steps divides time into equal jump-end steps', () {
    for (final count in [1, 4, 20]) {
      final curve = PantasCurves.steps(count);
      for (var i = 0; i < count; i++) {
        expect(curve.transform((i + 0.5) / count), i / count);
      }
      expect(curve.transform(1), 1);
    }
    expect(() => PantasCurves.steps(0), throwsAssertionError);
  });
}
