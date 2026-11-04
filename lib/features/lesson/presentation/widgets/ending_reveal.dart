import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

/// One part of a lesson ending arriving: a staggered 8 px rise and fade that
/// starts after [delay] and takes [duration] on the house ease. The phone and
/// the wide layout share it.
///
/// With reduced motion the child is simply there.
///
/// A [held] reveal stays at its start, unseen, and never runs. The inert
/// preview of an ending rising under a pull holds it, so the one real ending
/// that replaces the preview is the only one that plays.
class EndingReveal extends StatelessWidget {
  const EndingReveal({
    required this.delay,
    required this.duration,
    required this.child,
    this.held = false,
    super.key,
  });

  /// Milliseconds before the rise starts.
  final int delay;

  /// Milliseconds the rise takes once it starts.
  final int duration;
  final Widget child;

  /// True for a preview: the child keeps its place, drawn at its start.
  final bool held;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    if (held) return Opacity(opacity: 0, child: child);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: delay + duration),
      curve:
          Interval(delay / (delay + duration), 1, curve: PantasCurves.houseOut),
      // The fade changes only the layer's opacity, so the card behind it is
      // painted once.
      child: RepaintBoundary(child: child),
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 8 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
    );
  }
}
