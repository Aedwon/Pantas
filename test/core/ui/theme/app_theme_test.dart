import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new dimension tokens', () {
    expect(AppDimensions.radiusButton, 5);
    expect(AppDimensions.radiusSurface, 8);
    expect(AppDimensions.hairline, 1.0);
    expect(AppDimensions.progressHeight, 3.0);
  });

  test('themes use paper/ink scaffold backgrounds', () {
    expect(buildLightTheme().scaffoldBackgroundColor, AppColors.light.background);
    expect(buildDarkTheme().scaffoldBackgroundColor, AppColors.dark.background);
  });
}
