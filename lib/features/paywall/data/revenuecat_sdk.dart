import 'package:flutter/services.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/products.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _proEntitlementId = 'pro';

enum RevenueCatFailureKind {
  userCancelled,
  pending,
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
  const RevenueCatCustomerInfoSnapshot.inactive({
    this.requestDate,
    this.subscriptions = const [],
    this.promotions = const [],
    this.nonSubscriptionPurchases = const [],
    this.billingIssuesDetectedAt,
  })  : productId = null,
        expiresAt = null,
        isTrial = false,
        willRenew = false;

  const RevenueCatCustomerInfoSnapshot.active({
    required this.productId,
    this.expiresAt,
    this.isTrial = false,
    this.willRenew = true,
    this.requestDate,
    this.subscriptions = const [],
    this.promotions = const [],
    this.nonSubscriptionPurchases = const [],
    this.billingIssuesDetectedAt,
  });

  final String? productId;
  final DateTime? expiresAt;
  final bool isTrial;
  final bool willRenew;
  final DateTime? requestDate;
  final List<RevenueCatSubscriptionSnapshot> subscriptions;
  final List<CoveragePeriod> promotions;
  final List<String> nonSubscriptionPurchases;
  final DateTime? billingIssuesDetectedAt;

  bool get proIsActive =>
      productId != null || subscriptions.isNotEmpty || promotions.isNotEmpty;
}

class RevenueCatSubscriptionSnapshot {
  const RevenueCatSubscriptionSnapshot({
    required this.productId,
    this.expiresAt,
    this.isTrial = false,
    this.willRenew = true,
    this.billingIssuesDetectedAt,
  });

  final String productId;
  final DateTime? expiresAt;
  final bool isTrial;
  final bool willRenew;
  final DateTime? billingIssuesDetectedAt;
}

class RevenueCatProductSnapshot {
  const RevenueCatProductSnapshot({
    required this.productId,
    required this.priceString,
    required this.priceAmount,
    this.trialEligible = false,
  });

  final String productId;
  final String priceString;
  final double priceAmount;
  final bool trialEligible;
}

RevenueCatProductSnapshot revenueCatProductSnapshot(StoreProduct product) =>
    RevenueCatProductSnapshot(
      productId: product.identifier,
      priceString: product.priceString,
      priceAmount: product.price,
      trialEligible:
          productForId(product.identifier)?.period == PaywallSku.monthly &&
              (product.subscriptionOptions
                      ?.any((option) => option.freePhase != null) ??
                  false),
    );

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
  Future<RevenueCatCustomerInfoSnapshot> purchase(
    String productId, {
    String? oldProductId,
    bool allowTrial = true,
  });
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases();
}

PurchaseParams purchaseParamsFor(
  Package package, {
  String? oldProductId,
  bool allowTrial = true,
}) {
  final options = package.storeProduct.subscriptionOptions ?? const [];
  final requireBase = oldProductId != null ||
      (!allowTrial && options.any((option) => option.freePhase != null));
  if (!requireBase) return PurchaseParams.package(package);
  final base = options.where((option) => option.isBasePlan).firstOrNull;
  if (base == null) {
    throw const RevenueCatSdkException(RevenueCatFailureKind.configuration);
  }
  return PurchaseParams.subscriptionOption(
    base,
    productChangeInfo: oldProductId == null
        ? null
        : StoreProductChangeInfo(
            oldProductId,
            replacementMode: StoreReplacementMode.withTimeProration,
          ),
  );
}

RevenueCatFailureKind classifyRevenueCatErrorCode(PurchasesErrorCode code) {
  return switch (code) {
    PurchasesErrorCode.purchaseCancelledError =>
      RevenueCatFailureKind.userCancelled,
    PurchasesErrorCode.networkError ||
    PurchasesErrorCode.offlineConnectionError ||
    PurchasesErrorCode.apiEndpointBlocked ||
    PurchasesErrorCode.productRequestTimeout =>
      RevenueCatFailureKind.network,
    PurchasesErrorCode.operationAlreadyInProgressError =>
      RevenueCatFailureKind.operationInProgress,
    PurchasesErrorCode.configurationError =>
      RevenueCatFailureKind.configuration,
    PurchasesErrorCode.invalidCredentialsError ||
    PurchasesErrorCode.purchaseInvalidError ||
    PurchasesErrorCode.invalidAppUserIdError ||
    PurchasesErrorCode.invalidSubscriberAttributesError ||
    PurchasesErrorCode.unsupportedError ||
    PurchasesErrorCode.productDiscountMissingIdentifierError ||
    PurchasesErrorCode.productDiscountMissingSubscriptionGroupIdentifierError ||
    PurchasesErrorCode.invalidAppleSubscriptionKeyError ||
    PurchasesErrorCode.invalidPromotionalOfferError ||
    PurchasesErrorCode.featureNotAvailableInCustomEntitlementsComputationMode ||
    PurchasesErrorCode.featureNotSupportedWithStoreKit1 ||
    PurchasesErrorCode.invalidWebPurchaseToken =>
      RevenueCatFailureKind.developer,
    PurchasesErrorCode.paymentPendingError => RevenueCatFailureKind.pending,
    PurchasesErrorCode.storeProblemError ||
    PurchasesErrorCode.purchaseNotAllowedError ||
    PurchasesErrorCode.productNotAvailableForPurchaseError ||
    PurchasesErrorCode.productAlreadyPurchasedError ||
    PurchasesErrorCode.ineligibleError ||
    PurchasesErrorCode.insufficientPermissionsError ||
    PurchasesErrorCode.beginRefundRequestError ||
    PurchasesErrorCode.testStoreSimulatedPurchaseError =>
      RevenueCatFailureKind.store,
    PurchasesErrorCode.receiptAlreadyInUseError ||
    PurchasesErrorCode.invalidReceiptError ||
    PurchasesErrorCode.missingReceiptFileError ||
    PurchasesErrorCode.unexpectedBackendResponseError ||
    PurchasesErrorCode.receiptInUseByOtherSubscriberError ||
    PurchasesErrorCode.unknownBackendError ||
    PurchasesErrorCode.customerInfoError ||
    PurchasesErrorCode.systemInfoError ||
    PurchasesErrorCode.signatureVerificationFailed ||
    PurchasesErrorCode.purchaseBelongsToOtherUser ||
    PurchasesErrorCode.expiredWebPurchaseToken =>
      RevenueCatFailureKind.revenueCat,
    PurchasesErrorCode.unknownError ||
    PurchasesErrorCode.logOutWithAnonymousUserError ||
    PurchasesErrorCode.emptySubscriberAttributesError ||
    PurchasesErrorCode.unknownNonNativeError =>
      RevenueCatFailureKind.unknown,
  };
}

RevenueCatCustomerInfoSnapshot revenueCatCustomerInfoSnapshot(
  CustomerInfo info,
) {
  final requestDate = DateTime.tryParse(info.requestDate)?.toUtc();
  final active = info.entitlements.active[_proEntitlementId];
  DateTime? date(String? value) =>
      value == null ? null : DateTime.tryParse(value)?.toUtc();
  final subscriptions = [
    for (final id in info.activeSubscriptions)
      RevenueCatSubscriptionSnapshot(
        productId: id,
        expiresAt: date(
          info.subscriptionsByProductIdentifier[id]?.expiresDate ??
              info.allExpirationDates[id],
        ),
        isTrial: info.subscriptionsByProductIdentifier[id]?.periodType ==
            PeriodType.trial,
        willRenew: info.subscriptionsByProductIdentifier[id]?.willRenew ??
            (active?.productIdentifier == id ? active?.willRenew : null) ??
            true,
        billingIssuesDetectedAt: date(
          info.subscriptionsByProductIdentifier[id]?.billingIssuesDetectedAt,
        ),
      ),
  ];
  final promotions = [
    for (final entry in info.entitlements.active.entries)
      if ((entry.key.startsWith('promo_') ||
              entry.value.store == Store.promotional) &&
          date(entry.value.expirationDate) != null)
        CoveragePeriod(
          id: entry.key,
          endsAt: date(entry.value.expirationDate)!,
        ),
  ];
  final purchases = [
    for (final transaction in info.nonSubscriptionTransactions)
      transaction.productIdentifier,
  ];
  if (active == null) {
    return RevenueCatCustomerInfoSnapshot.inactive(
      requestDate: requestDate,
      subscriptions: subscriptions,
      promotions: promotions,
      nonSubscriptionPurchases: purchases,
    );
  }
  return RevenueCatCustomerInfoSnapshot.active(
    productId: active.productIdentifier,
    expiresAt: active.expirationDate == null
        ? null
        : DateTime.tryParse(active.expirationDate!)?.toUtc(),
    isTrial: active.periodType == PeriodType.trial,
    willRenew: active.willRenew,
    requestDate: requestDate,
    subscriptions: subscriptions,
    promotions: promotions,
    nonSubscriptionPurchases: purchases,
    billingIssuesDetectedAt: date(active.billingIssueDetectedAt),
  );
}

class PurchasesRevenueCatSdk implements RevenueCatSdk {
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
      (info) => onUpdate(revenueCatCustomerInfoSnapshot(info)),
    );
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() {
    return _translate(
      () async => revenueCatCustomerInfoSnapshot(
        await Purchases.getCustomerInfo(),
      ),
    );
  }

  @override
  Future<RevenueCatOfferingSnapshot?> getCurrentOffering() {
    return _translate(() async {
      final current = (await Purchases.getOfferings()).current;
      if (current == null) return null;
      return RevenueCatOfferingSnapshot(
        current.availablePackages
            .map(
              (package) => revenueCatProductSnapshot(package.storeProduct),
            )
            .toList(growable: false),
      );
    });
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) {
    return _translate(() async {
      final result = await Purchases.logIn(uid);
      return revenueCatCustomerInfoSnapshot(result.customerInfo);
    });
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(
    String productId, {
    String? oldProductId,
    bool allowTrial = true,
  }) {
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

      final result = await Purchases.purchase(
        purchaseParamsFor(
          target,
          oldProductId: oldProductId,
          allowTrial: allowTrial,
        ),
      );
      return revenueCatCustomerInfoSnapshot(result.customerInfo);
    });
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases() {
    return _translate(() async {
      await Purchases.syncPurchases();
      return revenueCatCustomerInfoSnapshot(await Purchases.getCustomerInfo());
    });
  }

  Future<T> _translate<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on RevenueCatSdkException {
      rethrow;
    } on PlatformException catch (error) {
      PurchasesErrorCode code;
      try {
        code = PurchasesErrorHelper.getErrorCode(error);
      } catch (_) {
        throw RevenueCatSdkException(RevenueCatFailureKind.unknown, error);
      }
      throw RevenueCatSdkException(classifyRevenueCatErrorCode(code), error);
    } catch (error) {
      throw RevenueCatSdkException(RevenueCatFailureKind.unknown, error);
    }
  }
}
