// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

import 'package:flutter/painting.dart';

/// Corner radii (logical px). `full` is a pill or a circle.
abstract final class PantasRadius {
  /// Key caps and the Pro mark.
  static const double xs = 5;

  /// Controls under 40px: 32px icon buttons, segment buttons and track,
  /// search field, checkbox, exam chip, phone week day, toast action.
  /// CHANGE: folds 7 (checkbox) and 10 (search, segmented track, exam
  /// chip).
  static const double sm = 8;

  /// Back link A highlight only (locked shape). Component token: kept apart
  /// from the scale because back link A is a fixed decision.
  static const double back = 11;

  /// Controls 40 to 44px: buttons 42 and 44, fields, icon buttons 40 and
  /// 44, sidebar nav items, desktop week day, date cells. CHANGE: folds 11
  /// (42px buttons) and 10 (sidebar items).
  static const double md = 12;

  /// Controls 46px and up and small surfaces: large and phone buttons,
  /// tertiary bar and dialog buttons (the filled ones are pills,
  /// radius-full), popover, toast, phone grouped list, sheet top, notice,
  /// answer option, tiles. CHANGE: folds 16 (notice, answer option).
  static const double lg = 14;

  /// Cards, week strip, explanation card, link tiles. CHANGE: folds 20
  /// (explanation card).
  static const double xl = 18;

  /// Dialogs.
  static const double r2xl = 22;

  /// Floating bottom bar (half its 64px height).
  static const double bar = 32;

  /// Tags (D188), switches, dots, progress tracks, avatars, the tab bar and
  /// its items, and the pill buttons the approved boards draw: the floating
  /// bar counter and action (.cnt, btn--bar), the phone dialog pair
  /// (btn--dialog) and the compact pill (btn--pill-sm, the onboarding
  /// Retry) (D187, D189, D190). No other button is a pill, and a tertiary
  /// bar or dialog button keeps radius-lg. Flutter: StadiumBorder (a pill)
  /// or a circle.
  static const double full = 9999;

  /// `radius-full` as a shape.
  static const StadiumBorder fullShape = StadiumBorder();
}
