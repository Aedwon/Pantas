import 'dart:async';

import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const package = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pro_monthly',
    priceString: '₱99',
  );

  test('purchase command refreshes entitlement after successful purchase',
      () async {
    final gateway = ControllerGateway();
    final controller = PaywallController(gateway);

    final result = await controller.purchase(package);

    expect(result.entitlement.proIsActive, isTrue);
    expect(result.errorMessage, isNull);
    expect(gateway.purchasedProductId, 'pro_monthly');
  });

  test('restore command refreshes entitlement after restore', () async {
    final gateway = ControllerGateway();
    final controller = PaywallController(gateway);

    final result = await controller.restore();

    expect(result.entitlement.proIsActive, isTrue);
    expect(result.errorMessage, isNull);
    expect(gateway.restoreCount, 1);
  });

  test('purchase failure exposes sheet error without changing entitlement',
      () async {
    final gateway = ControllerGateway(shouldFailPurchase: true);
    final controller = PaywallController(gateway);

    final result = await controller.purchase(package);

    expect(result.entitlement, const Entitlement.free());
    expect(
      result.errorMessage,
      "You need a connection to subscribe. Try again when you're back "
      'online.',
    );
  });
}

class ControllerGateway implements RevenueCatGateway {
  ControllerGateway({this.shouldFailPurchase = false});

  final bool shouldFailPurchase;
  String? purchasedProductId;
  int restoreCount = 0;

  @override
  Entitlement? cachedEntitlement = const Entitlement.free();

  @override
  Stream<Entitlement> get customerInfoUpdates => const Stream.empty();

  @override
  Future<void> configure({required String androidApiKey}) async {}

  @override
  Future<List<PaywallPackage>> currentOffering() async => const [];

  @override
  Future<void> logIn(String uid) async {}

  @override
  Future<Entitlement> purchase(PaywallPackage package) async {
    if (shouldFailPurchase) throw Exception('offline');
    purchasedProductId = package.productId;
    cachedEntitlement = const Entitlement(plan: EntitlementPlan.monthly);
    return cachedEntitlement!;
  }

  @override
  Future<Entitlement> restorePurchases() async {
    restoreCount += 1;
    cachedEntitlement = const Entitlement(plan: EntitlementPlan.monthly);
    return cachedEntitlement!;
  }
}
