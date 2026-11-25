import 'package:pantas/features/paywall/domain/checkout_declaration.dart';
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

  /// The server refused the checkout declaration: missing, or the wrong
  /// wording for the account.
  guardianConfirmationRequired,

  /// The server found the buyer's payment already made (they paid the link we
  /// were replacing). No new link was issued; the entitlement is refreshed.
  alreadyPaid,

  /// The server does not take web payments yet (prod before the live key).
  checkoutClosed,
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
  })  : confirmedEntitlement = entitlement,
        declarationKind = null;

  const PaymentOperationResult.failure({
    required this.status,
    this.declarationKind,
  }) : confirmedEntitlement = null;

  final PaymentOperationStatus status;

  /// With [PaymentOperationStatus.guardianConfirmationRequired]: the wording
  /// the server holds this account to.
  final DeclarationKind? declarationKind;
  final Entitlement? confirmedEntitlement;

  PaymentResult get result => switch (status) {
        PaymentOperationStatus.success => PaymentResult.success,
        PaymentOperationStatus.operationAlreadyInProgress =>
          PaymentResult.pending,
        PaymentOperationStatus.networkFailure => PaymentResult.offline,
        PaymentOperationStatus.userCancelled => PaymentResult.cancelled,
        PaymentOperationStatus.storeFailure ||
        PaymentOperationStatus.configurationFailure ||
        PaymentOperationStatus.developerFailure ||
        PaymentOperationStatus.guardianConfirmationRequired ||
        PaymentOperationStatus.checkoutClosed =>
          PaymentResult.storeError,
        PaymentOperationStatus.alreadyPaid ||
        PaymentOperationStatus.noActiveSubscription ||
        PaymentOperationStatus.entitlementNotActive ||
        PaymentOperationStatus.revenueCatFailure ||
        PaymentOperationStatus.unknownFailure =>
          PaymentResult.notConfirmedYet,
      };
}
