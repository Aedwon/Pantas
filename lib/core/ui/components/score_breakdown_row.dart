import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// One row of a score breakdown: the name, "correct / total", the percent and
/// a bar. Shared by the mock results and the assessment results.
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
    final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final values = Wrap(
      spacing: 14,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$correct / $total',
          style: context.type.subhead
              .copyWith(color: context.colors.secondaryLabel),
        ),
        Text(
          '${(accuracy * 100).round()}%',
          style: context.type.emphasized.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
    final title = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.type.body,
    );
    return Container(
      padding: context.wideWeb
          ? const EdgeInsets.symmetric(vertical: 15)
          // MK_PastPro: 13 px above the name, 11 under it, 13.5 under the bar.
          : const EdgeInsets.fromLTRB(16, 13, 16, 13.5),
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(width: .5, color: context.colors.separator),
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
                const SizedBox(width: 10),
                values,
              ],
            ),
          SizedBox(height: context.wideWeb ? 9 : 11),
          if (animatedAccuracy == null && !context.wideWeb)
            AccuracyBar(accuracy: accuracy)
          else
            // The wide boards draw an 8 px bar (the phone keeps 5 px). With no
            // entrance clock it fills like `AccuracyBar`: 600 ms, houseOut.
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Container(
                height: context.wideWeb ? 8 : 5,
                color: context.colors.fill,
                alignment: Alignment.centerLeft,
                child: animatedAccuracy == null
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: MediaQuery.disableAnimationsOf(context)
                              ? accuracy
                              : 0,
                          end: accuracy.clamp(0, 1),
                        ),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 600),
                        curve: PantasCurves.houseOut,
                        builder: (context, value, _) => _fill(context, value),
                      )
                    : _fill(context, animatedAccuracy!.clamp(0, 1)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fill(BuildContext context, double factor) => FractionallySizedBox(
        widthFactor: factor,
        child: ColoredBox(
          color: context.colors.accuracyTint(accuracy),
          child: SizedBox(height: context.wideWeb ? 8 : 5),
        ),
      );
}
