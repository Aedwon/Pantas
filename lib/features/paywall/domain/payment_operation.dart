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

class PaymentOperationResult {
  const PaymentOperationResult.authoritative({
    required this.status,
    required Entitlement entitlement,
  }) : confirmedEntitlement = entitlement;

  const PaymentOperationResult.failure({required this.status})
      : confirmedEntitlement = null;

  final PaymentOperationStatus status;
  final Entitlement? confirmedEntitlement;
}
