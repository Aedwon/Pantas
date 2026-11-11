import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// A thin bar that shows how far along something is (design system
/// ProgressBar): a 5 px `fill` track and a `radius-full` fill in `accent`
/// (`warning-text` when [warning]). An optional label row sits above it:
/// [label] at the left and [valueText] at the right, wrapping at large text.
///
/// The bar is not interactive. A warning always comes with words, so give
/// [valueText] a text such as "4 min left" when [warning] is set.
class PantasProgressBar extends StatelessWidget {
  const PantasProgressBar({
    required this.value,
    this.label,
    this.valueText,
    this.semanticValue,
    this.warning = false,
    super.key,
  }) : assert(value >= 0 && value <= 1, 'Value must be from 0 to 1.');

  /// The share done, 0 to 1.
  final double value;

  /// The visible label above the bar (`web-label`).
  final String? label;

  /// The short value at the right of the label row (`web-small`).
  final String? valueText;

  /// Replaces the spoken value; defaults to the percent.
  final String? semanticValue;

  /// Colors the fill `warning-text`.
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(PantasRadius.full),
      child: ColoredBox(
        color: colors.fill,
        child: SizedBox(
          height: PantasSize.accuracyBar,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: value),
            duration: still ? Duration.zero : PantasDurations.long2,
            curve: PantasCurves.house,
            builder: (context, v, _) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v,
                child: DecoratedBox(
                  key: const ValueKey('progress-bar-fill'),
                  decoration: BoxDecoration(
                    color: warning ? colors.warningText : colors.accent,
                    borderRadius: BorderRadius.circular(PantasRadius.full),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final head = label == null && valueText == null
        ? null
        : Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: PantasSpace.s12,
            runSpacing: PantasSpace.s4,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: PantasType.webLabel.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              if (valueText != null)
                Text(
                  valueText!,
                  style: PantasType.webSmall.copyWith(
                    color: colors.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          );
    return Semantics(
      label: label,
      value: semanticValue ?? '${(value * 100).round()} percent',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (head != null) ...[
              head,
              const SizedBox(height: PantasSpace.s8),
            ],
            bar,
          ],
        ),
      ),
    );
  }
}
