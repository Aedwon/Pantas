import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// One row of a score breakdown (the system's StatRow): the name at the left,
/// "correct / total" and the percent at the right, and a 5 high accuracy bar
/// under them. Shared by the mock results and the assessment results.
///
/// The row pads 12 above and below with 8 between the line and the bar, and
/// a 0.5 `divider` rule sits under it unless [divider] is false. The phone
/// insets it 16; on wide screens the card supplies the 20 inset. At large
/// text the values stack under the name.
class ScoreBreakdownRow extends StatelessWidget {
  const ScoreBreakdownRow({
    required this.name,
    required this.correct,
    required this.total,
    required this.divider,
    this.animatedAccuracy,
    super.key,
  });
  final String name;
  final int correct;
  final int total;

  /// Overrides the bar width while an entrance plays. Null uses the bar's own.
  final double? animatedAccuracy;
  final bool divider;
  double get accuracy => total == 0 ? 0 : correct / total;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final values = Wrap(
      spacing: PantasSpace.s14,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$correct / $total',
          style: PantasType.webRowValue.copyWith(color: c.textSecondary),
        ),
        Text(
          '${(accuracy * 100).round()}%',
          style: PantasType.webStatValue.copyWith(
            color: c.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
    // The name wraps to a second line instead of being cut: a long subject
    // such as "Language Proficiency (English & Filipino)" must read in full
    // on a phone, where the count and the percent sit beside it.
    final title = Text(
      name,
      style: PantasType.webRowTitleSettings.copyWith(color: c.textPrimary),
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.wideWeb ? PantasSpace.s0 : PantasSpace.s16,
        vertical: PantasSpace.s12,
      ),
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(
                  width: PantasBorder.hairline,
                  color: c.divider,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (large) ...[title, values] else
            Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: PantasSpace.s10),
                values,
              ],
            ),
          const SizedBox(height: PantasSpace.s8),
          if (animatedAccuracy == null)
            AccuracyBar(accuracy: accuracy)
          else
            // An entrance clock drives the fill directly.
            ClipRRect(
              borderRadius: BorderRadius.circular(PantasRadius.full),
              child: Container(
                height: PantasSize.accuracyBar,
                color: c.fill,
                alignment: Alignment.centerLeft,
                child: LayoutBuilder(
                  builder: (context, box) => SizedBox(
                    width: math.max(
                      PantasSize.accuracyBar,
                      animatedAccuracy!.clamp(0, 1) * box.maxWidth,
                    ),
                    height: PantasSize.accuracyBar,
                    child: ColoredBox(
                      key: const ValueKey('accuracy-bar-fill'),
                      color: AccuracyBar.stepColor(c, accuracy),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
