import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const weekly = PaywallPackage(
    sku: PaywallSku.weekly,
    productId: 'pro_weekly',
    priceString: '₱29',
  );
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pro_monthly',
    priceString: '₱99',
  );
  const yearly = PaywallPackage(
    sku: PaywallSku.yearly,
    productId: 'pro_yearly',
    priceString: '₱499',
  );
  test('CTA copy matches weekly monthly yearly selections', () {
    expect(ctaCopyFor(weekly), 'Get Pro - ₱29/week');
    expect(ctaCopyFor(monthly), 'Get Pro - ₱99/month');
    expect(ctaCopyFor(yearly), 'Start 7-day free trial');
  });

  test('badge copy distinguishes no-date recommendation', () {
    expect(
      recommendationBadgeCopy(
        recommended: PaywallSku.yearly,
        hasExamDate: false,
      ),
      'Best value for most',
    );
    expect(
      recommendationBadgeCopy(
        recommended: PaywallSku.monthly,
        hasExamDate: true,
      ),
      'Best for your exam date',
    );
  });

  test('packages are sorted weekly monthly yearly', () {
    final sorted = paywallDisplayOrder([monthly, weekly, yearly]);

    expect(
      sorted.map((package) => package.productId),
      ['pro_weekly', 'pro_monthly', 'pro_yearly'],
    );
  });
}
