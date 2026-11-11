import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

void main() {
  test('wholePesos drops .00 and keeps real centavos', () {
    expect(wholePesos('₱149.00'), '₱149');
    expect(wholePesos('₱1,499.00'), '₱1,499');
    expect(wholePesos('₱149.50'), '₱149.50');
    expect(wholePesos('₱149'), '₱149');
    expect(wholePesos('PHP 149.00'), 'PHP 149');
  });
}
