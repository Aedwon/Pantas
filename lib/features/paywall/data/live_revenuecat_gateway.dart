import 'dart:async';

import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

/// The RevenueCat entitlement identifier configured in the dashboard.
/// One entitlement covers all three SKUs.
const proEntitlementId = 'pro';

/// The permanent Google Play product ids chosen before the first submission.
const _weeklyProductId = 'pantas_pro_weekly';
const _monthlyProductId = 'pantas_pro_monthly';
const _yearlyProductId = 'pantas_pro_yearly';

/// Google Play can append a base-plan id, for example
/// `pantas_pro_monthly:monthly-autorenewing`.
PaywallSku? skuFromProductId(String productId) {
  final base = productId.split(':').first;
  return switch (base) {
    _weeklyProductId => PaywallSku.weekly,
    _monthlyProductId => PaywallSku.monthly,
    _yearlyProductId => PaywallSku.yearly,
    _ => null,
  };
}

EntitlementPlan planForSku(PaywallSku sku) {
  return switch (sku) {
    PaywallSku.weekly => EntitlementPlan.weekly,
    PaywallSku.monthly => EntitlementPlan.monthly,
    PaywallSku.yearly => EntitlementPlan.yearly,
  };
}

Entitlement entitlementFromCustomerInfo(RevenueCatCustomerInfoSnapshot info) {
  final productId = info.productId;
  if (!info.proIsActive || productId == null) return const Entitlement.free();

  final sku = skuFromProductId(productId);
  if (sku == null) {
    return Entitlement.activeUnknown(
      productId: productId,
      expiresAt: info.expiresAt,
      isTrial: info.isTrial,
      willRenew: info.willRenew,
    );
  }

  return Entitlement(
    plan: planForSku(sku),
    productId: productId,
    expiresAt: info.expiresAt,
    isTrial: info.isTrial,
    willRenew: info.willRenew,
  );
}

class LiveRevenueCatGateway implements RevenueCatGateway {
  LiveRevenueCatGateway({
    RevenueCatSdk? sdk,
    PaymentEntitlementState? entitlementState,
  })  : _sdk = sdk ?? PurchasesRevenueCatSdk(),
        _entitlementState = entitlementState ??
            PaymentEntitlementState(EntitlementSnapshotStore.inMemory());

  final RevenueCatSdk _sdk;
  final PaymentEntitlementState _entitlementState;
  bool _listening = false;

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

  Future<void> _acceptCustomerInfo(RevenueCatCustomerInfoSnapshot info) {
    return _entitlementState.acceptAuthoritative(
      entitlementFromCustomerInfo(info),
    );
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
      final unrecognized = <String>[];
      for (final product in offering.products) {
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
          ),
        );
      }

      if (recognized.isEmpty) {
        return PaywallOfferingResult(
          status: PaywallOfferingStatus.allProductsUnrecognized,
          unrecognizedProductIds: unrecognized,
        );
      }
      if (unrecognized.isNotEmpty) {
        return PaywallOfferingResult(
          status: PaywallOfferingStatus.mixedProducts,
          recognizedPackages: recognized,
          unrecognizedProductIds: unrecognized,
        );
      }
      return PaywallOfferingResult(
        status: PaywallOfferingStatus.available,
        recognizedPackages: recognized,
      );
    } on RevenueCatSdkException catch (error) {
      return PaywallOfferingResult(status: _offeringStatus(error.kind));
    } catch (_) {
      return const PaywallOfferingResult(
        status: PaywallOfferingStatus.unknownFailure,
      );
    }
  }

  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async {
    await initialize();
    try {
      final entitlement = entitlementFromCustomerInfo(
        await _sdk.purchase(package.productId),
      );
      await _entitlementState.acceptAuthoritative(entitlement);
      if (!entitlement.proIsActive) {
        return PaymentOperationResult.authoritative(
          status: PaymentOperationStatus.entitlementNotActive,
          entitlement: entitlement,
        );
      }
      return PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.success,
        entitlement: entitlement,
      );
    } on RevenueCatSdkException catch (error) {
      return PaymentOperationResult.failure(
        status: _operationStatus(error.kind),
      );
    } catch (_) {
      return const PaymentOperationResult.failure(
        status: PaymentOperationStatus.unknownFailure,
      );
    }
  }

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    await initialize();
    try {
      final entitlement = entitlementFromCustomerInfo(
        await _sdk.restorePurchases(),
      );
      await _entitlementState.acceptAuthoritative(entitlement);
      return PaymentOperationResult.authoritative(
        status: entitlement.proIsActive
            ? PaymentOperationStatus.success
            : PaymentOperationStatus.noActiveSubscription,
        entitlement: entitlement,
      );
    } on RevenueCatSdkException catch (error) {
      return PaymentOperationResult.failure(
        status: _operationStatus(error.kind),
      );
    } catch (_) {
      return const PaymentOperationResult.failure(
        status: PaymentOperationStatus.unknownFailure,
      );
    }
  }
}

PaywallOfferingStatus _offeringStatus(RevenueCatFailureKind kind) {
  return switch (kind) {
    RevenueCatFailureKind.network => PaywallOfferingStatus.networkFailure,
    RevenueCatFailureKind.store => PaywallOfferingStatus.storeFailure,
    RevenueCatFailureKind.revenueCat => PaywallOfferingStatus.revenueCatFailure,
    RevenueCatFailureKind.configuration =>
      PaywallOfferingStatus.configurationFailure,
    RevenueCatFailureKind.developer => PaywallOfferingStatus.developerFailure,
    RevenueCatFailureKind.userCancelled ||
    RevenueCatFailureKind.operationInProgress ||
    RevenueCatFailureKind.unknown => PaywallOfferingStatus.unknownFailure,
  };
}

PaymentOperationStatus _operationStatus(RevenueCatFailureKind kind) {
  return switch (kind) {
    RevenueCatFailureKind.userCancelled => PaymentOperationStatus.userCancelled,
    RevenueCatFailureKind.network => PaymentOperationStatus.networkFailure,
    RevenueCatFailureKind.store => PaymentOperationStatus.storeFailure,
    RevenueCatFailureKind.revenueCat => PaymentOperationStatus.revenueCatFailure,
    RevenueCatFailureKind.configuration =>
      PaymentOperationStatus.configurationFailure,
    RevenueCatFailureKind.developer => PaymentOperationStatus.developerFailure,
    RevenueCatFailureKind.operationInProgress =>
      PaymentOperationStatus.operationAlreadyInProgress,
    RevenueCatFailureKind.unknown => PaymentOperationStatus.unknownFailure,
  };
}
