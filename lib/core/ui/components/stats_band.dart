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
  const StatsBand({
    required this.figures,
    this.centred = false,
    this.compact = false,
    super.key,
  });

  final List<StatFigure> figures;

  /// Centres each figure in its column. The session panel and the Home spec's
  /// band are centred; the Progress table and the results pages are not.
  final bool centred;

  /// The 21px panel size rather than the 30px page size.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    assert(figures.isNotEmpty, 'StatsBand needs at least one figure');
    final colors = context.colors;
    final styles = context.textStyles;

    final numeralStyle = styles.displayLarge.copyWith(
      fontSize: compact ? 21 : 30,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final suffixStyle = numeralStyle.copyWith(
      fontSize: compact ? 12 : 16,
      fontWeight: FontWeight.w400,
      color: colors.inkMuted,
    );

    final children = <Widget>[];
    for (var i = 0; i < figures.length; i++) {
      final figure = figures[i];
      children.add(
        Column(
          crossAxisAlignment:
              centred ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: centred
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Text(figure.value, style: numeralStyle),
                if (figure.suffix != null)
                  Text(figure.suffix!, style: suffixStyle),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              figure.label,
              textAlign: centred ? TextAlign.center : TextAlign.start,
              style: styles.bodySmall.copyWith(
                fontSize: compact ? 11.5 : null,
                color: colors.inkMuted,
              ),
            ),
          ],
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colors.rule,
              width: AppDimensions.hairline,
            ),
            bottom: BorderSide(
              color: colors.rule,
              width: AppDimensions.hairline,
            ),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: children,
          ),
        ),
      ),
    );
  }
}
