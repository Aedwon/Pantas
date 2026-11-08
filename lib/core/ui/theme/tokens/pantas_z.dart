// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

/// Paint order of overlays (z-index).
abstract final class PantasZ {
  /// Page content.
  static const int base = 0;

  /// Sticky headers and the sticky side panel.
  static const int sticky = 10;

  /// TabBar, floating bar, tablet nav, reader bar.
  static const int nav = 20;

  /// Scrim. Each modal owns a scrim and surface pair.
  static const int overlay = 40;

  /// Dialog, Drawer, Sheet. A later modal stacks above an earlier one.
  static const int modal = 50;

  /// Popover, menu, select list. Above its owner, including inside a modal.
  static const int popover = 60;

  /// Toast, above every modal so Undo stays reachable.
  static const int toast = 70;

  /// Tooltip.
  static const int tooltip = 80;
}
