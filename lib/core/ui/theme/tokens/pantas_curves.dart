// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

import 'package:flutter/animation.dart';

/// Easing curves by role.
abstract final class PantasCurves {
  /// Things arriving: rise, fade-in, list reveal, push, slide-in panel, bar
  /// fills. Desktop default (rise in).
  static const enter = Cubic(0.2, 0.9, 0.3, 1);

  /// Spatial moves of something already on screen: nav panel, sliding
  /// thumb, arrow nudge, page and lesson open, reveal. The handoff shared
  /// ease.
  static const move = Cubic(0.32, 0.72, 0, 1);

  /// Overshoot: pop and the switch thumb.
  static const spring = Cubic(0.34, 1.56, 0.64, 1);

  /// Color and opacity only: hover tints, crossfades, state flips. CSS
  /// ease.
  static const fade = Cubic(0.25, 0.1, 0.25, 1);

  /// Strokes drawing: check marks, ring arcs, counters rolling out.
  static const draw = Cubic(0.6, 0, 0.3, 1);

  /// Liquid fills: the exam switch.
  static const liquid = Cubic(0.45, 0, 0.25, 1);

  /// Spinners and scroll-linked motion only.
  static const Curve linear = Curves.linear;

  /// Phone house ease: dialog open and close, toast, notice collapse, ring
  /// and gauge fills. Restored from the phone code (houseOut) for overlays;
  /// see Decisions.
  static const house = Cubic(0.3, 0.9, 0.3, 1);

  /// Drawer and sheet open and close (phone slideC).
  static const slide = Cubic(0.2, 1, 0.35, 1);

  /// Half gauge fill and roll counter (phone slideB).
  static const gauge = Cubic(0.2, 0.8, 0.25, 1);

  /// Shapes scroll-linked motion: reader bar, pull to advance (phone
  /// slideA).
  static const scroll = Cubic(0.22, 1, 0.36, 1);

  /// Badge and letter pops, exam-switch check (phone popB).
  static const popB = Cubic(0.3, 1.5, 0.5, 1);

  /// Confetti only.
  static const burst = Cubic(0.15, 0.7, 0.35, 1);
}
