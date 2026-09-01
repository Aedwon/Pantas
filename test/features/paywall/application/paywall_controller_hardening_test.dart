import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

void main() {
  const package = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pantas_pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );
  const pro = Entitlement(
    plan: EntitlementPlan.yearly,
    productId: 'pantas_pro_yearly',
  );

  test('network failure preserves the prior entitlement instead of making Free',
      () async {
    final gateway = ControlledGateway(cached: pro)
      ..purchaseResult = const PaymentOperationResult.failure(
        status: PaymentOperationStatus.networkFailure,
      );
    final controller = PaywallController(gateway);

    final result = await controller.purchase(package);

    expect(result.status, PaymentOperationStatus.networkFailure);
    expect(result.entitlement, pro);
    expect(result.entitlement.proIsActive, isTrue);
  });

  test('user cancellation is typed and does not expose an error message',
      () async {
    final gateway = ControlledGateway()
      ..purchaseResult = const PaymentOperationResult.failure(
        status: PaymentOperationStatus.userCancelled,
      );
    final controller = PaywallController(gateway);

    final result = await controller.purchase(package);

    expect(result.status, PaymentOperationStatus.userCancelled);
    expect(result.errorMessage, isNull);
  });

  test('double purchase is rejected while the first purchase is pending',
      () async {
    final gateway = ControlledGateway();
    final pending = Completer<PaymentOperationResult>();
    gateway.purchaseCompleter = pending;
    final controller = PaywallController(gateway);

    final first = controller.purchase(package);
    await Future<void>.delayed(Duration.zero);
    final second = await controller.purchase(package);

    expect(second.status, PaymentOperationStatus.operationAlreadyInProgress);
    expect(gateway.purchaseCount, 1);

    pending.complete(
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.success,
        entitlement: Entitlement(
          plan: EntitlementPlan.monthly,
          productId: 'pantas_pro_monthly',
        ),
      ),
    );
    await first;
  });

  test('restore is rejected while purchase is pending', () async {
    final gateway = ControlledGateway();
    final pending = Completer<PaymentOperationResult>();
    gateway.purchaseCompleter = pending;
    final controller = PaywallController(gateway);

    final first = controller.purchase(package);
    await Future<void>.delayed(Duration.zero);
    final restore = await controller.restore();

    expect(restore.status, PaymentOperationStatus.operationAlreadyInProgress);
    expect(gateway.restoreCount, 0);

    pending.complete(
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.success,
        entitlement: Entitlement(
          plan: EntitlementPlan.monthly,
          productId: 'pantas_pro_monthly',
        ),
      ),
    );
    await first;
  });

  test('purchase is rejected while restore is pending', () async {
    final gateway = ControlledGateway();
    final pending = Completer<PaymentOperationResult>();
    gateway.restoreCompleter = pending;
    final controller = PaywallController(gateway);

    final first = controller.restore();
    await Future<void>.delayed(Duration.zero);
    final purchase = await controller.purchase(package);

    expect(purchase.status, PaymentOperationStatus.operationAlreadyInProgress);
    expect(gateway.purchaseCount, 0);

    pending.complete(
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.success,
        entitlement: Entitlement(
          plan: EntitlementPlan.yearly,
          productId: 'pantas_pro_yearly',
        ),
      ),
    );
    await first;
  });

  test('double restore is rejected while the first restore is pending',
      () async {
    final gateway = ControlledGateway();
    final pending = Completer<PaymentOperationResult>();
    gateway.restoreCompleter = pending;
    final controller = PaywallController(gateway);

    final first = controller.restore();
    await Future<void>.delayed(Duration.zero);
    final second = await controller.restore();

    expect(second.status, PaymentOperationStatus.operationAlreadyInProgress);
    expect(gateway.restoreCount, 1);

    pending.complete(
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.noActiveSubscription,
        entitlement: Entitlement.free(),
      ),
    );
    await first;
  });

  test('guard releases after success', () async {
    final gateway = ControlledGateway();
    final pending = Completer<PaymentOperationResult>();
    gateway.purchaseCompleter = pending;
    final controller = PaywallController(gateway);

    final first = controller.purchase(package);
    pending.complete(
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.success,
        entitlement: Entitlement(
          plan: EntitlementPlan.monthly,
          productId: 'pantas_pro_monthly',
        ),
      ),
    );
    await first;

    gateway
      ..purchaseCompleter = null
      ..purchaseResult = const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.success,
        entitlement: Entitlement(
          plan: EntitlementPlan.monthly,
          productId: 'pantas_pro_monthly',
        ),
      );
    expect(
      (await controller.purchase(package)).status,
      PaymentOperationStatus.success,
    );
    expect(gateway.purchaseCount, 2);
  });

  test('guard releases after failure', () async {
    final gateway = ControlledGateway();
    final pending = Completer<PaymentOperationResult>();
    gateway.purchaseCompleter = pending;
    final controller = PaywallController(gateway);

    final first = controller.purchase(package);
    pending.complete(
      const PaymentOperationResult.failure(
        status: PaymentOperationStatus.networkFailure,
      ),
    );
    await first;

    gateway
      ..purchaseCompleter = null
      ..purchaseResult = const PaymentOperationResult.failure(
        status: PaymentOperationStatus.storeFailure,
      );
    expect(
      (await controller.purchase(package)).status,
      PaymentOperationStatus.storeFailure,
    );
    expect(gateway.purchaseCount, 2);
  });
}

class ControlledGateway implements RevenueCatGateway {
  ControlledGateway({Entitlement? cached})
      : cachedEntitlement = cached ?? const Entitlement.free();

  @override
  Entitlement? cachedEntitlement;
  PaymentOperationResult purchaseResult =
      const PaymentOperationResult.authoritative(
    status: PaymentOperationStatus.success,
    entitlement: Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_pro_monthly',
    ),
  );
  PaymentOperationResult restoreResult =
      const PaymentOperationResult.authoritative(
    status: PaymentOperationStatus.success,
    entitlement: Entitlement(
      plan: EntitlementPlan.yearly,
      productId: 'pantas_pro_yearly',
    ),
  );
  Completer<PaymentOperationResult>? purchaseCompleter;
  Completer<PaymentOperationResult>? restoreCompleter;
  int purchaseCount = 0;
  int restoreCount = 0;

  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async {
    purchaseCount += 1;
    final result =
        await (purchaseCompleter?.future ?? Future.value(purchaseResult));
    final confirmed = result.confirmedEntitlement;
    if (confirmed != null) cachedEntitlement = confirmed;
    return result;
  }

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    restoreCount += 1;
    final result =
        await (restoreCompleter?.future ?? Future.value(restoreResult));
    final confirmed = result.confirmedEntitlement;
    if (confirmed != null) cachedEntitlement = confirmed;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
