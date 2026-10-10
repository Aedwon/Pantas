import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

void main() {
  test('every old role maps to the new type tokens', () {
    final t = PantasType.create();
    final s = AppTextStyles.create(type: t);
    expect(s.displayLarge, t.largeTitle);
    expect(s.displayMedium, t.pageTitle);
    expect(s.displaySmall, t.sectionHero);
    expect(s.headlineLarge, t.sectionHero);
    expect(s.headlineMedium, t.sectionHero);
    expect(s.headlineSmall, t.emphasized);
    expect(s.titleSmall, t.subheadStrong);
    expect(s.bodyLarge, t.body);
    expect(s.bodyMedium, t.subhead);
    expect(s.bodyRegular, t.body);
    expect(s.bodySmall, t.subhead);
    expect(s.captionSmall, t.caption);
    expect(s.labelLarge, t.sectionHeader);
    expect(s.labelSmall, t.footnote);
    expect(s.mathBody, t.mathSerif);
  });
}
