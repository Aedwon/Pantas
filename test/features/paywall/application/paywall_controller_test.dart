import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  const package = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pantas_pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );

  test('purchase command returns confirmed entitlement after success',
      () async {
    final gateway = ControllerGateway();
    final controller = PaywallController(gateway);

    final result = await controller.purchase(package);

    expect(result.status, PaymentOperationStatus.success);
    expect(result.entitlement.proIsActive, isTrue);
    expect(result.errorMessage, isNull);
    expect(gateway.purchasedProductId, 'pantas_pro_monthly');
  });

  test('restore command returns confirmed entitlement after restore', () async {
    final gateway = ControllerGateway();
    final controller = PaywallController(gateway);

    final result = await controller.restore();

    expect(result.status, PaymentOperationStatus.success);
    expect(result.entitlement.proIsActive, isTrue);
    expect(result.errorMessage, isNull);
    expect(gateway.restoreCount, 1);
  });

  test('network failure exposes sheet error without fabricating entitlement',
      () async {
    final gateway = ControllerGateway(networkFailure: true);
    final controller = PaywallController(gateway);

    final result = await controller.purchase(package);

    expect(result.status, PaymentOperationStatus.networkFailure);
    expect(result.entitlement, const Entitlement.free());
    expect(
      result.errorMessage,
      "You need a connection to subscribe. Try again when you're back online.",
    );
  });
}

class ControllerGateway implements RevenueCatGateway {
  ControllerGateway({this.networkFailure = false});

  final bool networkFailure;
  String? purchasedProductId;
  int restoreCount = 0;

  @override
  Entitlement? cachedEntitlement = const Entitlement.free();

  @override
  Stream<Entitlement> get customerInfoUpdates => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> configure({required String androidApiKey}) async {}

  @override
  Future<PaywallOfferingResult> currentOffering() async =>
      const PaywallOfferingResult.noCurrentOffering();

  @override
  Future<void> logIn(String uid) async {}

  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async {
    if (networkFailure) {
      return const PaymentOperationResult.failure(
        status: PaymentOperationStatus.networkFailure,
      );
    }
    purchasedProductId = package.productId;
    cachedEntitlement = const Entitlement(plan: EntitlementPlan.monthly);
    return PaymentOperationResult.authoritative(
      status: PaymentOperationStatus.success,
      entitlement: cachedEntitlement!,
    );
  }

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    restoreCount += 1;
    cachedEntitlement = const Entitlement(plan: EntitlementPlan.monthly);
    return PaymentOperationResult.authoritative(
      status: PaymentOperationStatus.success,
      entitlement: cachedEntitlement!,
    );
  }
}
