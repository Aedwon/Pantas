// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

/// Ring and hairline widths (logical px).
abstract final class PantasBorder {
  /// Row separators, card footer rule, popover ring.
  static const double hairline = 0.5;

  /// 1px ring on fields, search, white buttons, notices, key hints, cards
  /// edge.
  static const double ring = 1;

  /// 1.5px ring on checkboxes, radios, answer badges, switch off,
  /// selectable tiles.
  static const double ringStrong = 1.5;

  /// Selected or wrong ring, focus ring width.
  static const double ringSelected = 2;

  /// Current question chip ring, spinner arc, the 44px ring value stroke
  /// (boards: 2.5). New (R3-O22: was a literal).
  static const double ringCurrent = 2.5;

  /// Keyboard focus ring width: 2px outline, offset 2px, accent
  /// (text-primary on items whose selected state is an accent ring).
  static const double focus = 2;
}
