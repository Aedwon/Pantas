import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';

/// A color that fades to a new value (item 17, `quick` and `ease`).
///
/// The fade is local: only [builder] runs on each frame, so a selection never
/// rebuilds the screen around it. With reduced motion the new color is simply
/// there.
class FadingColor extends StatelessWidget {
  const FadingColor({
    required this.color,
    required this.builder,
    this.duration = PantasDurations.quick,
    this.curve = PantasCurves.ease,
    this.child,
    super.key,
  });

  final Color color;
  final Duration duration;
  final Curve curve;

  /// Receives the color part-way between the old and the new one.
  final Widget Function(BuildContext context, Color color, Widget? child)
      builder;

  /// Built once and handed back to [builder], so it does not rebuild per frame.
  final Widget? child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: color),
        duration:
            MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration,
        curve: curve,
        child: child,
        builder: (context, value, child) =>
            builder(context, value ?? color, child),
      );
}

/// A marker that glides between slots: the tab bar pill, the sidebar tint and
/// the segmented thumb (item 17, `base` and the shared ease).
///
/// Only a translation and the marker's own length change, and only the marker
/// is rebuilt. Put it in a [Stack], behind the slots. It fills the cross axis
/// of the stack; [offsets] and [lengths] say where each slot is along [axis].
/// With no slot selected (an [index] out of range) it draws nothing.
class SlidingMarker extends StatelessWidget {
  const SlidingMarker({
    required this.offsets,
    required this.lengths,
    required this.index,
    required this.child,
    this.axis = Axis.horizontal,
    this.duration = PantasDurations.base,
    this.curve = PantasCurves.shared,
    super.key,
  }) : assert(offsets.length == lengths.length, 'One length for each offset.');

  /// Where each slot starts along [axis], in px.
  final List<double> offsets;

  /// How long each slot is along [axis], in px.
  final List<double> lengths;
  final int index;
  final Axis axis;
  final Duration duration;
  final Curve curve;

  /// The marker's own picture. It is sized and moved by this widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // No slot is selected (a page outside the four tabs): no marker.
    if (index < 0 || index >= offsets.length) return const SizedBox.shrink();
    final target = _Span(offsets[index], lengths[index]);
    return TweenAnimationBuilder<_Span>(
      tween: _SpanTween(end: target),
      duration:
          MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration,
      curve: curve,
      child: child,
      builder: (context, span, child) {
        final horizontal = axis == Axis.horizontal;
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: horizontal ? null : 0,
              bottom: horizontal ? 0 : null,
              width: horizontal ? span.length : null,
              height: horizontal ? null : span.length,
              child: Transform.translate(
                offset:
                    horizontal ? Offset(span.start, 0) : Offset(0, span.start),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

@immutable
class _Span {
  const _Span(this.start, this.length);
  final double start;
  final double length;

  // Equal spans must compare equal, or every rebuild would restart the glide.
  @override
  bool operator ==(Object other) =>
      other is _Span && other.start == start && other.length == length;

  @override
  int get hashCode => Object.hash(start, length);
}

class _SpanTween extends Tween<_Span> {
  _SpanTween({required _Span super.end});

  @override
  _Span lerp(double t) => _Span(
        lerpDouble(begin?.start ?? end!.start, end!.start, t)!,
        lerpDouble(begin?.length ?? end!.length, end!.length, t)!,
      );
}
