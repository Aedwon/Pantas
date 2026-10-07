import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';

void main() {
  test('every raw payment outcome has one typed result', () {
    const cases = {
      PaymentOperationStatus.success: PaymentResult.success,
      PaymentOperationStatus.noActiveSubscription:
          PaymentResult.notConfirmedYet,
      PaymentOperationStatus.entitlementNotActive:
          PaymentResult.notConfirmedYet,
      PaymentOperationStatus.userCancelled: PaymentResult.cancelled,
      PaymentOperationStatus.networkFailure: PaymentResult.offline,
      PaymentOperationStatus.storeFailure: PaymentResult.storeError,
      PaymentOperationStatus.revenueCatFailure: PaymentResult.notConfirmedYet,
      PaymentOperationStatus.configurationFailure: PaymentResult.storeError,
      PaymentOperationStatus.developerFailure: PaymentResult.storeError,
      PaymentOperationStatus.operationAlreadyInProgress: PaymentResult.pending,
      PaymentOperationStatus.unknownFailure: PaymentResult.notConfirmedYet,
    };
    expect(cases.keys.toSet(), PaymentOperationStatus.values.toSet());
    for (final entry in cases.entries) {
      expect(
        PaymentOperationResult.failure(status: entry.key).result,
        entry.value,
        reason: entry.key.name,
      );
    }
  });
}
