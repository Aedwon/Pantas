import 'package:flutter/services.dart';
import 'package:purchases_flutter/errors.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum RevenueCatFailureKind {
  userCancelled,
  network,
  store,
  revenueCat,
  configuration,
  developer,
  operationInProgress,
  unknown,
}

class RevenueCatSdkException implements Exception {
  const RevenueCatSdkException(this.kind, [this.cause]);

  final RevenueCatFailureKind kind;
  final Object? cause;

  @override
  String toString() => 'RevenueCatSdkException(${kind.name})';
}

class RevenueCatCustomerInfoSnapshot {
  const RevenueCatCustomerInfoSnapshot.inactive()
      : productId = null,
        expiresAt = null,
        isTrial = false,
        willRenew = false;

  const RevenueCatCustomerInfoSnapshot.active({
    required this.productId,
    this.expiresAt,
    this.isTrial = false,
    this.willRenew = true,
  });

  final String? productId;
  final DateTime? expiresAt;
  final bool isTrial;
  final bool willRenew;

  bool get proIsActive => productId != null;
}

class RevenueCatProductSnapshot {
  const RevenueCatProductSnapshot({
    required this.productId,
    required this.priceString,
    required this.priceAmount,
  });

  final String productId;
  final String priceString;
  final double priceAmount;
}

class RevenueCatOfferingSnapshot {
  const RevenueCatOfferingSnapshot(this.products);

  final List<RevenueCatProductSnapshot> products;
}

abstract interface class RevenueCatSdk {
  Future<void> configure(String androidApiKey);
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfoSnapshot) onUpdate,
  );
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo();
  Future<RevenueCatOfferingSnapshot?> getCurrentOffering();
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid);
  Future<RevenueCatCustomerInfoSnapshot> purchase(String productId);
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases();
}

class PurchasesRevenueCatSdk implements RevenueCatSdk {
  static const _proEntitlementId = 'pro';

  @override
  Future<void> configure(String androidApiKey) {
    return _translate(
      () => Purchases.configure(PurchasesConfiguration(androidApiKey)),
    );
  }

  @override
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfoSnapshot) onUpdate,
  ) {
    Purchases.addCustomerInfoUpdateListener(
      (info) => onUpdate(_customerInfoSnapshot(info)),
    );
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() {
    return _translate(() async => _customerInfoSnapshot(await Purchases.getCustomerInfo()));
  }

  @override
  Future<RevenueCatOfferingSnapshot?> getCurrentOffering() {
    return _translate(() async {
      final current = (await Purchases.getOfferings()).current;
      if (current == null) return null;
      return RevenueCatOfferingSnapshot(
        current.availablePackages
            .map(
              (package) => RevenueCatProductSnapshot(
                productId: package.storeProduct.identifier,
                priceString: package.storeProduct.priceString,
                priceAmount: package.storeProduct.price,
              ),
            )
            .toList(growable: false),
      );
    });
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) {
    return _translate(() async {
      final result = await Purchases.logIn(uid);
      return _customerInfoSnapshot(result.customerInfo);
    });
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(String productId) {
    return _translate(() async {
      final current = (await Purchases.getOfferings()).current;
      if (current == null) {
        throw const RevenueCatSdkException(
          RevenueCatFailureKind.configuration,
        );
      }

      Package? target;
      for (final package in current.availablePackages) {
        if (package.storeProduct.identifier == productId) {
          target = package;
          break;
        }
      }
      if (target == null) {
        throw const RevenueCatSdkException(
          RevenueCatFailureKind.developer,
        );
      }

      final result = await Purchases.purchase(PurchaseParams.package(target));
      return _customerInfoSnapshot(result.customerInfo);
    });
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases() {
    return _translate(
      () async => _customerInfoSnapshot(await Purchases.restorePurchases()),
    );
  }

  RevenueCatCustomerInfoSnapshot _customerInfoSnapshot(CustomerInfo info) {
    final active = info.entitlements.active[_proEntitlementId];
    if (active == null) return const RevenueCatCustomerInfoSnapshot.inactive();
    return RevenueCatCustomerInfoSnapshot.active(
      productId: active.productIdentifier,
      expiresAt: active.expirationDate == null
          ? null
          : DateTime.tryParse(active.expirationDate!)?.toUtc(),
      isTrial: active.periodType == PeriodType.trial,
      willRenew: active.willRenew,
    );
  }

  Future<T> _translate<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on RevenueCatSdkException {
      rethrow;
    } on PlatformException catch (error) {
      throw RevenueCatSdkException(_failureKind(error), error);
    } catch (error) {
      throw RevenueCatSdkException(RevenueCatFailureKind.unknown, error);
    }
  }

  RevenueCatFailureKind _failureKind(PlatformException error) {
    PurchasesErrorCode code;
    try {
      code = PurchasesErrorHelper.getErrorCode(error);
    } catch (_) {
      return RevenueCatFailureKind.unknown;
    }

    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return RevenueCatFailureKind.userCancelled;
      case PurchasesErrorCode.networkError:
      case PurchasesErrorCode.offlineConnectionError:
      case PurchasesErrorCode.apiEndpointBlocked:
      case PurchasesErrorCode.productRequestTimeout:
        return RevenueCatFailureKind.network;
      case PurchasesErrorCode.operationAlreadyInProgressError:
        return RevenueCatFailureKind.operationInProgress;
      case PurchasesErrorCode.configurationError:
      case PurchasesErrorCode.invalidCredentialsError:
        return RevenueCatFailureKind.configuration;
      case PurchasesErrorCode.purchaseInvalidError:
      case PurchasesErrorCode.invalidAppUserIdError:
      case PurchasesErrorCode.invalidSubscriberAttributesError:
      case PurchasesErrorCode.unsupportedError:
      case PurchasesErrorCode.productDiscountMissingIdentifierError:
      case PurchasesErrorCode.productDiscountMissingSubscriptionGroupIdentifierError:
        return RevenueCatFailureKind.developer;
      case PurchasesErrorCode.storeProblemError:
      case PurchasesErrorCode.purchaseNotAllowedError:
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
      case PurchasesErrorCode.productAlreadyPurchasedError:
      case PurchasesErrorCode.ineligibleError:
      case PurchasesErrorCode.insufficientPermissionsError:
      case PurchasesErrorCode.paymentPendingError:
        return RevenueCatFailureKind.store;
      case PurchasesErrorCode.receiptAlreadyInUseError:
      case PurchasesErrorCode.invalidReceiptError:
      case PurchasesErrorCode.missingReceiptFileError:
      case PurchasesErrorCode.unexpectedBackendResponseError:
      case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
      case PurchasesErrorCode.unknownBackendError:
      case PurchasesErrorCode.customerInfoError:
      case PurchasesErrorCode.signatureVerificationFailed:
      case PurchasesErrorCode.purchaseBelongsToOtherUser:
        return RevenueCatFailureKind.revenueCat;
      default:
        return RevenueCatFailureKind.unknown;
    }
  }
}
