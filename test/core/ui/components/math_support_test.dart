import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/math_support.dart';

void main() {
  group('displayFractions', () {
    test('promotes a lone fraction so it is readable inline', () {
      expect(displayFractions(r'\frac{1}{2}'), r'\dfrac{1}{2}');
    });

    test('leaves a fraction nested in another alone', () {
      // The inner one is meant to be smaller. Promoting it would set a
      // full-size fraction inside a fraction.
      expect(
        displayFractions(r'\frac{\frac{1}{2}}{3}'),
        r'\dfrac{\frac{1}{2}}{3}',
      );
    });

    test('leaves a fraction in the denominator alone too', () {
      expect(
        displayFractions(r'\frac{1}{\frac{2}{3}}'),
        r'\dfrac{1}{\frac{2}{3}}',
      );
    });

    test('promotes two fractions that sit side by side', () {
      expect(
        displayFractions(r'\frac{1}{2} + \frac{3}{4}'),
        r'\dfrac{1}{2} + \dfrac{3}{4}',
      );
    });

    test('handles the braceless form', () {
      expect(displayFractions(r'\frac12'), r'\dfrac12');
    });

    test('does not touch a fraction already promoted', () {
      expect(displayFractions(r'\dfrac{1}{2}'), r'\dfrac{1}{2}');
    });

    test('leaves a fraction nested inside an already promoted one', () {
      expect(
        displayFractions(r'\dfrac{\frac{1}{2}}{3}'),
        r'\dfrac{\frac{1}{2}}{3}',
      );
    });

    test('leaves maths with no fraction untouched', () {
      expect(displayFractions('x^2 + y^2 = z^2'), 'x^2 + y^2 = z^2');
    });
  });
}
