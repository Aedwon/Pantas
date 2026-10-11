import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_support.dart';

export 'package:pantas/core/ui/components/math_support.dart'
    show
        displayFractions,
        inlineMathExpressionSemanticsLabel,
        inlineMathSemantics,
        inlineMathSpan,
        inlineMathSpans;

/// A line of text that may carry `$…$` maths.
///
/// The single place a plain string becomes maths. Answer choices, which are
/// plain strings rather than lesson blocks, went to the screen through `Text`
/// and printed their dollar signs: 645 of the 2,000 questions in the bank
/// carry maths in a choice.
class InlineMathText extends StatelessWidget {
  const InlineMathText(
    this.text, {
    this.style,
    this.textAlign,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final richText = Text.rich(
      TextSpan(children: inlineMathSpans(text, style: style)),
      style: style,
      textAlign: textAlign,
    );
    final semantics = inlineMathSemantics(text);
    if (semantics == null || !semantics.hasMath) return richText;

    return Semantics(
      label: semantics.label,
      excludeSemantics: true,
      child: richText,
    );
  }
}
