import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

// Aedwon chose the math package's own KaTeX serif family, October 10.
// The package selects its individual KaTeX glyph families internally.
const mathRenderingFont = 'packages/flutter_math_fork/KaTeX_Main';

class MathText extends StatelessWidget {
  const MathText(
    this.text, {
    this.style,
    this.display = false,
    this.semanticsLabel,
    this.textAlign,
    super.key,
  });
  final String text;
  final TextStyle? style;
  final bool display;
  final String? semanticsLabel;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    final effective = style ?? context.type.body;
    if (display) {
      return MathExpression(
        latex: displayFractions(text),
        textStyle: effective.copyWith(fontFamily: mathRenderingFont),
        semanticsLabel: semanticsLabel,
        onErrorFallback: (context) => Text(text, style: effective),
      );
    }
    final rich = Text.rich(
      TextSpan(children: inlineMathSpans(text, style: effective)),
      style: effective,
      textAlign: textAlign,
    );
    final spoken = inlineMathSemantics(text);
    if (spoken == null || !spoken.hasMath) return rich;
    return Semantics(
      label: semanticsLabel ?? spoken.label,
      excludeSemantics: true,
      child: rich,
    );
  }
}
