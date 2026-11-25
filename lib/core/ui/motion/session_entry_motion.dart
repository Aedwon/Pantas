import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

/// The staggered entrance of the session results. The phone page and the wide
/// page share it, so both play one timeline off one controller.
class SessionEntryMotion {
  const SessionEntryMotion(this.controller);
  final AnimationController controller;

  /// Fades [child] in and rises it by [rise] px. [start] and [duration] are in
  /// milliseconds of the timeline. [curve] is the house ease unless a frame
  /// draws another.
  Widget appear(
    Widget child,
    int start,
    int duration, {
    double rise = 0,
    Curve curve = PantasCurves.house,
  }) =>
      AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) {
          final t = ((controller.value * controller.duration!.inMilliseconds -
                      start) /
                  duration)
              .clamp(0.0, 1.0);
          final value = curve.transform(t);
          return IgnorePointer(
            ignoring: t == 0,
            child: Transform.translate(
              offset: Offset(0, rise * (1 - value)),
              child: Opacity(opacity: value, child: child),
            ),
          );
        },
      );

  /// Pops the circle for question [index]: [step] ms after the one before it,
  /// from [start]. It grows to 1.12 in [grow] ms, then settles in [settle].
  Widget pop(
    int index,
    Widget child, {
    int start = 400,
    int step = 90,
    int grow = 260,
    int settle = 160,
    Curve curve = PantasCurves.popB,
  }) =>
      AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) {
          final elapsed =
              controller.value * controller.duration!.inMilliseconds -
                  start -
                  index * step;
          final before = elapsed < 0;
          final first = (elapsed / grow).clamp(0.0, 1.0);
          final last = ((elapsed - grow) / settle).clamp(0.0, 1.0);
          final scale = elapsed <= grow
              ? .4 + .72 * curve.transform(first)
              : 1.12 - .12 * curve.transform(last);
          return IgnorePointer(
            ignoring: before,
            child: Opacity(
              opacity: before
                  ? 0
                  : elapsed <= grow
                      ? curve.transform(first).clamp(0.0, 1.0)
                      : 1,
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
      );
}
