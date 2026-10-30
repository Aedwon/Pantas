import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class CheckMark extends StatelessWidget {
  const CheckMark({this.progress, super.key});
  final Animation<double>? progress;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final circle = DecoratedBox(
      key: const ValueKey('check-mark-circle'),
      decoration: BoxDecoration(
        color: context.colors.accentFill,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 24,
        child: Icon(
          PantasIcons.check,
          size: 14,
          color: context.colors.onAccent,
        ),
      ),
    );
    Widget scale(double value, Widget? child) => Transform.scale(
          key: const ValueKey('check-mark-scale'),
          scale: .4 + .6 * value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
    return Semantics(
      label: 'Done',
      excludeSemantics: true,
      child: progress != null
          ? AnimatedBuilder(
              animation: progress!,
              builder: (context, child) => scale(progress!.value, child),
              child: circle,
            )
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: still ? 1 : 0, end: 1),
              duration:
                  still ? Duration.zero : const Duration(milliseconds: 420),
              curve: PantasCurves.popC,
              builder: (context, value, child) => scale(value, child),
              child: circle,
            ),
    );
  }
}
