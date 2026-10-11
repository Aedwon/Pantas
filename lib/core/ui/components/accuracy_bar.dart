import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class AccuracyBar extends StatelessWidget {
  const AccuracyBar({required this.accuracy, super.key}) : height = 5;
  const AccuracyBar.topicRows({required this.accuracy, super.key}) : height = 4;
  final double accuracy;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
        label: '${(accuracy * 100).round()} percent',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Container(
            height: height,
            color: context.colors.fill,
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: MediaQuery.disableAnimationsOf(context) ? accuracy : 0,
                end: accuracy.clamp(0, 1),
              ),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 600),
              curve: PantasCurves.houseOut,
              builder: (context, value, _) => FractionallySizedBox(
                widthFactor: value,
                child: ColoredBox(
                  key: const ValueKey('accuracy-bar-fill'),
                  color: context.colors.accuracyTint(accuracy),
                  child: SizedBox(height: height),
                ),
              ),
            ),
          ),
        ),
      );
}
