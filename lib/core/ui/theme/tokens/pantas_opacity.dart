// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

/// Opacity values.
abstract final class PantasOpacity {
  /// Disabled compound controls only (switch, checkbox, radio). Text uses
  /// text-disabled, never opacity. CHANGE: .45 and .42 fold to .4.
  static const double disabled = 0.4;

  /// Hover and press wash: the label color (currentColor) or text-primary
  /// at 8% over the ground, on tertiary, neutral and outlined buttons,
  /// IconButton, BackLink, the counter, segment and nav item hover and the
  /// table sort button. CSS: color-mix(in srgb, currentColor
  /// calc(var(--opacity-hover) * 100%), transparent). New (R4-O05: was a
  /// literal).
  static const double hover = 0.08;

  /// Track of the inline spinner: currentColor at 30%. New (R4-O05: was a
  /// literal).
  static const double spinnerTrack = 0.3;

  /// Ring of the floating bar in its right and wrong states: accent or
  /// danger at 26% (FloatingBar). New (R4R-O03: was a literal).
  static const double barRing = 0.26;

  /// Start of the right-answer ripple: accent at 38%, fading to 0
  /// (motion.md recipe "Right-answer ripple"). New (R4R-O03: was a
  /// literal).
  static const double ripple = 0.38;

  /// Edge shadow on display math that scrolls sideways: text-primary at 18%
  /// (ReaderBlock, D150). New (R4R-O03: was a literal).
  static const double scrollEdge = 0.18;
}
