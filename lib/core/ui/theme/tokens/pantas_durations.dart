// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

/// Durations by role.
abstract final class PantasDurations {
  /// Press down (was dur-press).
  static const short1 = Duration(milliseconds: 120);

  /// Hover color and tint; reveal delay of the right answer (was
  /// dur-hover).
  static const short2 = Duration(milliseconds: 150);

  /// Press release; answer ring and fill change (was dur-release).
  static const short3 = Duration(milliseconds: 180);

  /// Arrow and chevron nudge on hover.
  static const nudge = Duration(milliseconds: 200);

  /// Moves, swaps, sliding markers, thumbs, popovers, pane change (was
  /// dur-base).
  static const medium1 = Duration(milliseconds: 240);

  /// Switch track, toast in, floating bar back to neutral.
  static const fade = Duration(milliseconds: 250);

  /// State flips, toast out, floating bar to a result; dialog scrim.
  static const flip = Duration(milliseconds: 300);

  /// Page and lesson open; dialog close (was dur-page, dur-dialog-close).
  static const medium2 = Duration(milliseconds: 320);

  /// Switch thumb; drawer and sheet scrim; collapse.
  static const switchDuration = Duration(milliseconds: 350);

  /// Push from the side; check mark draw (was dur-push, dur-check).
  static const slide = Duration(milliseconds: 380);

  /// Drawer and sheet close.
  static const drawerClose = Duration(milliseconds: 400);

  /// Pop; dialog open (was dur-pop, dur-dialog-open).
  static const medium3 = Duration(milliseconds: 420);

  /// Rise-in of a block; drawer and sheet open (was dur-rise,
  /// dur-drawer-open).
  static const long1 = Duration(milliseconds: 450);

  /// Mock question list toggle.
  static const navPanel = Duration(milliseconds: 460);

  /// Explanation slide-in.
  static const reveal = Duration(milliseconds: 500);

  /// Tooltip show delay on hover (keyboard focus shows it at once). Single
  /// owner: Tooltip. New (R3-O10).
  static const tooltip = Duration(milliseconds: 500);

  /// Bars filling (was dur-draw).
  static const long2 = Duration(milliseconds: 600);

  /// Rings filling after dur-wait; spinner turn (was dur-fill, dur-spin).
  static const long3 = Duration(milliseconds: 900);

  /// Half gauge fill after dur-wait (app half-ring gauge 1400; assessment
  /// 1500 and mock 1600 are choreography values).
  static const gauge = Duration(milliseconds: 1400);

  /// Delay before a ring fill, a skeleton, or the edge tab. A delay, not a
  /// duration.
  static const wait = Duration(milliseconds: 300);

  /// Step between staggered siblings: delay = index x dur-stagger.
  static const stagger = Duration(milliseconds: 80);

  /// Skeleton pulse cycle.
  static const pulse = Duration(milliseconds: 1300);

  /// Toast without an action stays this long.
  static const toast = Duration(milliseconds: 4000);

  /// Toast with an action (Undo) stays this long, paused while hovered or
  /// focused.
  static const toastAction = Duration(milliseconds: 8000);
}
