import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new dimension tokens', () {
    expect(AppDimensions.radiusButton, 5);
    expect(AppDimensions.radiusSurface, 8);
    expect(AppDimensions.hairline, 1.0);
    expect(AppDimensions.progressHeight, 3.0);
  });

  test('themes use paper/ink scaffold backgrounds', () {
    expect(
      buildLightTheme().scaffoldBackgroundColor,
      AppColors.light.background,
    );
    expect(buildDarkTheme().scaffoldBackgroundColor, AppColors.dark.background);
  });

  test('light scheme overrides Material-seeded colors with identity tokens',
      () {
    final scheme = buildLightTheme().colorScheme;
    const c = AppColors.light;
    expect(scheme.primary, c.board);
    expect(scheme.onPrimary, c.onBoard);
    expect(scheme.surface, c.surface);
    expect(scheme.onSurface, c.ink);
    expect(scheme.error, c.rust);
    expect(scheme.outline, c.rule);
    expect(scheme.surfaceTint, Colors.transparent);
  });

  test('dark scheme overrides Material-seeded colors with identity tokens',
      () {
    final scheme = buildDarkTheme().colorScheme;
    const c = AppColors.dark;
    expect(scheme.primary, c.board);
    expect(scheme.onPrimary, c.onBoard);
    expect(scheme.surface, c.surface);
    expect(scheme.onSurface, c.ink);
    expect(scheme.error, c.rust);
    expect(scheme.outline, c.rule);
    expect(scheme.surfaceTint, Colors.transparent);
  });

  test('dark theme sets adaptive visual density', () {
    expect(
      buildDarkTheme().visualDensity,
      VisualDensity.adaptivePlatformDensity,
    );
  });
}
