import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/revenuecat_gateway.dart';
import '../domain/entitlement.dart';

final revenueCatGatewayProvider = Provider<RevenueCatGateway>(
  (ref) => const DisabledRevenueCatGateway(),
);

final entitlementProvider = StreamProvider<Entitlement>((ref) {
  final gateway = ref.watch(revenueCatGatewayProvider);
  final cached = gateway.cachedEntitlement ?? const Entitlement.free();
  return gateway.customerInfoUpdates.distinct().startWith(cached);
});

extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
