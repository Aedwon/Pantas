import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('display and headline styles use Source Serif 4', () {
    final s = AppTextStyles.create();
    expect(s.displayLarge.fontFamily, 'SourceSerif4');
    expect(s.displaySmall.fontFamily, 'SourceSerif4');
    expect(s.headlineMedium.fontFamily, 'SourceSerif4');
    expect(s.headlineSmall.fontFamily, 'SourceSerif4');
    expect(s.mathBody.fontFamily, 'SourceSerif4');
  });

  test('body and label styles use Source Sans 3', () {
    final s = AppTextStyles.create();
    expect(s.bodyLarge.fontFamily, 'SourceSans3');
    expect(s.bodyMedium.fontFamily, 'SourceSans3');
    expect(s.bodySmall.fontFamily, 'SourceSans3');
    expect(s.labelLarge.fontFamily, 'SourceSans3');
    expect(s.labelSmall.fontFamily, 'SourceSans3');
  });

  test('includes the five 4 August amended type sizes', () {
    final s = AppTextStyles.create();
    expect(s.displayMedium.fontSize, 24);
    expect(s.displayMedium.fontFamily, 'SourceSerif4');
    expect(s.displayMedium.fontWeight, FontWeight.w700);
    expect(s.displayMedium.height, 1.2);
    expect(s.displayMedium.letterSpacing, -0.2);

    expect(s.headlineLarge.fontSize, 16);
    expect(s.headlineLarge.fontFamily, 'SourceSerif4');
    expect(s.headlineLarge.fontWeight, FontWeight.w700);
    expect(s.headlineLarge.height, 1.3);

    expect(s.titleSmall.fontSize, 14);
    expect(s.titleSmall.fontFamily, 'SourceSerif4');
    expect(s.titleSmall.fontWeight, FontWeight.w700);
    expect(s.titleSmall.height, 1.45);

    expect(s.bodyRegular.fontSize, 13);
    expect(s.bodyRegular.fontFamily, 'SourceSans3');
    expect(s.bodyRegular.fontWeight, FontWeight.w400);
    expect(s.bodyRegular.height, 1.5);

    expect(s.captionSmall.fontSize, 11.5);
    expect(s.captionSmall.fontFamily, 'SourceSans3');
    expect(s.captionSmall.fontWeight, FontWeight.w400);
    expect(s.captionSmall.height, 1.5);

    expect(s.headlineSmall.fontSize, 15);
  });
}
