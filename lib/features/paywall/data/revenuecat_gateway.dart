import 'dart:async';

import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

abstract interface class RevenueCatGateway {
  Stream<Entitlement> get customerInfoUpdates;
  Entitlement? get cachedEntitlement;

  Future<void> initialize();
  Future<void> configure({required String androidApiKey});
  Future<void> logIn(String uid);
  Future<PaywallOfferingResult> currentOffering();
  Future<PaymentOperationResult> purchase(PaywallPackage package);
  Future<PaymentOperationResult> restorePurchases();
}

class DisabledRevenueCatGateway implements RevenueCatGateway {
  const DisabledRevenueCatGateway([this._entitlementState]);

  final PaymentEntitlementState? _entitlementState;

  @override
  Entitlement? get cachedEntitlement =>
      _entitlementState?.current ?? const Entitlement.free();

  @override
  Stream<Entitlement> get customerInfoUpdates =>
      _entitlementState?.updates ??
      Stream<Entitlement>.value(const Entitlement.free());

  @override
  Future<void> initialize() async {
    await _entitlementState?.initialize();
  }

  @override
  Future<void> configure({required String androidApiKey}) async {}

  @override
  Future<PaywallOfferingResult> currentOffering() async =>
      const PaywallOfferingResult.noCurrentOffering();

  @override
  Future<void> logIn(String uid) async {}

  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async {
    return const PaymentOperationResult.failure(
      status: PaymentOperationStatus.configurationFailure,
    );
  }

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    return const PaymentOperationResult.failure(
      status: PaymentOperationStatus.configurationFailure,
    );
  }
}
