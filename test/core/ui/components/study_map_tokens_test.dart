import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

void main() {
  test('October 12 on-fill label has the approved colors and readable contrast',
      () {
    expect(PantasColors.light.onFillLabel.toARGB32(), 0xff636366);
    expect(PantasColors.dark.onFillLabel.toARGB32(), 0xffa3a3a3);
    for (final c in [PantasColors.light, PantasColors.dark]) {
      final a = c.onFillLabel.computeLuminance();
      final b = c.fill.computeLuminance();
      expect(
        a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}
