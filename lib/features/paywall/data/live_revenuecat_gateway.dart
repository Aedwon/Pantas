import 'dart:async';

import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// The RevenueCat entitlement identifier configured in the dashboard.
/// One entitlement covers all three SKUs.
const proEntitlementId = 'pro';

const _weeklyProductId = 'pro_weekly';
const _monthlyProductId = 'pro_monthly';
const _yearlyProductId = 'pro_yearly';

/// Google Play appends a base plan id to the product id, as in
/// `pro_monthly:monthly-autorenewing`. Compare on the part before the colon.
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

Entitlement entitlementFromCustomerInfo(CustomerInfo info) {
  final active = info.entitlements.active[proEntitlementId];
  if (active == null) return const Entitlement.free();

  final sku = skuFromProductId(active.productIdentifier);
  // An active entitlement on a product this build does not know about is a
  // paid student. Treat it as Pro on the monthly plan rather than as Free:
  // failing closed here would take Pro from someone who paid for it.
  final plan = sku == null ? EntitlementPlan.monthly : planForSku(sku);

  return Entitlement(
    plan: plan,
    productId: active.productIdentifier,
    expiresAt: active.expirationDate == null
        ? null
        : DateTime.tryParse(active.expirationDate!),
    isTrial: active.periodType == PeriodType.trial,
    willRenew: active.willRenew,
  );
}

class LiveRevenueCatGateway implements RevenueCatGateway {
  LiveRevenueCatGateway();

  final _controller = StreamController<Entitlement>.broadcast();
  Entitlement? _cached;
  bool _listening = false;

  @override
  Entitlement? get cachedEntitlement => _cached;

  @override
  Stream<Entitlement> get customerInfoUpdates => _controller.stream;

  @override
  Future<void> configure({required String androidApiKey}) async {
    await Purchases.configure(PurchasesConfiguration(androidApiKey));
    if (!_listening) {
      _listening = true;
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
    }
    final info = await Purchases.getCustomerInfo();
    _onCustomerInfo(info);
  }

  void _onCustomerInfo(CustomerInfo info) {
    final entitlement = entitlementFromCustomerInfo(info);
    _cached = entitlement;
    if (!_controller.isClosed) _controller.add(entitlement);
  }

  @override
  Future<void> logIn(String uid) async {
    final result = await Purchases.logIn(uid);
    _onCustomerInfo(result.customerInfo);
  }

  @override
  Future<List<PaywallPackage>> currentOffering() async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) return const [];

    final packages = <PaywallPackage>[];
    for (final package in current.availablePackages) {
      final product = package.storeProduct;
      final sku = skuFromProductId(product.identifier);
      // A product the ladder does not name is not shown. The ladder is three
      // SKUs and a fourth appearing on screen would be a pricing bug.
      if (sku == null) continue;
      packages.add(
        PaywallPackage(
          sku: sku,
          productId: product.identifier,
          priceString: product.priceString,
          priceAmount: product.price,
        ),
      );
    }
    return packages;
  }

  @override
  Future<Entitlement> purchase(PaywallPackage package) async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) {
      throw StateError('No current offering configured in RevenueCat.');
    }
    final target = current.availablePackages.firstWhere(
      (candidate) => candidate.storeProduct.identifier == package.productId,
      orElse: () => throw StateError(
        'Product ${package.productId} is not in the current offering.',
      ),
    );

    // 8.11.0 returns CustomerInfo directly rather than a result wrapper.
    final info = await Purchases.purchasePackage(target);
    final entitlement = entitlementFromCustomerInfo(info);
    _cached = entitlement;
    return entitlement;
  }

  @override
  Future<Entitlement> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    final entitlement = entitlementFromCustomerInfo(info);
    _cached = entitlement;
    return entitlement;
  }
}
