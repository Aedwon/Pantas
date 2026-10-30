import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class CheckMark extends StatelessWidget {
  const CheckMark({this.progress, super.key})
      : selection = false,
        selected = true;
  const CheckMark.selection({required this.selected, super.key})
      : progress = null,
        selection = true;
  final bool selection;
  final bool selected;
  final Animation<double>? progress;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    if (selection && !selected) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.controlOutline, width: 1.5),
        ),
      );
    }
    final circle = DecoratedBox(
      key: const ValueKey('check-mark-circle'),
      decoration: BoxDecoration(
        color: context.colors.accentFill,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: selection ? 22 : 24,
        child: Icon(
          PantasIcons.check,
          size: selection ? 13 : 14,
          color: context.colors.onAccent,
        ),
      ),
    );
    Widget scale(double value, Widget? child) => Transform.scale(
          key: const ValueKey('check-mark-scale'),
          scale: selection ? .5 + .5 * value : .4 + .6 * value,
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
              duration: still
                  ? Duration.zero
                  : Duration(milliseconds: selection ? 200 : 420),
              curve: selection ? PantasCurves.popB : PantasCurves.popC,
              builder: (context, value, child) => scale(value, child),
              child: circle,
            ),
    );
  }
}
