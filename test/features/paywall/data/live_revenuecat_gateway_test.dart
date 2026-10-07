import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

void main() {
  group('skuFromProductId', () {
    test('maps the three settled product ids', () {
      expect(skuFromProductId('pantas_pro_weekly'), PaywallSku.weekly);
      expect(skuFromProductId('pantas_pro_monthly'), PaywallSku.monthly);
      expect(skuFromProductId('pantas_pro_yearly'), PaywallSku.yearly);
    });

    test('Civil Service subscriptions resolve to their store periods', () {
      expect(skuFromProductId('pantas_cs_weekly'), PaywallSku.weekly);
      expect(skuFromProductId('pantas_cs_monthly:monthly'), PaywallSku.monthly);
      expect(skuFromProductId('pantas_cs_yearly'), PaywallSku.yearly);
    });

    test('an unknown product id maps to null rather than to a guess', () {
      expect(skuFromProductId('pantas_pro_lifetime'), isNull);
      expect(skuFromProductId(''), isNull);
      expect(skuFromProductId('cse_cet_pro_monthly'), isNull);
      // The names carried before 12 August. They are not the products.
      expect(skuFromProductId('pro_monthly'), isNull);
    });

    test('a Play base plan suffix still resolves', () {
      expect(
        skuFromProductId('pantas_pro_monthly:monthly-autorenewing'),
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
      productId: 'pantas_pro_monthly',
      priceString: '₱99.00',
      priceAmount: 99,
    );
    expect(package.priceAmount, 99);
    expect(package.priceString, '₱99.00');
  });
}
