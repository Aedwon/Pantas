import 'dart:async';

import 'package:pantas/features/paywall/application/offline_window.dart';
import 'package:pantas/features/paywall/application/trusted_clock.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';
import 'package:purchases_flutter/purchases_flutter.dart'
    show VerificationResult;

/// The RevenueCat entitlement identifier configured in the dashboard.
/// One entitlement covers all three SKUs.
const proEntitlementId = 'pro';

DateTime _systemReferenceTime() => DateTime.now().toUtc();

TrustedClock _memoryClock(DateTime Function() referenceTime) {
  final values = <String, String>{};
  return TrustedClock(
    readValue: (key) async => values[key],
    writeValue: (key, value) async => values[key] = value,
    deviceNow: referenceTime,
    elapsedNow: () async => null,
  );
}

bool _productIsActive(RevenueCatCustomerInfoSnapshot info, String productId) {
  final base = productId.split(':').first;
  return (info.proIsActive && info.productId?.split(':').first == base) ||
      info.subscriptions
          .any((source) => source.productId.split(':').first == base);
}

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

class LiveRevenueCatGateway implements RevenueCatAccountGateway {
  LiveRevenueCatGateway({
    RevenueCatSdk? sdk,
    PaymentEntitlementState? entitlementState,
    DateTime Function()? referenceTime,
    PendingPurchaseStore? pendingStore,
    TrustedClock? trustedClock,
  })  : _sdk = sdk ?? PurchasesRevenueCatSdk(),
        _entitlementState = entitlementState ??
            PaymentEntitlementState(EntitlementSnapshotStore.inMemory()),
        _referenceTime = referenceTime ?? _systemReferenceTime,
        _pendingStore = pendingStore ?? PendingPurchaseStore.inMemory(),
        _clock =
            trustedClock ?? _memoryClock(referenceTime ?? _systemReferenceTime);

  final RevenueCatSdk _sdk;
  final PaymentEntitlementState _entitlementState;
  final DateTime Function() _referenceTime;
  final PendingPurchaseStore _pendingStore;
  final TrustedClock _clock;
  String? _uid;
  bool _listening = false;
  bool _identityBusy = true;
  int _identityEpoch = 0;

  @override
  Future<void> initialize() async {
    await _clock.start();
    await _entitlementState.initialize();
  }

  @override
  Entitlement? get cachedEntitlement {
    final current = _entitlementState.current;
    return current == null
        ? null
        : OfflineWindow.apply(
            current,
            effectiveTime: _clock.effectiveTime,
            windowConsumed: _clock.windowConsumed,
          );
  }

  @override
  Stream<Entitlement> get customerInfoUpdates => _contextualUpdates();

  Stream<Entitlement> _contextualUpdates() async* {
    await initialize();
    yield* OfflineWindow.watch(
      _entitlementState.updates,
      confirmed: () => _entitlementState.current ?? const Entitlement.free(),
      clock: _clock,
    );
  }

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
    await _prepareFreshRead();
    await _acceptCustomerInfo(await _sdk.getCustomerInfo());
  }

  Future<void> _prepareFreshRead() async {
    await initialize();
    await _clock.observe();
    if (cachedEntitlement?.state == EntitlementState.paused ||
        _clock.hadSetbackSinceCheck ||
        ((_entitlementState.current?.proIsActive ?? false) &&
            _clock.trustedTime == null)) {
      await _sdk.invalidateCustomerInfoCache();
    }
  }

  Future<Entitlement> _acceptCustomerInfo(
    RevenueCatCustomerInfoSnapshot info, {
    bool identityAnswer = false,
    int? expectedEpoch,
  }) async {
    final epoch = expectedEpoch ?? _identityEpoch;
    if (epoch != _identityEpoch) return const Entitlement.free();
    if (_identityBusy && !identityAnswer) {
      return cachedEntitlement ?? const Entitlement.free();
    }
    await initialize();
    await _clock.observe();
    if (epoch != _identityEpoch) return const Entitlement.free();
    final current = _entitlementState.current ?? const Entitlement.free();
    final requestDate = info.requestDate?.toUtc();
    if (info.verification != VerificationResult.verified ||
        requestDate == null) {
      return cachedEntitlement ?? const Entitlement.free();
    }
    if (!info.proIsActive &&
        current.verifiedAt != null &&
        !requestDate.isAfter(current.verifiedAt!)) {
      return cachedEntitlement ?? const Entitlement.free();
    }
    if (await _clock.confirm(requestDate) &&
        _clock.trustedTime == requestDate &&
        epoch == _identityEpoch) {
      final reported =
          entitlementFromCustomerInfo(info).withEvidence(requestDate);
      await _entitlementState.acceptAuthoritative(
        reported,
        shouldContinue: () => epoch == _identityEpoch,
      );
      final uid = _uid;
      if (uid != null) {
        final pending = await _pendingStore.read(uid);
        if (pending != null && _productIsActive(info, pending.productId)) {
          await _pendingStore.clear(uid);
        }
      }
      return cachedEntitlement ?? const Entitlement.free();
    }

    return cachedEntitlement ?? const Entitlement.free();
  }

  @override
  Future<void> clearIdentity() {
    _identityEpoch++;
    _identityBusy = true;
    _uid = null;
    return _entitlementState.clear();
  }

  @override
  Future<void> logOut() async {
    await clearIdentity();
    await _sdk.logOut();
  }

  @override
  Future<void> logIn(String uid) async {
    _identityBusy = true;
    var epoch = _identityEpoch;
    await initialize();
    if (epoch != _identityEpoch) return;
    final owner = _uid ?? await _entitlementState.readOwner();
    if (epoch != _identityEpoch) return;
    if (owner != uid) {
      final clearing = clearIdentity();
      epoch = _identityEpoch;
      await clearing;
      if (epoch != _identityEpoch) return;
    }
    final info = await _sdk.logIn(uid);
    if (epoch != _identityEpoch) return;
    _uid = uid;
    await _entitlementState.writeOwner(uid);
    await _acceptCustomerInfo(info, identityAnswer: true, expectedEpoch: epoch);
    if (epoch == _identityEpoch) _identityBusy = false;
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
    if (_identityBusy) {
      return const PaymentOperationResult.failure(
        status: PaymentOperationStatus.operationAlreadyInProgress,
      );
    }
    final uid = _uid;
    final epoch = _identityEpoch;
    try {
      if (uid != null && await _pendingStore.read(uid) != null) {
        return const PaymentOperationResult.failure(
          status: PaymentOperationStatus.operationAlreadyInProgress,
        );
      }
      if (epoch != _identityEpoch || _identityBusy) {
        return const PaymentOperationResult.failure(
          status: PaymentOperationStatus.operationAlreadyInProgress,
        );
      }
      final current = _entitlementState.current;
      final isUpgrade =
          current?.coverage(at: _referenceTime()).subscriptionTier ==
                  PriceTier.student &&
              productForId(package.productId)?.tier == PriceTier.civilService &&
              productForId(package.productId)?.kind == ProductKind.subscription;
      final info = await _sdk.purchase(
        package.productId,
        oldProductId: isUpgrade ? current?.productId : null,
        allowTrial: !isUpgrade && package.trialEligible,
      );
      final confirmed = await _acceptCustomerInfo(info, expectedEpoch: epoch);
      return PaymentOperationResult.authoritative(
        status: epoch == _identityEpoch &&
                info.verification == VerificationResult.verified &&
                info.requestDate == confirmed.verifiedAt &&
                _productIsActive(info, package.productId)
            ? PaymentOperationStatus.success
            : PaymentOperationStatus.entitlementNotActive,
        entitlement: confirmed,
      );
    } on RevenueCatSdkException catch (error) {
      if (error.kind == RevenueCatFailureKind.pending && uid != null) {
        await _pendingStore.save(
          PendingPurchase(
            uid: uid,
            productId: package.productId,
            startedAt: _referenceTime().toUtc(),
          ),
        );
      }
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
    if (_identityBusy) {
      return const PaymentOperationResult.failure(
        status: PaymentOperationStatus.operationAlreadyInProgress,
      );
    }
    final epoch = _identityEpoch;
    try {
      await _prepareFreshRead();
      if (epoch != _identityEpoch || _identityBusy) {
        return const PaymentOperationResult.failure(
          status: PaymentOperationStatus.operationAlreadyInProgress,
        );
      }
      final info = await _sdk.restorePurchases();
      final confirmed = await _acceptCustomerInfo(info, expectedEpoch: epoch);
      if (epoch != _identityEpoch ||
          info.verification != VerificationResult.verified ||
          info.requestDate != confirmed.verifiedAt) {
        return PaymentOperationResult.authoritative(
          status: info.proIsActive
              ? PaymentOperationStatus.entitlementNotActive
              : PaymentOperationStatus.noActiveSubscription,
          entitlement: confirmed,
        );
      }
      final reported = entitlementFromCustomerInfo(info);
      final uid = _uid;
      if (uid != null) {
        final pending = await _pendingStore.read(uid);
        if (pending != null && !_productIsActive(info, pending.productId)) {
          if (_referenceTime().toUtc().difference(pending.startedAt) >
              const Duration(hours: 72)) {
            await _pendingStore.clear(uid);
          } else {
            return const PaymentOperationResult.failure(
              status: PaymentOperationStatus.operationAlreadyInProgress,
            );
          }
        }
      }
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
    RevenueCatFailureKind.pending =>
      PaymentOperationStatus.operationAlreadyInProgress,
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
    RevenueCatFailureKind.pending => PaywallOfferingStatus.storeFailure,
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
