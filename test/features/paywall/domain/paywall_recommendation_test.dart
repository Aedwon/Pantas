import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
  const lifetime = PaywallPackage(
    sku: PaywallSku.lifetime,
    productId: 'pro_lifetime',
    priceString: '₱1,499',
  );

  test('monthly is recommended when exam is less than five months away', () {
    final sku = recommendedSkuForExamDate(
      today: DateTime.utc(2026, 5, 21),
      examDate: DateTime.utc(2026, 10, 20),
    );

    expect(sku, PaywallSku.monthly);
  });

  test('yearly is recommended from five to twenty four months', () {
    final sku = recommendedSkuForExamDate(
      today: DateTime.utc(2026, 5, 21),
      examDate: DateTime.utc(2026, 10, 21),
    );

    expect(sku, PaywallSku.yearly);
  });

  test('yearly is recommended beyond twenty four months', () {
    final sku = recommendedSkuForExamDate(
      today: DateTime.utc(2026, 5, 21),
      examDate: DateTime.utc(2028, 6, 1),
    );

    expect(sku, PaywallSku.yearly);
  });

  test('yearly is recommended when exam date is missing', () {
    expect(
      recommendedSkuForExamDate(today: DateTime.utc(2026, 5, 21)),
      PaywallSku.yearly,
    );
  });

  test('past exam date is treated as missing', () {
    final sku = recommendedSkuForExamDate(
      today: DateTime.utc(2026, 5, 21),
      examDate: DateTime.utc(2026, 5, 20),
    );

    expect(sku, PaywallSku.yearly);
  });

  test('lifetime is never auto recommended', () {
    final cases = [
      DateTime.utc(2026, 6, 1),
      DateTime.utc(2027, 5, 21),
      DateTime.utc(2030, 5, 21),
    ];

    for (final examDate in cases) {
      expect(
        recommendedSkuForExamDate(
          today: DateTime.utc(2026, 5, 21),
          examDate: examDate,
        ),
        isNot(PaywallSku.lifetime),
      );
    }
  });

  test('CTA copy matches monthly yearly and lifetime selections', () {
    expect(ctaCopyFor(monthly), 'Get Pro - ₱99/month');
    expect(ctaCopyFor(yearly), 'Start 7-day free trial');
    expect(ctaCopyFor(lifetime), 'Get Pro - ₱1,499 one-time');
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

  test('packages are sorted monthly yearly lifetime', () {
    final sorted = paywallDisplayOrder([lifetime, monthly, yearly]);

    expect(
      sorted.map((package) => package.productId),
      ['pro_monthly', 'pro_yearly', 'pro_lifetime'],
    );
  });
}
