import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/paywall_recommendation.dart';
import '../data/revenuecat_gateway.dart';
import '../domain/entitlement.dart';
import 'paywall_controller.dart';

final revenueCatGatewayProvider = Provider<RevenueCatGateway>(
  (ref) => const DisabledRevenueCatGateway(),
);

final entitlementProvider = StreamProvider<Entitlement>((ref) {
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
