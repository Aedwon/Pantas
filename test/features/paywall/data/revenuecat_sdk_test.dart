import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
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
