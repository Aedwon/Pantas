import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/web_page_transitions.dart';
import 'package:pantas/core/ui/theme/component_themes.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

// Lets every `context.colors` caller read the screen-facing color names.
export 'package:pantas/core/ui/theme/theme_names.dart';

ThemeData buildLightTheme({bool web = kIsWeb}) => _buildTheme(
      PantasColors.light,
      Brightness.light,
      web: web || kIsWeb,
    );

ThemeData buildDarkTheme({bool web = kIsWeb}) => _buildTheme(
      PantasColors.dark,
      Brightness.dark,
      web: web || kIsWeb,
    );

ThemeData _buildTheme(
  PantasColors colors,
  Brightness brightness, {
  required bool web,
}) {
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
  final type = PantasTypeBundle.create(colors: colors);
  final themes = PantasComponentThemes(colors, brightness);
  return ThemeData(
    pageTransitionsTheme: web ? webPageTransitionsTheme : null,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: colors.surfaceHover,
    textButtonTheme: themes.textButton,
    filledButtonTheme: themes.filledButton,
    elevatedButtonTheme: themes.elevatedButton,
    outlinedButtonTheme: themes.outlinedButton,
    iconButtonTheme: themes.iconButton,
    inputDecorationTheme: themes.inputDecoration,
    tooltipTheme: themes.tooltip,
    snackBarTheme: themes.snackBar,
    listTileTheme: themes.listTile,
    progressIndicatorTheme: themes.progressIndicator,
    checkboxTheme: themes.checkbox,
    radioTheme: themes.radio,
    switchTheme: themes.switchTheme,
    sliderTheme: themes.slider,
    chipTheme: themes.chip,
    popupMenuTheme: themes.popupMenu,
    floatingActionButtonTheme: themes.floatingActionButton,
    dropdownMenuTheme: themes.dropdownMenu,
    menuTheme: themes.menu,
    menuButtonTheme: themes.menuButton,
    bottomSheetTheme: themes.bottomSheet,
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
    dialogTheme: themes.dialog,
    fontFamily: 'Geist',
    extensions: [colors, type],
  );
}

extension AppThemeContext on BuildContext {
  PantasColors get colors {
    final theme = Theme.of(this);
    return theme.extension<PantasColors>()!;
  }

  PantasTypeBundle get type =>
      Theme.of(this).extension<PantasTypeBundle>() ??
      PantasTypeBundle.create(colors: colors);
}
