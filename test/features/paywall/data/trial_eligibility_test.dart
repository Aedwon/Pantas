import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/paywall_recommendation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  const free = PricingPhase(
    Period(PeriodUnit.day, 7, 'P7D'),
    RecurrenceMode.finiteRecurring,
    1,
    Price('Free', 0, 'PHP'),
    OfferPaymentMode.freeTrial,
  );

  StoreProduct product(String id, {bool offer = false}) => StoreProduct(
        id,
        'Subscription',
        'Pro',
        99,
        '₱99',
        'PHP',
        subscriptionOptions: [
          SubscriptionOption(
            offer ? 'monthly:trial' : 'base',
            id,
            id.split(':').first,
            offer ? [free] : [],
            const [],
            !offer,
            const Period(PeriodUnit.month, 1, 'P1M'),
            false,
            null,
            offer ? free : null,
            null,
            null,
            null,
          ),
        ],
      );

  test('AC-9 Monthly shows a trial only when Play offers a free phase', () {
    for (final id in ['pantas_pro_monthly', 'pantas_cs_monthly:monthly']) {
      expect(revenueCatProductSnapshot(product(id)).trialEligible, isFalse);
      expect(
        revenueCatProductSnapshot(product(id, offer: true)).trialEligible,
        isTrue,
      );
    }
  });

  test('AC-9 Weekly and Yearly never display a trial even with a stray offer',
      () {
    for (final id in ['pantas_pro_weekly', 'pantas_cs_yearly']) {
      expect(
        revenueCatProductSnapshot(product(id, offer: true)).trialEligible,
        isFalse,
      );
    }
  });

  test('AC-9 Monthly CTA never promises a trial without store eligibility', () {
    final eligible = revenueCatProductSnapshot(
      product('pantas_pro_monthly', offer: true),
    );
    final ineligible = revenueCatProductSnapshot(product('pantas_pro_monthly'));
    PaywallPackage package(RevenueCatProductSnapshot snapshot) =>
        PaywallPackage(
          sku: PaywallSku.monthly,
          productId: snapshot.productId,
          priceString: snapshot.priceString,
          priceAmount: snapshot.priceAmount,
          trialEligible: snapshot.trialEligible,
        );
    expect(ctaCopyFor(package(eligible)), 'Start my free trial');
    expect(ctaCopyFor(package(ineligible)), 'Get Pro. ₱99 a month.');
  });
}
