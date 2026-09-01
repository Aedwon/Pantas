import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';

class FakeRevenueCatGateway implements RevenueCatGateway {
  FakeRevenueCatGateway({
    Entitlement? initialCached,
    Stream<Entitlement>? updates,
  }) : _cachedEntitlement = initialCached {
    if (updates != null) {
      _subscription = updates.listen(
        (entitlement) {
          _cachedEntitlement = entitlement;
          _controller.add(entitlement);
        },
        onError: (Object error, StackTrace stack) {
          _controller.addError(error, stack);
        },
      );
    }
  }

  Entitlement? _cachedEntitlement;
  StreamSubscription<Entitlement>? _subscription;
  final StreamController<Entitlement> _controller =
      StreamController<Entitlement>.broadcast();

  @override
  Entitlement? get cachedEntitlement => _cachedEntitlement;

  @override
  Stream<Entitlement> get customerInfoUpdates => _controller.stream;

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
  Future<PaymentOperationResult> purchase(PaywallPackage package) async =>
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.entitlementNotActive,
        entitlement: Entitlement.free(),
      );

  @override
  Future<PaymentOperationResult> restorePurchases() async =>
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.noActiveSubscription,
        entitlement: Entitlement.free(),
      );

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

void main() {
  group('entitlementProvider offline & error resilience', () {
    test(
      '1. Cached Pro plus stream error yields Pro and stays Pro',
      () async {
        final gateway = FakeRevenueCatGateway(
          initialCached: const Entitlement(plan: EntitlementPlan.monthly),
          updates: Stream.error(Exception('Network socket failed')),
        );
        final container = ProviderContainer(
          overrides: [
            revenueCatGatewayProvider.overrideWithValue(gateway),
          ],
        );
        addTearDown(() {
          container.dispose();
          gateway.dispose();
        });

        container.listen(entitlementProvider, (_, __) {});
        await pumpEventQueue();

        final initial = container.read(entitlementProvider);
        expect(
          initial.value,
          const Entitlement(plan: EntitlementPlan.monthly),
        );
        expect(initial.hasError, isFalse);

        await pumpEventQueue();

        final afterError = container.read(entitlementProvider);
        expect(
          afterError.value,
          const Entitlement(plan: EntitlementPlan.monthly),
        );
        expect(afterError.hasError, isFalse);
      },
    );

    test(
      '2. Cached Pro plus successful Free response yields Free',
      () async {
        final controller = StreamController<Entitlement>.broadcast();
        final gateway = FakeRevenueCatGateway(
          initialCached: const Entitlement(plan: EntitlementPlan.monthly),
          updates: controller.stream,
        );
        final container = ProviderContainer(
          overrides: [
            revenueCatGatewayProvider.overrideWithValue(gateway),
          ],
        );
        addTearDown(() {
          container.dispose();
          gateway.dispose();
          controller.close();
        });

        container.listen(entitlementProvider, (_, __) {});
        await pumpEventQueue();

        expect(
          container.read(entitlementProvider).value,
          const Entitlement(plan: EntitlementPlan.monthly),
        );

        controller.add(const Entitlement.free());
        await pumpEventQueue();

        expect(
          container.read(entitlementProvider).value,
          const Entitlement.free(),
        );
        expect(container.read(entitlementProvider).hasError, isFalse);
      },
    );

    test(
      '3. Cold start with no cache and no network yields Free',
      () async {
        final gateway = FakeRevenueCatGateway(
          updates: Stream.error(TimeoutException('Network timeout')),
        );
        final container = ProviderContainer(
          overrides: [
            revenueCatGatewayProvider.overrideWithValue(gateway),
          ],
        );
        addTearDown(() {
          container.dispose();
          gateway.dispose();
        });

        container.listen(entitlementProvider, (_, __) {});
        await pumpEventQueue();

        final asyncValue = container.read(entitlementProvider);
        expect(asyncValue.value, const Entitlement.free());
        expect(asyncValue.hasError, isFalse);

        await pumpEventQueue();

        final afterError = container.read(entitlementProvider);
        expect(afterError.value, const Entitlement.free());
        expect(afterError.hasError, isFalse);
      },
    );

    test(
      '4. Persisted Pro survives a fresh gateway and provider container',
      () async {
        final values = <String, String>{};
        EntitlementSnapshotStore store() => EntitlementSnapshotStore(
              readValue: (key) async => values[key],
              writeValue: (key, value) async => values[key] = value,
            );

        await store().writeConfirmed(
          const Entitlement(
            plan: EntitlementPlan.monthly,
            productId: 'pantas_pro_monthly',
          ),
        );

        final freshState = PaymentEntitlementState(store());
        final freshGateway = DisabledRevenueCatGateway(freshState);
        await freshGateway.initialize();

        final container = ProviderContainer(
          overrides: [
            revenueCatGatewayProvider.overrideWithValue(freshGateway),
          ],
        );
        addTearDown(container.dispose);

        container.listen(entitlementProvider, (_, __) {});
        await pumpEventQueue();

        expect(
          container.read(entitlementProvider).value,
          const Entitlement(
            plan: EntitlementPlan.monthly,
            productId: 'pantas_pro_monthly',
          ),
        );
        expect(container.read(entitlementProvider).hasError, isFalse);
      },
    );

    test('5. No error state is ever surfaced from this provider', () async {
      final controller = StreamController<Entitlement>.broadcast();
      final gateway = FakeRevenueCatGateway(
        initialCached: const Entitlement(plan: EntitlementPlan.monthly),
        updates: controller.stream,
      );
      final container = ProviderContainer(
        overrides: [
          revenueCatGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(() {
        container.dispose();
        gateway.dispose();
        controller.close();
      });

      container.listen(entitlementProvider, (_, __) {});
      await pumpEventQueue();

      expect(container.read(entitlementProvider).hasError, isFalse);

      controller.addError(Exception('Socket closed'));
      await pumpEventQueue();
      expect(container.read(entitlementProvider).hasError, isFalse);

      controller.addError(TimeoutException('Request timed out'));
      await pumpEventQueue();
      expect(container.read(entitlementProvider).hasError, isFalse);

      expect(
        container.read(entitlementProvider).value,
        const Entitlement(plan: EntitlementPlan.monthly),
      );
    });
  });
}
