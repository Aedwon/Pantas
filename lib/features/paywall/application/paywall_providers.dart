import 'package:cse_cet_reviewer/features/paywall/application/paywall_controller.dart';
import 'package:cse_cet_reviewer/features/paywall/data/revenuecat_gateway.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_recommendation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final revenueCatGatewayProvider = Provider<RevenueCatGateway>(
  (ref) => const DisabledRevenueCatGateway(),
);

final entitlementProvider = StreamProvider<Entitlement>((ref) {
  if (kDebugMode && const bool.fromEnvironment('FAKE_PRO')) {
    return Stream.value(const Entitlement(plan: EntitlementPlan.monthly));
  }
  final gateway = ref.watch(revenueCatGatewayProvider);
  final cached = gateway.cachedEntitlement ?? const Entitlement.free();
  return gateway.customerInfoUpdates.distinct().startWith(cached);
});

final paywallPackagesProvider = FutureProvider((ref) async {
  final gateway = ref.watch(revenueCatGatewayProvider);
  final packages = await gateway.currentOffering();
  return paywallDisplayOrder(packages);
});

final paywallControllerProvider = Provider<PaywallController>((ref) {
  return PaywallController(ref.watch(revenueCatGatewayProvider));
});

extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
