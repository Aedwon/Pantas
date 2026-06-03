import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
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

  test('no letterspaced all-caps label styles remain', () {
    final s = AppTextStyles.create();
    expect(s.labelSmall.letterSpacing, isNull);
  });
}
