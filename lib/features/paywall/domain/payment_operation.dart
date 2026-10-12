import 'package:pantas/features/paywall/domain/entitlement.dart';

enum PaymentOperationStatus {
  success,
  noActiveSubscription,
  entitlementNotActive,
  userCancelled,
  networkFailure,
  storeFailure,
  revenueCatFailure,
  configurationFailure,
  developerFailure,
  operationAlreadyInProgress,
  unknownFailure,
}

enum PaymentResult {
  success,
  pending,
  offline,
  cancelled,
  storeError,
  notConfirmedYet
}

class PaymentOperationResult {
  const PaymentOperationResult.authoritative({
    required this.status,
    required Entitlement entitlement,
  }) : confirmedEntitlement = entitlement;

  const PaymentOperationResult.failure({required this.status})
      : confirmedEntitlement = null;

  final PaymentOperationStatus status;
  final Entitlement? confirmedEntitlement;

  PaymentResult get result => switch (status) {
        PaymentOperationStatus.success => PaymentResult.success,
        PaymentOperationStatus.operationAlreadyInProgress =>
          PaymentResult.pending,
        PaymentOperationStatus.networkFailure => PaymentResult.offline,
        PaymentOperationStatus.userCancelled => PaymentResult.cancelled,
        PaymentOperationStatus.storeFailure ||
        PaymentOperationStatus.configurationFailure ||
        PaymentOperationStatus.developerFailure =>
          PaymentResult.storeError,
        PaymentOperationStatus.noActiveSubscription ||
        PaymentOperationStatus.entitlementNotActive ||
        PaymentOperationStatus.revenueCatFailure ||
        PaymentOperationStatus.unknownFailure =>
          PaymentResult.notConfirmedYet,
      };
}
