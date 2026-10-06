import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

/// Each builder receives progress for a board-specific ring, path or particles.
/// Timings are explicit; board effects do not loop.
abstract final class PantasEffects {
  static Widget pop({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('pop', duration, PantasCurves.popC, builder, child);
  static Widget rise({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('rise', duration, PantasCurves.riseIn, builder, child);
  static Widget gauge({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('gauge', duration, PantasCurves.houseOut, builder, child);
  static Widget checkDraw({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('checkDraw', duration, PantasCurves.checkDraw, builder, child);
  static Widget shake({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('shake', duration, PantasCurves.shake, builder, child);
  static Widget press({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('press', duration, PantasCurves.ease, builder, child);
  static Widget ring({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('ring', duration, PantasCurves.easeOut, builder, child);
  static Widget burst({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('burst', duration, PantasCurves.burst, builder, child);
  static Widget push({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('push', duration, PantasCurves.riseIn, builder, child);
  static Widget collapse({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('collapse', duration, PantasCurves.ease, builder, child);
  static Widget fade({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('fade', duration, PantasCurves.ease, builder, child);

  static Widget _effect(
    String effect,
    Duration duration,
    Curve curve,
    ValueWidgetBuilder<double> builder,
    Widget? child,
  ) =>
      Builder(
        builder: (context) {
          if (MediaQuery.disableAnimationsOf(context)) {
            return _frame(effect, 1, builder(context, 1, child));
          }
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: duration,
            curve: curve,
            child: child,
            builder: (context, value, child) =>
                _frame(effect, value, builder(context, value, child)),
          );
        },
      );

  static Widget _frame(String effect, double value, Widget child) {
    final opacity = value.clamp(0.0, 1.0);
    return switch (effect) {
      'pop' => Transform.scale(
          scale: 0.4 + 0.6 * value,
          child: Opacity(opacity: opacity, child: child),
        ),
      'rise' => Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: Opacity(opacity: opacity, child: child),
        ),
      'push' => Transform.translate(
          offset: Offset(40 * (1 - value), 0),
          child: Opacity(opacity: opacity, child: child),
        ),
      'shake' =>
        Transform.translate(offset: Offset(_shake(value), 0), child: child),
      'press' => Transform.scale(
          scale: 1 - 0.03 * math.sin(math.pi * value),
          child: child,
        ),
      'collapse' => ClipRect(
          child: Align(
            heightFactor: 1 - opacity,
            child: Opacity(opacity: 1 - opacity, child: child),
          ),
        ),
      'fade' => Opacity(opacity: opacity, child: child),
      // The board owns the geometry of a gauge, check, ring or burst.
      _ => child,
    };
  }

  static double _shake(double t) {
    const stops = [0.0, 0.18, 0.36, 0.54, 0.72, 1.0];
    const offsets = [0.0, -9.0, 8.0, -5.0, 3.0, 0.0];
    for (var i = 1; i < stops.length; i++) {
      if (t <= stops[i]) {
        final fraction = (t - stops[i - 1]) / (stops[i] - stops[i - 1]);
        return offsets[i - 1] + fraction * (offsets[i] - offsets[i - 1]);
      }
    }
    return 0;
  }
}
