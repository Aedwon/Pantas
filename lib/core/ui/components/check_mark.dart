import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';

/// The pop of the done mark: `dur-medium-3` on `motion-spring`.
const _popDuration = PantasDurations.medium3;

/// The check inside the 24 disc, as the Checkbox draws it.
// ds-board: Checkbox README: 14 px check
const _glyph = 14.0;

class CheckMark extends StatelessWidget {
  const CheckMark({
    this.progress,
    this.animate = true,
    this.delay = Duration.zero,
    this.diameter = PantasSize.check,
    super.key,
  })  : glyphSize = null,
        glyphColor = null;

  /// Only the check, no disc, for a list that draws it bare (the wide Study
  /// map). It pops in as the disc does.
  const CheckMark.glyph({
    required double size,
    required Color color,
    this.animate = true,
    this.delay = Duration.zero,
    super.key,
  })  : glyphSize = size,
        glyphColor = color,
        diameter = PantasSize.check,
        progress = null;
  final Animation<double>? progress;

  /// False when the mark is drawn for something already done (a list laid out
  /// again): it stands in place at once.
  final bool animate;

  /// How long the mark waits, unseen, before it pops. For a mark that mounts
  /// under an entrance, so the pop starts once the row can be seen.
  final Duration delay;
  final double? glyphSize;
  final Color? glyphColor;

  /// The disc's width. A ring larger than the 24 marker (ProgressRing README:
  /// 100% swaps the ring for the marker) passes its own size, so the disc
  /// covers the ring.
  final double diameter;

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
              dimension: diameter,
              child: Icon(
                PantasIcons.check,
                size: _glyph * diameter / PantasSize.check,
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
              duration: still ? Duration.zero : delay + _popDuration,
              curve: delay == Duration.zero
                  ? PantasCurves.spring
                  : Interval(
                      delay.inMilliseconds /
                          (delay + _popDuration).inMilliseconds,
                      1,
                      curve: PantasCurves.spring,
                    ),
              builder: (context, value, child) => scale(value, child),
              child: circle,
            ),
    );
  }
}
