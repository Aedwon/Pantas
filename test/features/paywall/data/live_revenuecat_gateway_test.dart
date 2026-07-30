import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('skuFromProductId', () {
    test('maps the three settled product ids', () {
      expect(skuFromProductId('pro_weekly'), PaywallSku.weekly);
      expect(skuFromProductId('pro_monthly'), PaywallSku.monthly);
      expect(skuFromProductId('pro_yearly'), PaywallSku.yearly);
    });

    test('an unknown product id maps to null rather than to a guess', () {
      expect(skuFromProductId('pro_lifetime'), isNull);
      expect(skuFromProductId(''), isNull);
      expect(skuFromProductId('cse_cet_pro_monthly'), isNull);
    });

    test('a Play base plan suffix still resolves', () {
      expect(
        skuFromProductId('pro_monthly:monthly-autorenewing'),
        PaywallSku.monthly,
      );
    });
  });

  group('planForSku', () {
    test('each SKU has exactly one plan', () {
      expect(planForSku(PaywallSku.weekly), EntitlementPlan.weekly);
      expect(planForSku(PaywallSku.monthly), EntitlementPlan.monthly);
      expect(planForSku(PaywallSku.yearly), EntitlementPlan.yearly);
    });
  });

  test('a package carries the numeric price as well as the display string', () {
    const package = PaywallPackage(
      sku: PaywallSku.monthly,
      productId: 'pro_monthly',
      priceString: '₱99.00',
      priceAmount: 99,
    );
    expect(package.priceAmount, 99);
    expect(package.priceString, '₱99.00');
  });
}
