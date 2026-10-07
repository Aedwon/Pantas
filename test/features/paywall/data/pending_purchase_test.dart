import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';

import 'live_revenuecat_gateway_hardening_test.dart';

void main() {
  late Map<String, String> values;
  late DateTime now;
  setUp(() {
    values = {};
    now = DateTime.utc(2026, 10, 7);
  });
  PendingPurchaseStore store() => PendingPurchaseStore(
        readValue: (key) async => values[key],
        writeValue: (key, value) async => values[key] = value,
      );
  Future<LiveRevenueCatGateway> gateway(_PendingSdk sdk, String uid) async {
    final result = LiveRevenueCatGateway(
      sdk: sdk,
      pendingStore: store(),
      referenceTime: () => now,
    );
    await result.logIn(uid);
    return result;
  }

  test('pending payment blocks another purchase and survives a restart',
      () async {
    final sdk = _PendingSdk();
    final first = await gateway(sdk, 'account-a');
    expect(
      (await first.purchase(monthlyPackage)).result,
      PaymentResult.pending,
    );
    expect((await first.purchase(yearlyPackage)).result, PaymentResult.pending);
    expect(sdk.purchases, 1);
    final marker = await store().read('account-a');
    expect(marker!.uid, 'account-a');
    expect(marker.productId, monthlyPackage.productId);
    expect(marker.startedAt, now);
    final nextSdk = _PendingSdk();
    final restarted = await gateway(nextSdk, 'account-a');
    expect(
      (await restarted.purchase(monthlyPackage)).result,
      PaymentResult.pending,
    );
    expect(nextSdk.purchases, 0);
  });

  test('a different account never sees or inherits the pending block',
      () async {
    final first = await gateway(_PendingSdk(), 'account-a');
    await first.purchase(monthlyPackage);
    final sdk = _PendingSdk();
    final second = await gateway(sdk, 'account-b');
    await second.purchase(monthlyPackage);
    expect(sdk.purchases, 1);
    expect((await store().read('account-a'))!.uid, 'account-a');
    expect((await store().read('account-b'))!.uid, 'account-b');
  });

  test('target activation clears its marker but another product does not',
      () async {
    final sdk = _PendingSdk();
    final result = await gateway(sdk, 'account-a');
    await result.purchase(monthlyPackage);
    sdk.customerInfo = const RevenueCatCustomerInfoSnapshot.active(
      productId: 'pantas_cs_monthly',
    );
    await result.configure(androidApiKey: 'test-only-key');
    expect(await store().read('account-a'), isNotNull);
    sdk.customerInfo = const RevenueCatCustomerInfoSnapshot.active(
      productId: 'pantas_pro_monthly',
    );
    await result.configure(androidApiKey: 'test-only-key');
    expect(await store().read('account-a'), isNull);
    sdk.pending = false;
    expect(
      (await result.purchase(monthlyPackage)).result,
      PaymentResult.success,
    );
  });

  test('Restore before and exactly 72 hours keeps the marker', () async {
    final sdk = _PendingSdk();
    final result = await gateway(sdk, 'account-a');
    await result.purchase(monthlyPackage);
    now = now.add(const Duration(hours: 71));
    expect((await result.restorePurchases()).result, PaymentResult.pending);
    expect(await store().read('account-a'), isNotNull);
    now = now.add(const Duration(hours: 1));
    expect((await result.restorePurchases()).result, PaymentResult.pending);
    expect(await store().read('account-a'), isNotNull);
  });

  test('only Restore after 72 hours without entitlement clears the marker',
      () async {
    final sdk = _PendingSdk();
    final result = await gateway(sdk, 'account-a');
    await result.purchase(monthlyPackage);
    now = now.add(const Duration(hours: 73));
    expect(
      (await result.purchase(monthlyPackage)).result,
      PaymentResult.pending,
    );
    expect(sdk.purchases, 1);
    expect(
      (await result.restorePurchases()).status,
      PaymentOperationStatus.noActiveSubscription,
    );
    expect(await store().read('account-a'), isNull);
    await result.purchase(monthlyPackage);
    expect(sdk.purchases, 2);
  });

  test('Restore error never clears an old marker', () async {
    final sdk = _PendingSdk();
    final result = await gateway(sdk, 'account-a');
    await result.purchase(monthlyPackage);
    now = now.add(const Duration(hours: 73));
    sdk.restoreFailure = RevenueCatFailureKind.network;
    expect((await result.restorePurchases()).result, PaymentResult.offline);
    expect(await store().read('account-a'), isNotNull);
  });
}

class _PendingSdk extends FakeRevenueCatSdk {
  bool pending = true;
  int purchases = 0;

  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(
    String productId, {
    String? oldProductId,
    bool allowTrial = true,
  }) async {
    purchases++;
    if (pending) {
      throw const RevenueCatSdkException(RevenueCatFailureKind.pending);
    }
    return RevenueCatCustomerInfoSnapshot.active(productId: productId);
  }
}
