import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StatFigure {
  const StatFigure({required this.value, required this.label, this.suffix});

  final String value;
  final String? suffix;
  final String label;
}

/// "Figures first" stats: large serif numerals, sans labels beneath,
/// vertical hairlines between figures, ruled top and bottom.
class StatsBand extends StatelessWidget {
  const StatsBand({required this.figures, super.key});

  final List<StatFigure> figures;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final numeralStyle =
        styles.displayLarge.copyWith(fontSize: 30, height: 1);
    final suffixStyle = numeralStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: colors.inkMuted,
    );

    final children = <Widget>[];
    for (var i = 0; i < figures.length; i++) {
      final figure = figures[i];
      children.add(
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(figure.value, style: numeralStyle),
                  if (figure.suffix != null)
                    Text(figure.suffix!, style: suffixStyle),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                figure.label,
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ),
      );
      if (i < figures.length - 1) {
        children.add(
          Container(
            key: ValueKey('stats-divider-$i'),
            width: AppDimensions.hairline,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: colors.rule,
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          // AppDimensions.hairline (1px) currently equals BorderSide's
          // default width, but it's stated explicitly so the rule tracks
          // the constant rather than an implicit default.
          top: BorderSide(
            color: colors.rule,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
          bottom: BorderSide(
            color: colors.rule,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(children: children),
      ),
    );
  }
}
