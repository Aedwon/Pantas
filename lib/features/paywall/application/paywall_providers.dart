import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/paywall_recommendation.dart';

final revenueCatConfigProvider = Provider<RevenueCatConfig>(
  (ref) => RevenueCatConfig.fromEnvironment(),
);

final entitlementSnapshotStoreProvider = Provider<EntitlementSnapshotStore>((ref) {
  final preferences = ref.watch(appPreferencesRepositoryProvider);
  return EntitlementSnapshotStore(
    readValue: preferences.deviceValue,
    writeValue: preferences.setDeviceValue,
  );
});

final paymentEntitlementStateProvider = Provider<PaymentEntitlementState>((ref) {
  return PaymentEntitlementState(ref.watch(entitlementSnapshotStoreProvider));
});

final revenueCatGatewayProvider = Provider<RevenueCatGateway>((ref) {
  final config = ref.watch(revenueCatConfigProvider);
  if (!config.isEnabled) return const DisabledRevenueCatGateway();
  return LiveRevenueCatGateway(
    entitlementState: ref.watch(paymentEntitlementStateProvider),
  );
});

final entitlementProvider = StreamProvider<Entitlement>((ref) {
  if (kDebugMode) {
    // The switch `tools/pro` flips, which beats FAKE_PRO because it does not
    // need a rebuild to change.
    final override = ref.watch(devProOverrideProvider);
    if (override != null) {
      return Stream.value(
        override
            ? const Entitlement(plan: EntitlementPlan.monthly)
            : const Entitlement.free(),
      );
    }
  }
  if (kDebugMode && const bool.fromEnvironment('FAKE_PRO')) {
    return Stream.value(const Entitlement(plan: EntitlementPlan.monthly));
  }
  final gateway = ref.watch(revenueCatGatewayProvider);
  final cached = gateway.cachedEntitlement ?? const Entitlement.free();
  return gateway.customerInfoUpdates
      .handleError((Object error, StackTrace stack) {
        // Stream errors are treated as no news; entitlement never fails closed.
      })
      .distinct()
      .startWith(cached);
});

final paywallOfferingProvider = FutureProvider<PaywallOfferingResult>((ref) {
  return ref.watch(revenueCatGatewayProvider).currentOffering();
});

final paywallPackagesProvider = FutureProvider((ref) async {
  final offering = await ref.watch(paywallOfferingProvider.future);
  return paywallDisplayOrder(offering.recognizedPackages);
});

final paywallControllerProvider = Provider<PaywallController>((ref) {
  return PaywallController(
    ref.watch(revenueCatGatewayProvider),
    telemetry: ref.watch(telemetryProvider),
  );
});

extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
