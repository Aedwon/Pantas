import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'emphasis may wrap math without consuming TeX operators $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
          tester, const ContentRenderer(text: r'**Use $x_1*x_2$ here.**'),
          brightness: brightness);
      expect(tester.widget<MathExpression>(find.byType(MathExpression)).latex,
          'x_1*x_2');
      expect(
          tester
              .widget<MathExpression>(find.byType(MathExpression))
              .textStyle!
              .fontWeight,
          FontWeight.w600);
      expect(find.textContaining('**'), findsNothing);
    });
    testWidgets('Markdown preserves complete subscript expressions $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
          tester,
          const ContentRenderer(
              text: r'Use **bold** and $x_1+x_2$ with _emphasis_.'),
          brightness: brightness);
      expect(find.byType(MathExpression), findsOneWidget);
      expect(tester.widget<MathExpression>(find.byType(MathExpression)).latex,
          'x_1+x_2');
      expect(find.textContaining('**'), findsNothing);
      final body = tester.widget<Text>(find.byType(Text).first);
      expect(body.textSpan!.toPlainText(), contains('Use bold and'));
      await expectSurvivesTextScale(
          tester, const ContentRenderer(text: r'$x_1+x_2$ and *words*.'),
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true);
    });
  }
}
