import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';

void main() {
  // The table printed in the Nov 3 motion preview, item 17.
  test('the table is exactly the approved one', () {
    expect(PantasDurations.tap, const Duration(milliseconds: 120));
    expect(PantasDurations.quick, const Duration(milliseconds: 160));
    expect(PantasDurations.base, const Duration(milliseconds: 240));
    expect(PantasDurations.page, const Duration(milliseconds: 320));
  });

  test('the names run from quickest to slowest', () {
    expect(PantasDurations.tap, lessThan(PantasDurations.quick));
    expect(PantasDurations.quick, lessThan(PantasDurations.base));
    expect(PantasDurations.base, lessThan(PantasDurations.page));
  });
}
