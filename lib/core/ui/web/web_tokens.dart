import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

// LEGACY: remove in family M. Lets callers of `webTokens.colors` see the old
// field names.
export 'package:pantas/core/ui/theme/legacy_theme_shim.dart';

/// Desktop canvas roles. One palette serves every width: the getters below
/// forward to the design system roles and styles (D50, D51, D112, D123, D124
/// dark values come from `tokens.json`).
@immutable
class WebTokens {
  const WebTokens(this.brightness);
  final Brightness brightness;
  bool get dark => brightness == Brightness.dark;

  PantasColors get colors => dark ? PantasColors.dark : PantasColors.light;

  /// A primary button under the pointer (`accent-fill-hover`).
  Color get accentHover => colors.accentFillHover;

  /// Teal text on `accent-tint` (`accent-tint-text`).
  Color get tintText => colors.accentTintText;
  Color get figureScrim => colors.figureScrim;
  Color get figureCaption => colors.figureCaption;
  Color get cardEdge => colors.edgeCard;
  Color get strongDivider => colors.dividerStrong;
  Color get segmentOn => colors.surfaceSegmentOn;
  Color get rowHover => colors.surfaceHover;
  Color get secondaryHover => colors.accentTintHover;
  Color get dangerFill => colors.dangerFill;
  Color get dangerHover => colors.dangerFillHover;
  // No role for a disabled well: the neutral fill is the nearest by meaning.
  Color get disabledBackground => colors.fill;
  Color get disabledText => colors.textDisabled;

  TextStyle style(
    double size, {
    FontWeight weight = FontWeight.w400,
    double? height,
    double spacing = 0,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: 'Geist',
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: color ?? colors.textPrimary,
      );
  TextStyle get h1 => PantasType.webH1.copyWith(color: colors.textPrimary);
  TextStyle get h2 => PantasType.webH2.copyWith(color: colors.textPrimary);
  TextStyle get h3 => PantasType.webH3.copyWith(color: colors.textPrimary);
  TextStyle get qtext =>
      PantasType.webQuestion.copyWith(color: colors.textPrimary);
  TextStyle get big =>
      PantasType.webBigNumeral.copyWith(color: colors.textPrimary);
  TextStyle get sub => PantasType.webSub.copyWith(color: colors.textSecondary);
  TextStyle get sm => PantasType.webSmall.copyWith(color: colors.textSecondary);
  TextStyle get eb =>
      PantasType.webEyebrow.copyWith(color: colors.textSecondary);
}

extension WebTokensContext on BuildContext {
  WebTokens get webTokens => WebTokens(Theme.of(this).brightness);
}
