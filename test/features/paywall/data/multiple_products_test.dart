import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  test('AC-7 a promotional pro grant never becomes a known subscription', () {
    final end = DateTime.utc(2026, 11, 7);
    final entitlement = entitlementFromCustomerInfo(
      RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
        expiresAt: end,
        promotions: [CoveragePeriod(id: 'pro', endsAt: end)],
      ),
    );
    expect(entitlement.state, EntitlementState.unknown);
    expect(
      entitlement.coversExam(
        'exam_upcat',
        examTier: PriceTier.student,
        at: DateTime.utc(2026, 10, 7),
      ),
      isFalse,
    );
  });

  test('AC-7 a real subscription survives overlap with a known giveaway', () {
    final end = DateTime.utc(2026, 11, 7);
    final entitlement = entitlementFromCustomerInfo(
      RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_cs_monthly',
        subscriptions: [
          RevenueCatSubscriptionSnapshot(
            productId: 'pantas_cs_monthly',
            expiresAt: end,
          ),
        ],
        promotions: [CoveragePeriod(id: 'promo_student', endsAt: end)],
      ),
    );
    expect(entitlement.state, EntitlementState.active);
    expect(
      entitlement.coversExam(
        'exam_cse_pro',
        examTier: PriceTier.civilService,
        at: DateTime.utc(2026, 10, 7),
      ),
      isTrue,
    );
  });

  test('all active products and purchase history survive SDK projection', () {
    const info = CustomerInfo(
      EntitlementInfos({}, {}),
      {},
      ['pantas_pro_yearly', 'pantas_cs_monthly'],
      ['pantas_pro_yearly', 'pantas_cs_monthly', 'pantas_pass_cse_pro'],
      [
        StoreTransaction(
          'transaction',
          'pantas_pass_cse_pro',
          '2026-10-01',
        ),
      ],
      '2026-01-01T00:00:00Z',
      'test-firebase-user',
      {
        'pantas_pro_yearly': '2027-10-01T00:00:00Z',
        'pantas_cs_monthly': '2026-11-01T00:00:00Z',
      },
      '2026-10-07T00:00:00Z',
      subscriptionsByProductIdentifier: {
        'pantas_cs_monthly': SubscriptionInfo(
          'pantas_cs_monthly',
          '2026-10-01T00:00:00Z',
          false,
          true,
          false,
          expiresDate: '2026-11-01T00:00:00Z',
          billingIssuesDetectedAt: '2026-10-06T00:00:00Z',
        ),
      },
    );
    final snapshot = revenueCatCustomerInfoSnapshot(info);
    expect(
      snapshot.subscriptions.map((source) => source.productId),
      ['pantas_pro_yearly', 'pantas_cs_monthly'],
    );
    expect(snapshot.nonSubscriptionPurchases, ['pantas_pass_cse_pro']);
    final entitlement = entitlementFromCustomerInfo(snapshot);
    expect(entitlement.tier, PriceTier.civilService);
    expect(entitlement.plan, EntitlementPlan.monthly);
    expect(entitlement.state, EntitlementState.billingIssue);
    expect(entitlement.passes, isEmpty);
    expect(entitlement.subscriptions, hasLength(2));
    expect(entitlement.endsAt, DateTime.utc(2027, 10));
    expect(
      entitlement.coversExam(
        'exam_cse_pro',
        examTier: PriceTier.civilService,
        at: DateTime.utc(2026, 10, 7),
      ),
      isTrue,
    );
  });
}
