import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTextStyles.create()', () {
    testWidgets('displayLarge is 28sp weight 700', (tester) async {
      final styles = AppTextStyles.create();
      expect(styles.displayLarge.fontSize, 28);
      expect(styles.displayLarge.fontWeight, FontWeight.w700);
    });

    testWidgets('displaySmall is 22sp weight 700', (tester) async {
      final styles = AppTextStyles.create();
      expect(styles.displaySmall.fontSize, 22);
      expect(styles.displaySmall.fontWeight, FontWeight.w700);
    });

    testWidgets('bodyLarge is 16sp weight 500', (tester) async {
      final styles = AppTextStyles.create();
      expect(styles.bodyLarge.fontSize, 16);
      expect(styles.bodyLarge.fontWeight, FontWeight.w500);
    });

    testWidgets('bodyMedium is 14sp weight 400', (tester) async {
      final styles = AppTextStyles.create();
      expect(styles.bodyMedium.fontSize, 14);
      expect(styles.bodyMedium.fontWeight, FontWeight.w400);
    });

    testWidgets('labelSmall has 0.5 letter spacing', (tester) async {
      final styles = AppTextStyles.create();
      expect(styles.labelSmall.letterSpacing, 0.5);
    });

    testWidgets('mathBody uses notoSerif font family', (tester) async {
      final styles = AppTextStyles.create();
      expect(styles.mathBody.fontFamily, contains('NotoSerif'));
    });
  });

  group('AppTextStyles.copyWith', () {
    testWidgets('copies with overridden displayLarge', (tester) async {
      final styles = AppTextStyles.create();
      final copy = styles.copyWith(
        displayLarge: const TextStyle(fontSize: 99),
      );
      expect(copy.displayLarge.fontSize, 99);
      expect(copy.bodyMedium.fontSize, styles.bodyMedium.fontSize);
    });
  });
}
