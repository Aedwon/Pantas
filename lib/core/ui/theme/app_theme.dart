import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';
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
  final textStyles = AppTextStyles.create();
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textStyles.headlineMedium.copyWith(color: colors.ink),
      iconTheme: IconThemeData(color: colors.inkMuted, size: 20),
    ),
    dividerTheme: DividerThemeData(
      color: colors.rule,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
    ),
    extensions: [colors, textStyles],
  );
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppTextStyles get textStyles => Theme.of(this).extension<AppTextStyles>()!;
}
