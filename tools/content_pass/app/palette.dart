import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The app's accent green, for the selected segment and Looks good. The same
/// in both themes, so white text on it keeps its contrast.
const thumbGreen = Color(0xFF0B7A67);

/// Quiet monochrome colors for the reviewer chrome. The screen in the middle
/// has its own theme.
class Palette {
  const Palette({
    required this.bg,
    required this.panel,
    required this.line,
    required this.text,
    required this.muted,
    required this.track,
    required this.hover,
    required this.greenTint,
    required this.greenLine,
  });

  factory Palette.of({required bool dark}) => dark ? _dark : _light;

  final Color bg;
  final Color panel;
  final Color line;
  final Color text;
  final Color muted;

  /// The recessed track behind a switch.
  final Color track;
  final Color hover;
  final Color greenTint;
  final Color greenLine;

  static const _light = Palette(
    bg: Color(0xFFF4F4F2),
    panel: Color(0xFFFFFFFF),
    line: Color(0xFFE0E0DC),
    text: Color(0xFF1D1D1B),
    muted: Color(0xFF5F5F5A),
    track: Color(0xFFE6E6E2),
    hover: Color(0x0F000000),
    greenTint: Color(0x1F0B7A67),
    greenLine: Color(0xFF0B7A67),
  );

  static const _dark = Palette(
    bg: Color(0xFF161616),
    panel: Color(0xFF1C1C1C),
    line: Color(0xFF2E2E2E),
    text: Color(0xFFE8E8E6),
    muted: Color(0xFFA6A6A1),
    track: Color(0xFF2A2A2A),
    hover: Color(0x14FFFFFF),
    greenTint: Color(0x330B7A67),
    greenLine: Color(0xFF4CC3AC),
  );

  // ignore: prefer_constructors_over_static_methods
  static Palette lerp(Palette a, Palette b, double t) => Palette(
        bg: Color.lerp(a.bg, b.bg, t)!,
        panel: Color.lerp(a.panel, b.panel, t)!,
        line: Color.lerp(a.line, b.line, t)!,
        text: Color.lerp(a.text, b.text, t)!,
        muted: Color.lerp(a.muted, b.muted, t)!,
        track: Color.lerp(a.track, b.track, t)!,
        hover: Color.lerp(a.hover, b.hover, t)!,
        greenTint: Color.lerp(a.greenTint, b.greenTint, t)!,
        greenLine: Color.lerp(a.greenLine, b.greenLine, t)!,
      );
}

/// Tweens between two palettes, so a theme change fades the whole chrome.
class PaletteTween extends Tween<Palette> {
  PaletteTween({super.begin, super.end});

  @override
  Palette lerp(double t) => Palette.lerp(begin!, end!, t);
}

/// WCAG contrast ratio of two opaque colors.
double contrastRatio(Color a, Color b) {
  double luminance(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
