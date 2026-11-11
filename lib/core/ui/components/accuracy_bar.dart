import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';

/// A thin bar beside an accuracy number. The fill is one of five discrete
/// steps (`chart-1` below 45%, `chart-2` 45 to 54, `chart-3` 55 to 64,
/// `chart-4` 65 to 74, `chart-5` from 75), never a blend. The number is
/// always printed beside it, so the bar is `aria-hidden` in the system; here
/// it keeps its percent label for assistive tech.
class AccuracyBar extends StatelessWidget {
  const AccuracyBar({required this.accuracy, super.key})
      : height = PantasSize.accuracyBar;
  const AccuracyBar.topicRows({required this.accuracy, super.key})
      : height = PantasSize.accuracyBarCompact;
  final double accuracy;
  final double height;

  /// The step color for [accuracy] (0 to 1).
  static Color stepColor(PantasColors colors, double accuracy) {
    final percent = (accuracy * 100).round();
    if (percent < 45) return colors.chart1;
    if (percent < 55) return colors.chart2;
    if (percent < 65) return colors.chart3;
    if (percent < 75) return colors.chart4;
    return colors.chart5;
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: '${(accuracy * 100).round()} percent',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PantasRadius.full),
        child: Container(
          height: height,
          color: context.colors.fill,
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: still ? accuracy : 0,
              end: accuracy.clamp(0, 1),
            ),
            duration: still ? Duration.zero : PantasDurations.long2,
            curve: PantasCurves.house,
            builder: (context, value, _) => LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                // A bar never shrinks below its own height, so a low value
                // still shows.
                width: math.max(height, value * constraints.maxWidth),
                height: height,
                child: ColoredBox(
                  key: const ValueKey('accuracy-bar-fill'),
                  color: stepColor(context.colors, accuracy),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
