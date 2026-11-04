import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class CheckMark extends StatelessWidget {
  const CheckMark({this.progress, this.animate = true, super.key})
      : glyphSize = null,
        glyphColor = null;

  /// Only the check, no disc, for a list that draws it bare (the wide Study
  /// map). It pops in as the disc does.
  const CheckMark.glyph({
    required double size,
    required Color color,
    this.animate = true,
    super.key,
  })  : glyphSize = size,
        glyphColor = color,
        progress = null;
  final Animation<double>? progress;

  /// False when the mark is drawn for something already done (a list laid out
  /// again): it stands in place at once.
  final bool animate;
  final double? glyphSize;
  final Color? glyphColor;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context) || !animate;
    final glyphSize = this.glyphSize;
    final circle = glyphSize != null
        ? Icon(PantasIcons.check, size: glyphSize, color: glyphColor)
        : DecoratedBox(
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
