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

  group('recommendation buckets at the ₱999 crossover', () {
    final today = DateTime(2026, 8, 4);

    test('no exam date recommends Monthly, not Yearly', () {
      expect(
        recommendedSkuForExamDate(today: today),
        PaywallSku.monthly,
      );
    });

    test('a past exam date recommends Monthly', () {
      expect(
        recommendedSkuForExamDate(
          today: today,
          examDate: DateTime(2026, 7),
        ),
        PaywallSku.monthly,
      );
    });

    test('21 days out recommends Weekly', () {
      expect(
        recommendedSkuForExamDate(
          today: today,
          examDate: DateTime(2026, 8, 25),
        ),
        PaywallSku.weekly,
      );
    });

    test('22 days out recommends Monthly', () {
      expect(
        recommendedSkuForExamDate(
          today: today,
          examDate: DateTime(2026, 8, 26),
        ),
        PaywallSku.monthly,
      );
    });

    test('six months out recommends Monthly, which the old buckets got wrong',
        () {
      expect(
        recommendedSkuForExamDate(
          today: today,
          examDate: DateTime(2027, 2, 4),
        ),
        PaywallSku.monthly,
      );
    });

    test('ten months out still recommends Monthly', () {
      expect(
        recommendedSkuForExamDate(
          today: today,
          examDate: DateTime(2027, 6, 4),
        ),
        PaywallSku.monthly,
      );
    });

    test('eleven months out recommends Yearly', () {
      expect(
        recommendedSkuForExamDate(
          today: today,
          examDate: DateTime(2027, 7, 4),
        ),
        PaywallSku.yearly,
      );
    });
  });
}
