import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// A phone page title that never breaks a word in two.
///
/// Two rules, both from the design system (Text scaling, D180):
///
/// * The phone large title steps down to `phone-title-2` when the screen is
///   under 12rem wide (`layout-title-narrow`). The width is the space this
///   title has, divided by the scaled 16px: a 390 phone at 200% is 11.2rem.
/// * A word is split only when one word alone is wider than the line. If the
///   longest word does not fit at the chosen size, the title takes the next
///   step down so it fits.
///
/// [style] is the title's own style (large title, page title or a screen
/// variant). The step-down is `phone-title-2` in the title's color. A title
/// that is not a large title passes [narrowRule] false, so it only steps down
/// when a word would split.
class PantasTitle extends StatelessWidget {
  const PantasTitle(
    this.text, {
    required this.style,
    this.narrowRule = true,
    this.maxLines,
    this.textAlign,
    super.key,
  });

  final String text;
  final TextStyle style;

  /// Apply the 12rem `layout-title-narrow` step. True for the large title.
  final bool narrowRule;
  final int? maxLines;
  final TextAlign? textAlign;

  /// Width of the narrow screen in rem under which the large title steps down.
  static const double narrowRem = 12;

  /// The style to use for [text] on a line [width] wide. The step-down keeps
  /// the title's color.
  static TextStyle resolve({
    required String text,
    required TextStyle style,
    required double width,
    required TextScaler scaler,
    required TextDirection direction,
    bool narrowRule = true,
  }) {
    final down = PantasType.phoneTitle2.copyWith(color: style.color);
    if (narrowRule && width / scaler.scale(16) < narrowRem) return down;
    if (_longestWordFits(text, style, width, scaler, direction)) return style;
    return down;
  }

  static bool _longestWordFits(
    String text,
    TextStyle style,
    double width,
    TextScaler scaler,
    TextDirection direction,
  ) {
    if (!width.isFinite) return true;
    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(text: word, style: style),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      final fits = painter.width <= width;
      painter.dispose();
      if (!fits) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Text(
          text,
          maxLines: maxLines,
          textAlign: textAlign,
          style: resolve(
            text: text,
            style: style,
            width: constraints.maxWidth,
            scaler: MediaQuery.textScalerOf(context),
            direction: Directionality.of(context),
            narrowRule: narrowRule,
          ),
        ),
      );
}
