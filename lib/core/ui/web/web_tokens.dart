import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

/// Desktop canvas roles. Native colors remain in PantasColors.light/dark.
@immutable
class WebTokens {
  const WebTokens(this.brightness);
  final Brightness brightness;
  bool get dark => brightness == Brightness.dark;

  PantasColors get colors => dark
      ? PantasColors.dark.copyWith(
          background: const Color(0xFF151515),
          surface: const Color(0xFF1F1F1F),
          label: const Color(0xFFF5F5F5),
          secondaryLabel: const Color(0xFFA3A3A3),
          tertiaryLabel: const Color(0xFF949494),
          separator: const Color(0xFF303030),
          fill: const Color(0xFF2A2A2A),
          onFillLabel: const Color(0xFFA3A3A3),
          skeleton: const Color(0xFF2A2A2A),
          chevron: const Color(0xFF949494),
          accent: const Color(0xFF4CC3AC),
          accentFill: const Color(0xFF0F8571),
          accentTint: const Color(0xFF18332D),
          destructive: const Color(0xFFC44A46),
          wrongText: const Color(0xFFE0706B),
          wrongTint: const Color(0xFF33201F),
          floatingRight: const Color(0xFF18332D),
          floatingWrong: const Color(0xFF2E1E1D),
          choiceOutline: const Color(0xFF3D3D3D),
          controlOutline: const Color(0xFF3D3D3D),
          onAccent: Colors.white,
        )
      : PantasColors.light.copyWith(
          tertiaryLabel: const Color(0xFF8A8A8E),
          wrongTint: const Color(0xFFFDE8EA),
          floatingRight: const Color(0xFFEEF8F5),
        );

  Color get accentHover => dark ? colors.accentFill : const Color(0xFF086A5A);
  Color get tintText => dark ? const Color(0xFF7FD8C6) : colors.accent;
  Color get cardEdge => dark ? const Color(0xFF2C2C2C) : Colors.transparent;
  Color get strongDivider =>
      dark ? const Color(0xFF3D3D3D) : const Color(0xFFD1D1D6);
  Color get segmentOn => dark ? const Color(0xFF4A4A4A) : Colors.white;
  Color get rowHover => dark ? colors.fill : const Color(0xFFF7F7F9);
  Color get secondaryHover =>
      dark ? colors.accentTint : const Color(0xFFD6EBE6);
  Color get dangerFill => dark ? const Color(0xFFB2423E) : colors.destructive;
  Color get dangerHover =>
      dark ? const Color(0xFFA33C38) : const Color(0xFFB80012);
  Color get disabledBackground => dark ? colors.fill : const Color(0xFFEDEDF0);
  Color get disabledText =>
      dark ? colors.tertiaryLabel : const Color(0xFFAEAEB2);

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
        color: color ?? colors.label,
      );
  TextStyle get h1 =>
      style(38, weight: FontWeight.w700, height: 1.1, spacing: -.912);
  TextStyle get h2 =>
      style(26, weight: FontWeight.w700, height: 1.2, spacing: -.468);
  TextStyle get h3 =>
      style(20, weight: FontWeight.w700, height: 1.3, spacing: -.24);
  TextStyle get qtext =>
      style(27, weight: FontWeight.w600, height: 1.38, spacing: -.432);
  TextStyle get big =>
      style(40, weight: FontWeight.w700, height: 1.05, spacing: -1.2)
          .copyWith(fontFeatures: [const FontFeature.tabularFigures()]);
  TextStyle get sub => style(15, height: 1.45, color: colors.secondaryLabel);
  TextStyle get sm => style(13, height: 1.45, color: colors.secondaryLabel);
  TextStyle get eb => style(
        13,
        weight: FontWeight.w600,
        spacing: .26,
        color: colors.secondaryLabel,
      );
}

extension WebTokensContext on BuildContext {
  WebTokens get webTokens => WebTokens(Theme.of(this).brightness);
}
