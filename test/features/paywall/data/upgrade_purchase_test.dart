import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  Package package(String id) => Package(
        id,
        PackageType.custom,
        StoreProduct(
          id,
          'Pro',
          'Pro',
          149,
          '₱149',
          'PHP',
          subscriptionOptions: [
            SubscriptionOption(
              'base',
              id,
              id,
              const [],
              const [],
              true,
              const Period(PeriodUnit.month, 1, 'P1M'),
              false,
              null,
              null,
              null,
              null,
              null,
            ),
          ],
        ),
        const PresentedOfferingContext('offering', null, null),
      );

  test('every Student to Civil Service pair credits time and uses no trial',
      () {
    for (final old in [
      'pantas_pro_weekly',
      'pantas_pro_monthly',
      'pantas_pro_yearly',
    ]) {
      for (final next in [
        'pantas_cs_weekly',
        'pantas_cs_monthly',
        'pantas_cs_yearly',
      ]) {
        final params = purchaseParamsFor(
          package(next),
          oldProductId: old,
          allowTrial: false,
        );
        expect(params.productChangeInfo!.oldProductIdentifier, old);
        expect(
          params.productChangeInfo!.replacementMode,
          StoreReplacementMode.withTimeProration,
        );
        expect(params.subscriptionOption!.isBasePlan, isTrue);
        expect(params.subscriptionOption!.freePhase, isNull);
      }
    }
  });
}
