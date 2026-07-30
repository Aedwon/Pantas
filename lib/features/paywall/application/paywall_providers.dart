import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_recommendation.dart';

final revenueCatConfigProvider = Provider<RevenueCatConfig>(
  (ref) => RevenueCatConfig.fromEnvironment(),
);

final revenueCatGatewayProvider = Provider<RevenueCatGateway>((ref) {
  final config = ref.watch(revenueCatConfigProvider);
  if (!config.isEnabled) return const DisabledRevenueCatGateway();
  return LiveRevenueCatGateway();
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

final paywallPackagesProvider = FutureProvider((ref) async {
  final gateway = ref.watch(revenueCatGatewayProvider);
  final packages = await gateway.currentOffering();
  return paywallDisplayOrder(packages);
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
