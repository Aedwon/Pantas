import 'dart:async';

import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

abstract interface class RevenueCatGateway {
  Stream<Entitlement> get customerInfoUpdates;
  Entitlement? get cachedEntitlement;

  Future<void> configure({required String androidApiKey});
  Future<void> logIn(String uid);
  Future<List<PaywallPackage>> currentOffering();
  Future<Entitlement> purchase(PaywallPackage package);
  Future<Entitlement> restorePurchases();
}

class DisabledRevenueCatGateway implements RevenueCatGateway {
  const DisabledRevenueCatGateway([
    this._cachedEntitlement = const Entitlement.free(),
  ]);

  final Entitlement _cachedEntitlement;

  @override
  Entitlement? get cachedEntitlement => _cachedEntitlement;

  @override
  Stream<Entitlement> get customerInfoUpdates =>
      Stream<Entitlement>.value(const Entitlement.free());

  @override
  Future<void> configure({required String androidApiKey}) async {}

  @override
  Future<List<PaywallPackage>> currentOffering() async => const [];

  @override
  Future<void> logIn(String uid) async {}

  @override
  Future<Entitlement> purchase(PaywallPackage package) async {
    return const Entitlement.free();
  }

  @override
  Future<Entitlement> restorePurchases() async => const Entitlement.free();
}
