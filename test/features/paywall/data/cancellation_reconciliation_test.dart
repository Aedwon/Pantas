import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'live_revenuecat_gateway_hardening_test.dart';

void main() {
  test('AC-3 cancellation stays active through mapping, gateway, and snapshot',
      () async {
    final at = DateTime.utc(2026, 11);
    final end = DateTime.utc(2026, 12);
    final canceled = RevenueCatCustomerInfoSnapshot.active(
      productId: 'pantas_pro_monthly',
      expiresAt: end,
      willRenew: false,
      requestDate: at.add(const Duration(seconds: 1)),
      verification: VerificationResult.verified,
    );
    expect(entitlementFromCustomerInfo(canceled).proIsActive, isTrue);
    final store = EntitlementSnapshotStore.inMemory();
    final sdk = FakeRevenueCatSdk(
      customerInfo: RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
        expiresAt: end,
        requestDate: at,
      ),
      purchaseInfo: canceled,
      restoreInfo: canceled,
    );
    var refreshed = 0;
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      entitlementState: PaymentEntitlementState(store),
      referenceTime: () => at,
      refreshClaims: (uid) async {
        expect(uid, 'test-account');
        refreshed++;
      },
    );
    await gateway.logIn('test-account');
    expect(
      (await gateway.purchase(monthlyPackage)).status,
      PaymentOperationStatus.success,
    );
    expect(gateway.cachedEntitlement?.state, EntitlementState.canceledActive);
    expect((await store.readConfirmed())?.expiresAt, end);
    expect((await store.readConfirmed())?.proIsActive, isTrue);
    await gateway.restorePurchases();
    expect(refreshed, 2);
  });
}
