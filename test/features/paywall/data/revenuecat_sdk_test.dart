import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Restore syncs purchases before reading customer info', () async {
    final calls = <String>[];
    const channel = MethodChannel('purchases_flutter');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'syncPurchases') return null;
      return {
        'entitlements': {
          'all': <String, Object>{},
          'active': <String, Object>{},
        },
        'allPurchaseDates': <String, Object>{},
        'activeSubscriptions': <String>[],
        'allPurchasedProductIdentifiers': <String>[],
        'nonSubscriptionTransactions': <Object>[],
        'firstSeen': '2026-10-01T00:00:00Z',
        'originalAppUserId': 'test-only-account',
        'allExpirationDates': <String, Object>{},
        'requestDate': '2026-10-07T00:00:00Z',
      };
    });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await PurchasesRevenueCatSdk().restorePurchases();
    expect(calls, ['syncPurchases', 'getCustomerInfo']);
  });

  test('payment awaiting completion is pending, not a store failure', () {
    expect(
      classifyRevenueCatErrorCode(PurchasesErrorCode.paymentPendingError).name,
      'pending',
    );
  });

  test('RevenueCat SDK error codes map to stable payment failure kinds', () {
    expect(
      classifyRevenueCatErrorCode(PurchasesErrorCode.purchaseCancelledError),
      RevenueCatFailureKind.userCancelled,
    );
    expect(
      classifyRevenueCatErrorCode(PurchasesErrorCode.networkError),
      RevenueCatFailureKind.network,
    );
    expect(
      classifyRevenueCatErrorCode(PurchasesErrorCode.storeProblemError),
      RevenueCatFailureKind.store,
    );
    expect(
      classifyRevenueCatErrorCode(PurchasesErrorCode.configurationError),
      RevenueCatFailureKind.configuration,
    );
    expect(
      classifyRevenueCatErrorCode(PurchasesErrorCode.invalidCredentialsError),
      RevenueCatFailureKind.developer,
    );
    expect(
      classifyRevenueCatErrorCode(
        PurchasesErrorCode.operationAlreadyInProgressError,
      ),
      RevenueCatFailureKind.operationInProgress,
    );
    expect(
      classifyRevenueCatErrorCode(PurchasesErrorCode.unknownBackendError),
      RevenueCatFailureKind.revenueCat,
    );
    expect(
      classifyRevenueCatErrorCode(PurchasesErrorCode.unknownError),
      RevenueCatFailureKind.unknown,
    );
  });

  test('CustomerInfo requestDate maps into the SDK snapshot', () {
    const info = CustomerInfo(
      EntitlementInfos(
        <String, EntitlementInfo>{},
        <String, EntitlementInfo>{},
      ),
      <String, String?>{},
      <String>[],
      <String>[],
      <StoreTransaction>[],
      '2026-08-01T00:00:00.000Z',
      r'$RCAnonymousID:test',
      <String, String?>{},
      '2026-08-28T04:30:00.000Z',
    );

    final snapshot = revenueCatCustomerInfoSnapshot(info);

    expect(snapshot.proIsActive, isFalse);
    expect(snapshot.requestDate, DateTime.utc(2026, 8, 28, 4, 30));
  });
}
