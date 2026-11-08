// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

import 'package:flutter/animation.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

/// Duration, delay and curve of one named motion recipe.
class PantasMotionRecipe {
  const PantasMotionRecipe({
    required this.duration,
    required this.delay,
    required this.curve,
  });

  final Duration duration;
  final Duration delay;
  final Curve curve;
}

/// Recipe values from design/system/motion.md.
abstract final class PantasMotionRecipes {
  /// Reveal mark pop
  static const revealMark = PantasMotionRecipe(
    duration: Duration(milliseconds: 560),
    delay: Duration.zero,
    curve: PantasCurves.move,
  );

  /// Right-answer ripple (`accent` at `opacity-ripple` 0.38 to 0)
  static const ripple = PantasMotionRecipe(
    duration: Duration(milliseconds: 700),
    delay: Duration(milliseconds: 50),
    curve: Cubic(0, 0, 0.58, 1),
  );

  /// Question panel children in
  static const panelChildrenIn = PantasMotionRecipe(
    duration: Duration(milliseconds: 220),
    delay: Duration(milliseconds: 120),
    curve: PantasCurves.fade,
  );

  /// Question panel children out
  static const panelChildrenOut = PantasMotionRecipe(
    duration: Duration(milliseconds: 160),
    delay: Duration.zero,
    curve: PantasCurves.fade,
  );

  /// Skeleton out
  static const skeletonOut = PantasMotionRecipe(
    duration: Duration(milliseconds: 200),
    delay: Duration.zero,
    curve: PantasCurves.fade,
  );

  /// Skeleton in
  static const skeletonIn = PantasMotionRecipe(
    duration: Duration(milliseconds: 300),
    delay: Duration(milliseconds: 60),
    curve: PantasCurves.fade,
  );

  /// View swap out
  static const swapOut = PantasMotionRecipe(
    duration: Duration(milliseconds: 100),
    delay: Duration.zero,
    curve: PantasCurves.fade,
  );

  /// View swap in
  static const swapIn = PantasMotionRecipe(
    duration: Duration(milliseconds: 180),
    delay: Duration(milliseconds: 60),
    curve: PantasCurves.move,
  );

  /// Pane out
  static const paneOut = PantasMotionRecipe(
    duration: Duration(milliseconds: 90),
    delay: Duration.zero,
    curve: PantasCurves.fade,
  );

  /// Pane in
  static const paneIn = PantasMotionRecipe(
    duration: Duration(milliseconds: 170),
    delay: Duration(milliseconds: 70),
    curve: PantasCurves.move,
  );

  /// Check draw
  static const checkDraw = PantasMotionRecipe(
    duration: PantasDurations.slide,
    delay: Duration(milliseconds: 120),
    curve: PantasCurves.draw,
  );

  /// Tassel swing
  static const tassel = PantasMotionRecipe(
    duration: Duration(milliseconds: 2200),
    delay: Duration(milliseconds: 400),
    curve: Cubic(0.36, 0.07, 0.19, 0.97),
  );
}
