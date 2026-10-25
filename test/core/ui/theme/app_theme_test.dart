import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

void main() {
  test('themes use paper/ink scaffold backgrounds', () {
    expect(
      buildLightTheme().scaffoldBackgroundColor,
      PantasColors.light.background,
    );
    expect(
      buildDarkTheme().scaffoldBackgroundColor,
      PantasColors.dark.background,
    );
  });

  test('light scheme overrides Material-seeded colors with identity tokens',
      () {
    final scheme = buildLightTheme().colorScheme;
    const c = PantasColors.light;
    expect(scheme.primary, c.accent);
    expect(scheme.onPrimary, c.surface);
    expect(scheme.surface, c.surface);
    expect(scheme.onSurface, c.label);
    expect(scheme.error, c.destructive);
    expect(scheme.outline, c.separator);
    expect(scheme.surfaceTint, Colors.transparent);
  });

  test('dark scheme overrides Material-seeded colors with identity tokens', () {
    final scheme = buildDarkTheme().colorScheme;
    const c = PantasColors.dark;
    expect(scheme.primary, c.accent);
    expect(scheme.onPrimary, c.surface);
    expect(scheme.surface, c.surface);
    expect(scheme.onSurface, c.label);
    expect(scheme.error, c.destructive);
    expect(scheme.outline, c.separator);
    expect(scheme.surfaceTint, Colors.transparent);
  });

  test('dark theme sets adaptive visual density', () {
    expect(
      buildDarkTheme().visualDensity,
      VisualDensity.adaptivePlatformDensity,
    );
  });

  test('app bar is flat paper with ink title', () {
    final theme = buildLightTheme();
    const c = PantasColors.light;
    final appBar = theme.appBarTheme;
    expect(appBar.backgroundColor, c.background);
    expect(appBar.surfaceTintColor, Colors.transparent);
    expect(appBar.elevation, 0);
    expect(appBar.scrolledUnderElevation, 0);
    expect(appBar.centerTitle, false);
    expect(appBar.titleTextStyle?.color, c.label);
  });

  test('dividers use the separator width', () {
    final divider = buildLightTheme().dividerTheme;
    expect(divider.color, PantasColors.light.separator);
    expect(divider.thickness, 0.5);
  });

  test('dialogs and sheets are flat identity surfaces', () {
    final theme = buildDarkTheme();
    const c = PantasColors.dark;
    expect(theme.dialogTheme.backgroundColor, c.surface);
    expect(
      theme.dialogTheme.shape,
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    );
    expect(theme.bottomSheetTheme.backgroundColor, c.background);
    expect(theme.bottomSheetTheme.surfaceTintColor, Colors.transparent);
  });
}
