import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/pantas_shape.dart';

void main() {
  test('shape tokens match README and floating board variants', () {
    expect(PantasShape.groupRadius, 14);
    expect(PantasShape.cardRadius, 18);
    expect(PantasShape.floatingRadius, 22);
    expect(PantasShape.floatingRadiusLarge, 24);
    expect(PantasShape.pillRadius, 99);
    expect(PantasShape.buttonHeight, 52);
    expect(PantasShape.buttonRadius, 14);
    expect(PantasShape.rowMinHeight, 44);
    expect(PantasShape.rowInset, 16);
    expect(PantasShape.gutter, 16);
  });
}
