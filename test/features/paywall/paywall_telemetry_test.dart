import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

void main() {
  test('PaywallController emits purchaseStarted and purchaseCompleted',
      () async {
    final sink = RecordingTelemetrySink();
    final controller = PaywallController(
      FakeRevenueCatGateway(
        result: const PaymentOperationResult.authoritative(
          status: PaymentOperationStatus.success,
          entitlement: Entitlement(plan: EntitlementPlan.yearly),
        ),
      ),
      telemetry: sink,
    );

    const package = PaywallPackage(
      sku: PaywallSku.yearly,
      productId: 'pantas_pro_yearly',
      priceString: '₱799',
      priceAmount: 799,
    );

    await controller.purchase(package);
    await pumpEventQueue();

    expect(sink.loggedEvents, [
      TelemetryEvent.purchaseStarted,
      TelemetryEvent.purchaseCompleted,
    ]);
  });

  test('PaywallController emits purchaseFailed on typed failure', () async {
    final sink = RecordingTelemetrySink();
    final controller = PaywallController(
      FakeRevenueCatGateway(
        result: const PaymentOperationResult.failure(
          status: PaymentOperationStatus.networkFailure,
        ),
      ),
      telemetry: sink,
    );

    const package = PaywallPackage(
      sku: PaywallSku.yearly,
      productId: 'pantas_pro_yearly',
      priceString: '₱799',
      priceAmount: 799,
    );

    await controller.purchase(package);
    await pumpEventQueue();

    expect(sink.loggedEvents, [
      TelemetryEvent.purchaseStarted,
      TelemetryEvent.purchaseFailed,
    ]);
  });

  test('PaywallController does not log user cancellation as purchaseFailed',
      () async {
    final sink = RecordingTelemetrySink();
    final controller = PaywallController(
      FakeRevenueCatGateway(
        result: const PaymentOperationResult.failure(
          status: PaymentOperationStatus.userCancelled,
        ),
      ),
      telemetry: sink,
    );

    const package = PaywallPackage(
      sku: PaywallSku.yearly,
      productId: 'pantas_pro_yearly',
      priceString: '₱799',
      priceAmount: 799,
    );

    await controller.purchase(package);
    await pumpEventQueue();

    expect(sink.loggedEvents, [TelemetryEvent.purchaseStarted]);
  });
}

class FakeRevenueCatGateway implements RevenueCatGateway {
  FakeRevenueCatGateway({required this.result});

  final PaymentOperationResult result;

  @override
  Entitlement? get cachedEntitlement => const Entitlement.free();

  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async =>
      result;

  @override
  Future<PaymentOperationResult> restorePurchases() async => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RecordingTelemetrySink implements Telemetry {
  final loggedEvents = <TelemetryEvent>[];
  final loggedProperties = <Map<String, Object>?>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    loggedEvents.add(event);
    loggedProperties.add(properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}
