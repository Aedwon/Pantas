import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/theme/pantas_shape.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

ThemeData buildLightTheme({bool web = kIsWeb}) => _buildTheme(
      web ? const WebTokens(Brightness.light).colors : PantasColors.light,
      Brightness.light,
    );

ThemeData buildDarkTheme({bool web = kIsWeb}) => _buildTheme(
      web ? const WebTokens(Brightness.dark).colors : PantasColors.dark,
      Brightness.dark,
    );

ThemeData _buildTheme(PantasColors colors, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: colors.accent,
    brightness: brightness,
  ).copyWith(
    primary: colors.accent,
    onPrimary: colors.surface,
    secondary: colors.accent,
    onSecondary: colors.surface,
    surface: colors.surface,
    onSurface: colors.label,
    error: colors.destructive,
    onError: colors.surface,
    outline: colors.separator,
    outlineVariant: colors.fill,
    surfaceTint: Colors.transparent,
  );
  final type = PantasType.create(colors: colors);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.label,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: type.sectionHero.copyWith(color: colors.label),
      iconTheme: IconThemeData(color: colors.secondaryLabel, size: 20),
    ),
    dividerTheme: DividerThemeData(
      color: colors.separator,
      thickness: 0.5,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(PantasShape.groupRadius)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PantasShape.groupRadius),
        ),
      ),
    ),
    fontFamily: 'Geist',
    extensions: [colors, type],
  );
}

extension AppThemeContext on BuildContext {
  PantasColors get colors {
    final theme = Theme.of(this);
    return theme.extension<PantasColors>()!;
  }

  PantasType get type =>
      Theme.of(this).extension<PantasType>() ??
      PantasType.create(colors: colors);
}
