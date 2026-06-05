import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme() => _buildTheme(AppColors.light, Brightness.light);

ThemeData buildDarkTheme() => _buildTheme(AppColors.dark, Brightness.dark);

ThemeData _buildTheme(AppColors colors, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1D5C50),
    brightness: brightness,
  ).copyWith(
    primary: colors.board,
    onPrimary: colors.onBoard,
    secondary: colors.board,
    onSecondary: colors.onBoard,
    surface: colors.surface,
    onSurface: colors.ink,
    error: colors.rust,
    onError: colors.onBoard,
    outline: colors.rule,
    outlineVariant: colors.ruleFaint,
    surfaceTint: Colors.transparent,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: [colors, AppTextStyles.create()],
  );
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppTextStyles get textStyles => Theme.of(this).extension<AppTextStyles>()!;
}
