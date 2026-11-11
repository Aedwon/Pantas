import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

void main() {
  // The design system 4.0 duration table. The hover fade is 150 ms (D93); the
  // Nov 3 motion preview had 160 ms.
  test('the table is exactly the approved one', () {
    expect(PantasDurations.short1, const Duration(milliseconds: 120));
    expect(PantasDurations.short2, const Duration(milliseconds: 150));
    expect(PantasDurations.short3, const Duration(milliseconds: 180));
    expect(PantasDurations.medium1, const Duration(milliseconds: 240));
    expect(PantasDurations.medium2, const Duration(milliseconds: 320));
  });

  test('the names run from quickest to slowest', () {
    expect(PantasDurations.short1, lessThan(PantasDurations.short2));
    expect(PantasDurations.short2, lessThan(PantasDurations.medium1));
    expect(PantasDurations.medium1, lessThan(PantasDurations.medium2));
  });
}
