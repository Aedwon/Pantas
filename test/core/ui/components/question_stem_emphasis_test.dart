import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('stem bold stays distinct at $width in $brightness',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          const QuestionCard(
            subject: 'English',
            stem: 'Choose the meaning of **reserved** in this sentence.',
          ),
          viewportSize: Size(width, 700),
          brightness: brightness,
        );
        final rich = tester.widget<RichText>(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText() ==
                    'Choose the meaning of reserved in this sentence.',
          ),
        );
        final spans = ((rich.text as TextSpan).children!.single as TextSpan)
            .children!
            .cast<TextSpan>();
        expect(spans.map((span) => span.style!.fontWeight), [
          FontWeight.w500,
          FontWeight.w800,
          FontWeight.w500,
        ]);
        expect(spans.map((span) => span.style!.color).toSet(), hasLength(1));
        expect(spans.map((span) => span.style!.fontSize).toSet(), {21.0});
      });
    }
  }

  testWidgets('a review preview keeps bold distinct', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(
        text: 'Choose **one** word.',
        questionStem: true,
        maxLines: 1,
      ),
    );
    final rich = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Choose one word.',
      ),
    );
    final spans = ((rich.text as TextSpan).children!.single as TextSpan)
        .children!
        .cast<TextSpan>();
    expect(spans.map((span) => span.style!.fontWeight), [
      FontWeight.w500,
      FontWeight.w800,
      FontWeight.w500,
    ]);
  });

  testWidgets('a stem without bold keeps its current weight', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const QuestionCard(subject: 'English', stem: 'Choose one word.'),
    );
    final rich = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Choose one word.',
      ),
    );
    final content = (rich.text as TextSpan).children!.single as TextSpan;
    final span = content.children!.single as TextSpan;
    expect(span.style!.fontWeight, FontWeight.w600);
  });
}
