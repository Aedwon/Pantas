import 'dart:async';

import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/products.dart';

/// The RevenueCat entitlement identifier configured in the dashboard.
/// One entitlement covers all three SKUs.
const proEntitlementId = 'pro';

/// RevenueCat refreshes foreground CustomerInfo cache entries after five
/// minutes.
const revenueCatInactiveAuthorityWindow = Duration(minutes: 5);

DateTime _systemReferenceTime() => DateTime.now().toUtc();

/// Google Play can append a base-plan id, for example
/// `pantas_pro_monthly:monthly-autorenewing`.
PaywallSku? skuFromProductId(String productId) {
  return productForId(productId)?.period;
}

EntitlementPlan planForSku(PaywallSku sku) {
  return switch (sku) {
    PaywallSku.weekly => EntitlementPlan.weekly,
    PaywallSku.monthly => EntitlementPlan.monthly,
    PaywallSku.yearly => EntitlementPlan.yearly,
  };
}

Entitlement entitlementFromCustomerInfo(RevenueCatCustomerInfoSnapshot info) {
  if (!info.proIsActive) return const Entitlement.free();
  final sources = [
    ...info.subscriptions,
    if (info.productId != null &&
        !info.subscriptions
            .any((source) => source.productId == info.productId) &&
        productForId(info.productId!)?.kind != ProductKind.pass &&
        info.promotions.isEmpty)
      RevenueCatSubscriptionSnapshot(
        productId: info.productId!,
        expiresAt: info.expiresAt,
        isTrial: info.isTrial,
        willRenew: info.willRenew,
        billingIssuesDetectedAt: info.billingIssuesDetectedAt,
      ),
  ];
  final known = sources
      .where(
        (source) =>
            productForId(source.productId)?.kind == ProductKind.subscription,
      )
      .toList()
    ..sort(
      (a, b) => productForId(b.productId)!
          .tier
          .index
          .compareTo(productForId(a.productId)!.tier.index),
    );
  final selected = known.isEmpty ? null : known.first;
  final productId = selected?.productId ??
      info.productId ??
      (sources.isEmpty ? null : sources.first.productId);
  final subscriptions = [
    for (final source in sources)
      if (source.expiresAt != null)
        CoveragePeriod(id: source.productId, endsAt: source.expiresAt!),
  ];
  final knownPromotions = info.promotions
      .where(
        (source) => productForId(source.id)?.kind == ProductKind.promotional,
      )
      .toList();
  if (selected == null && knownPromotions.isNotEmpty) {
    return Entitlement(
      plan: EntitlementPlan.free,
      willRenew: false,
      state: EntitlementState.grant,
      promotions: info.promotions,
      subscriptions: subscriptions,
    );
  }
  if (selected == null && info.promotions.isNotEmpty) {
    // A promotional entitlement is not a subscription, regardless of its
    // displayed product identifier. Unknown grants cover nothing.
    final unknown = info.promotions.first;
    return Entitlement(
      plan: EntitlementPlan.free,
      productId: unknown.id,
      expiresAt: unknown.endsAt,
      willRenew: false,
      isUnknownPlan: true,
      promotions: info.promotions,
      state: EntitlementState.unknown,
    );
  }
  if (productId == null) return const Entitlement.free();

  final sku = skuFromProductId(productId);
  if (sku == null) {
    return Entitlement.activeUnknown(
      productId: productId,
      expiresAt: info.expiresAt ?? sources.firstOrNull?.expiresAt,
      isTrial: info.isTrial,
      willRenew: info.willRenew,
    );
  }

  return Entitlement(
    plan: planForSku(sku),
    productId: productId,
    expiresAt: selected?.expiresAt ?? info.expiresAt,
    isTrial: selected?.isTrial ?? info.isTrial,
    willRenew: selected?.willRenew ?? info.willRenew,
    tier: productForId(productId)?.tier,
    state: selected?.billingIssuesDetectedAt != null
        ? EntitlementState.billingIssue
        : null,
    subscriptions: subscriptions,
    promotions: info.promotions,
  );
}

class LiveRevenueCatGateway implements RevenueCatGateway {
  LiveRevenueCatGateway({
    RevenueCatSdk? sdk,
    PaymentEntitlementState? entitlementState,
    DateTime Function()? referenceTime,
  })  : _sdk = sdk ?? PurchasesRevenueCatSdk(),
        _entitlementState = entitlementState ??
            PaymentEntitlementState(EntitlementSnapshotStore.inMemory()),
        _referenceTime = referenceTime ?? _systemReferenceTime;

  final RevenueCatSdk _sdk;
  final PaymentEntitlementState _entitlementState;
  final DateTime Function() _referenceTime;
  bool _listening = false;

  @override
  Future<void> initialize() => _entitlementState.initialize();

  @override
  Entitlement? get cachedEntitlement => _entitlementState.current;

  @override
  Stream<Entitlement> get customerInfoUpdates => _entitlementState.updates;

  @override
  Future<void> configure({required String androidApiKey}) async {
    await initialize();
    await _sdk.configure(androidApiKey);
    if (!_listening) {
      _listening = true;
      _sdk.addCustomerInfoUpdateListener((info) {
        unawaited(_acceptCustomerInfo(info));
      });
    }
    await _acceptCustomerInfo(await _sdk.getCustomerInfo());
  }

  Future<Entitlement> _acceptCustomerInfo(
    RevenueCatCustomerInfoSnapshot info,
  ) async {
    await initialize();
    final reported = entitlementFromCustomerInfo(info);
    final current = _entitlementState.current ?? const Entitlement.free();

    if (reported.proIsActive ||
        !current.proIsActive ||
        _inactiveCustomerInfoCanRevoke(info)) {
      await _entitlementState.acceptAuthoritative(reported);
      return reported;
    }

    return current;
  }

  bool _inactiveCustomerInfoCanRevoke(RevenueCatCustomerInfoSnapshot info) {
    final requestDate = info.requestDate?.toUtc();
    if (requestDate == null) return false;

    final referenceTime = _referenceTime().toUtc();
    if (requestDate.isAfter(referenceTime)) return false;

    return referenceTime.difference(requestDate) <=
        revenueCatInactiveAuthorityWindow;
  }

  @override
  Future<void> logIn(String uid) async {
    await initialize();
    await _acceptCustomerInfo(await _sdk.logIn(uid));
  }

  @override
  Future<PaywallOfferingResult> currentOffering() async {
    try {
      final offering = await _sdk.getCurrentOffering();
      if (offering == null) {
        return const PaywallOfferingResult.noCurrentOffering();
      }
      if (offering.products.isEmpty) {
        return const PaywallOfferingResult.emptyCurrentOffering();
      }

      final recognized = <PaywallPackage>[];
      final passes = <PaywallPassPackage>[];
      final unrecognized = <String>[];
      for (final product in offering.products) {
        if (productForId(product.productId)?.kind == ProductKind.pass) {
          passes.add(
            PaywallPassPackage(
              productId: product.productId,
              priceString: product.priceString,
              priceAmount: product.priceAmount,
            ),
          );
          continue;
        }
        final sku = skuFromProductId(product.productId);
        if (sku == null) {
          unrecognized.add(product.productId);
          continue;
        }
        recognized.add(
          PaywallPackage(
            sku: sku,
            productId: product.productId,
            priceString: product.priceString,
            priceAmount: product.priceAmount,
            trialEligible: product.trialEligible,
          ),
        );
      }

      if (recognized.isEmpty && passes.isEmpty) {
        return PaywallOfferingResult(
          status: PaywallOfferingStatus.allProductsUnrecognized,
          unrecognizedProductIds: unrecognized,
        );
      }
      if (unrecognized.isNotEmpty) {
        return PaywallOfferingResult(
          status: PaywallOfferingStatus.mixedProducts,
          recognizedPackages: recognized,
          passPackages: passes,
          unrecognizedProductIds: unrecognized,
        );
      }
      return PaywallOfferingResult(
        status: PaywallOfferingStatus.available,
        recognizedPackages: recognized,
        passPackages: passes,
      );
    } on RevenueCatSdkException catch (error) {
      return PaywallOfferingResult(
        status: _offeringStatusForFailure(error.kind),
      );
    } catch (_) {
      return const PaywallOfferingResult(
        status: PaywallOfferingStatus.unknownFailure,
      );
    }
  }

  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async {
    try {
      final info = await _sdk.purchase(package.productId);
      final reported = entitlementFromCustomerInfo(info);
      final confirmed = await _acceptCustomerInfo(info);
      return PaymentOperationResult.authoritative(
        status: reported.proIsActive
            ? PaymentOperationStatus.success
            : PaymentOperationStatus.entitlementNotActive,
        entitlement: confirmed,
      );
    } on RevenueCatSdkException catch (error) {
      return PaymentOperationResult.failure(
        status: _operationStatusForFailure(error.kind),
      );
    } catch (_) {
      return const PaymentOperationResult.failure(
        status: PaymentOperationStatus.unknownFailure,
      );
    }
  }

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    try {
      final info = await _sdk.restorePurchases();
      final reported = entitlementFromCustomerInfo(info);
      final confirmed = await _acceptCustomerInfo(info);
      return PaymentOperationResult.authoritative(
        status: reported.proIsActive
            ? PaymentOperationStatus.success
            : PaymentOperationStatus.noActiveSubscription,
        entitlement: confirmed,
      );
    } on RevenueCatSdkException catch (error) {
      return PaymentOperationResult.failure(
        status: _operationStatusForFailure(error.kind),
      );
    } catch (_) {
      return const PaymentOperationResult.failure(
        status: PaymentOperationStatus.unknownFailure,
      );
    }
  }
}

PaymentOperationStatus _operationStatusForFailure(RevenueCatFailureKind kind) {
  return switch (kind) {
    RevenueCatFailureKind.userCancelled => PaymentOperationStatus.userCancelled,
    RevenueCatFailureKind.network => PaymentOperationStatus.networkFailure,
    RevenueCatFailureKind.store => PaymentOperationStatus.storeFailure,
    RevenueCatFailureKind.revenueCat =>
      PaymentOperationStatus.revenueCatFailure,
    RevenueCatFailureKind.configuration =>
      PaymentOperationStatus.configurationFailure,
    RevenueCatFailureKind.developer => PaymentOperationStatus.developerFailure,
    RevenueCatFailureKind.operationInProgress =>
      PaymentOperationStatus.operationAlreadyInProgress,
    RevenueCatFailureKind.unknown => PaymentOperationStatus.unknownFailure,
  };
}

PaywallOfferingStatus _offeringStatusForFailure(RevenueCatFailureKind kind) {
  return switch (kind) {
    RevenueCatFailureKind.network => PaywallOfferingStatus.networkFailure,
    RevenueCatFailureKind.store => PaywallOfferingStatus.storeFailure,
    RevenueCatFailureKind.revenueCat => PaywallOfferingStatus.revenueCatFailure,
    RevenueCatFailureKind.configuration =>
      PaywallOfferingStatus.configurationFailure,
    RevenueCatFailureKind.developer => PaywallOfferingStatus.developerFailure,
    RevenueCatFailureKind.userCancelled ||
    RevenueCatFailureKind.operationInProgress ||
    RevenueCatFailureKind.unknown =>
      PaywallOfferingStatus.unknownFailure,
  };
}
