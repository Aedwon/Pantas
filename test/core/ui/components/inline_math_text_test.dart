import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/inline_math_text.dart';

import '../../../helpers/pump_app.dart';

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

  group('InlineMathText', () {
    testWidgets('sets a dollar-wrapped run as maths rather than printing it',
        (tester) async {
      await tester.pumpApp(const InlineMathText(r'What is $x^2$ here?'));

      expect(find.byType(Math), findsOneWidget);
      expect(find.textContaining(r'$'), findsNothing);
    });

    testWidgets('keeps the words around the maths', (tester) async {
      await tester.pumpApp(const InlineMathText(r'What is $x^2$ here?'));

      expect(find.textContaining('What is'), findsOneWidget);
    });

    testWidgets('renders a plain string with no maths widget', (tester) async {
      await tester.pumpApp(const InlineMathText('No maths at all'));

      expect(find.byType(Math), findsNothing);
      expect(find.text('No maths at all'), findsOneWidget);
    });

    testWidgets('handles two runs in one line', (tester) async {
      await tester.pumpApp(const InlineMathText(r'$a$ and $b$'));

      expect(find.byType(Math), findsNWidgets(2));
      expect(find.textContaining(r'$'), findsNothing);
    });

    testWidgets('leaves a lone dollar sign as a dollar sign', (tester) async {
      // Money, not maths. Nothing closes the run, so nothing is maths.
      await tester.pumpApp(const InlineMathText(r'It costs $5 today'));

      expect(find.byType(Math), findsNothing);
    });
  });
}
