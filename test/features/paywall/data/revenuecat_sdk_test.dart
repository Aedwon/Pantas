import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:purchases_flutter/errors.dart';

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
}
