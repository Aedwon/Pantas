import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

/// Each builder receives progress for a board-specific ring, path or particles.
/// Timings are explicit; board effects do not loop.
abstract final class PantasEffects {
  static Widget pop({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('pop', duration, PantasCurves.spring, builder, child);
  static Widget rise({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('rise', duration, PantasCurves.enter, builder, child);
  static Widget gauge({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('gauge', duration, PantasCurves.house, builder, child);
  static Widget checkDraw({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('checkDraw', duration, PantasCurves.draw, builder, child);
  static Widget shake({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('shake', duration, PantasBoardCurves.shake, builder, child);
  static Widget press({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('press', duration, PantasCurves.fade, builder, child);
  static Widget ring({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('ring', duration, PantasBoardCurves.easeOut, builder, child);
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
      _effect('push', duration, PantasCurves.enter, builder, child);
  static Widget collapse({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('collapse', duration, PantasCurves.fade, builder, child);
  static Widget fade({
    required Duration duration,
    required ValueWidgetBuilder<double> builder,
    Widget? child,
  }) =>
      _effect('fade', duration, PantasCurves.fade, builder, child);

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
            // CSS timing functions apply within each keyframe interval.
            curve: effect == 'pop' || effect == 'shake' ? Curves.linear : curve,
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
          scale: _keyframes(
            value,
            const [0, 0.6, 1],
            const [0.4, 1.12, 1],
            PantasCurves.spring,
          ),
          child: Opacity(
            opacity: _keyframes(
              value,
              const [0, 0.6, 1],
              const [0, 1, 1],
              PantasCurves.spring,
            ).clamp(0.0, 1.0),
            child: child,
          ),
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

  /// The sideways offset, in logical pixels, of the shake at [t] (0 to 1).
  /// For a widget that must replay the shake without being rebuilt, such as
  /// a text field that has to keep its focus.
  static double shakeOffset(double t) => _shake(t);

  /// The tassel's swing angle, in degrees, at [t] (0 to 1) of the waiting
  /// screen's logo: it swings out, back, and settles. Clockwise is positive.
  static double tasselSwing(double t) => _keyframes(
        t,
        const [0, 0.18, 0.38, 0.56, 0.74, 1],
        const [0, 11, -8, 5, -2.5, 0],
        PantasBoardCurves.shake,
      );

  static double _shake(double t) => _keyframes(
        t,
        const [0, 0.18, 0.36, 0.54, 0.72, 1],
        const [0, -9, 8, -5, 3, 0],
        PantasBoardCurves.shake,
      );

  static double _keyframes(
    double t,
    List<double> stops,
    List<double> values,
    Curve curve,
  ) {
    for (var i = 1; i < stops.length; i++) {
      if (t <= stops[i]) {
        final fraction = (t - stops[i - 1]) / (stops[i] - stops[i - 1]);
        return values[i - 1] +
            curve.transform(fraction.clamp(0.0, 1.0)) *
                (values[i] - values[i - 1]);
      }
    }
    return values.last;
  }
}
