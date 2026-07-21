import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every role uses the one family', () {
    // Aedwon chose one font everywhere on 10 August: the serif was an
    // eyesore, and a reader noticing the type is not reading the lesson.
    final s = AppTextStyles.create();
    expect(s.displayLarge.fontFamily, 'SourceSans3');
    expect(s.displaySmall.fontFamily, 'SourceSans3');
    expect(s.headlineMedium.fontFamily, 'SourceSans3');
    expect(s.headlineSmall.fontFamily, 'SourceSans3');
    expect(s.mathBody.fontFamily, 'SourceSans3');
  });

  test('body and label styles use the same family as the headings', () {
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
    expect(s.displayMedium.fontFamily, 'SourceSans3');
    expect(s.displayMedium.fontWeight, FontWeight.w700);
    expect(s.displayMedium.height, 1.2);
    // Tracked tighter than a default now that size and weight are the only
    // things separating a heading from a paragraph.
    expect(s.displayMedium.letterSpacing, -0.4);

    expect(s.headlineLarge.fontSize, 16);
    expect(s.headlineLarge.fontFamily, 'SourceSans3');
    expect(s.headlineLarge.fontWeight, FontWeight.w700);
    expect(s.headlineLarge.height, 1.3);

    expect(s.titleSmall.fontSize, 14);
    expect(s.titleSmall.fontFamily, 'SourceSans3');
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

  test('no role is left pointing at the retired serif', () {
    // The family is gone from the bundle, so a stray reference would fall
    // back to the platform default, which is the one look this app is not.
    final s = AppTextStyles.create();
    final every = [
      s.displayLarge,
      s.displayMedium,
      s.displaySmall,
      s.headlineLarge,
      s.headlineMedium,
      s.headlineSmall,
      s.titleSmall,
      s.bodyLarge,
      s.bodyMedium,
      s.bodyRegular,
      s.bodySmall,
      s.captionSmall,
      s.labelLarge,
      s.labelSmall,
      s.mathBody,
    ];
    for (final style in every) {
      expect(style.fontFamily, 'SourceSans3');
    }
  });
}
