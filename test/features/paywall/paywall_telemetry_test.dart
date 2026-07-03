import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_controller.dart';
import 'package:cse_cet_reviewer/features/paywall/data/revenuecat_gateway.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PaywallController emits purchaseStarted and purchaseCompleted',
      () async {
    final sink = RecordingTelemetrySink();
    final controller = PaywallController(
      FakeRevenueCatGateway(
        entitlementToReturn: const Entitlement(plan: EntitlementPlan.yearly),
      ),
      telemetry: sink,
    );

    const package = PaywallPackage(
      sku: PaywallSku.yearly,
      productId: 'p_yearly',
      priceString: '₱999',
      priceAmount: 999,
    );

    await controller.purchase(package);

    expect(sink.loggedEvents, [
      TelemetryEvent.purchaseStarted,
      TelemetryEvent.purchaseCompleted,
    ]);
  });

  test('PaywallController emits purchaseFailed on error', () async {
    final sink = RecordingTelemetrySink();
    final controller = PaywallController(
      FakeRevenueCatGateway(shouldThrow: true),
      telemetry: sink,
    );

    const package = PaywallPackage(
      sku: PaywallSku.yearly,
      productId: 'p_yearly',
      priceString: '₱999',
      priceAmount: 999,
    );

    await controller.purchase(package);

    expect(sink.loggedEvents, [
      TelemetryEvent.purchaseStarted,
      TelemetryEvent.purchaseFailed,
    ]);
  });
}

class FakeRevenueCatGateway implements RevenueCatGateway {
  FakeRevenueCatGateway({
    this.entitlementToReturn = const Entitlement.free(),
    this.shouldThrow = false,
  });

  final Entitlement entitlementToReturn;
  final bool shouldThrow;

  @override
  Future<Entitlement> purchase(PaywallPackage package) async {
    if (shouldThrow) throw Exception('Purchase failed');
    return entitlementToReturn;
  }

  @override
  Future<Entitlement> restorePurchases() async => entitlementToReturn;

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
