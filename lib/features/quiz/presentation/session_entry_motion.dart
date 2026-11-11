import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

/// The staggered entrance of the session results. The phone page and the wide
/// page share it, so both play one timeline off one controller.
class SessionEntryMotion {
  const SessionEntryMotion(this.controller);
  final AnimationController controller;

  /// Fades [child] in and rises it by [rise] px. [start] and [duration] are in
  /// milliseconds of the timeline.
  Widget appear(Widget child, int start, int duration, {double rise = 0}) =>
      AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) {
          final t = ((controller.value * controller.duration!.inMilliseconds -
                      start) /
                  duration)
              .clamp(0.0, 1.0);
          final value = PantasCurves.house.transform(t);
          return IgnorePointer(
            ignoring: t == 0,
            child: Transform.translate(
              offset: Offset(0, rise * (1 - value)),
              child: Opacity(opacity: value, child: child),
            ),
          );
        },
      );

  /// Pops the circle for question [index]: 90 ms after the one before it.
  Widget pop(int index, Widget child) => AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) {
          final elapsed =
              controller.value * controller.duration!.inMilliseconds -
                  400 -
                  index * 90;
          final before = elapsed < 0;
          final first = (elapsed / 260).clamp(0.0, 1.0);
          final last = ((elapsed - 260) / 160).clamp(0.0, 1.0);
          const curve = PantasCurves.popB;
          final scale = elapsed <= 260
              ? .4 + .72 * curve.transform(first)
              : 1.12 - .12 * curve.transform(last);
          return IgnorePointer(
            ignoring: before,
            child: Opacity(
              opacity: before
                  ? 0
                  : elapsed <= 260
                      ? curve.transform(first).clamp(0.0, 1.0)
                      : 1,
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
      );
}
