import 'dart:async';

import 'package:pantas/features/paywall/application/offline_window.dart';
import 'package:pantas/features/paywall/application/trusted_clock.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';

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

abstract interface class RevenueCatAccountGateway implements RevenueCatGateway {
  Future<void> clearIdentity();
  Future<void> logOut();
}

class DisabledRevenueCatGateway implements RevenueCatAccountGateway {
  const DisabledRevenueCatGateway([this._entitlementState, this._clock]);

  final TrustedClock? _clock;

  final PaymentEntitlementState? _entitlementState;

  @override
  Entitlement? get cachedEntitlement {
    final current = _entitlementState?.current ?? const Entitlement.free();
    final clock = _clock;
    return clock == null
        ? current
        : OfflineWindow.apply(
            current,
            effectiveTime: clock.effectiveTime,
            windowConsumed: clock.windowConsumed,
          );
  }

  @override
  Stream<Entitlement> get customerInfoUpdates {
    final updates = _entitlementState?.updates ??
        Stream<Entitlement>.value(const Entitlement.free());
    final clock = _clock;
    return clock == null
        ? updates
        : OfflineWindow.watch(
            updates,
            confirmed: () =>
                _entitlementState?.current ?? const Entitlement.free(),
            clock: clock,
          );
  }

  @override
  Future<void> initialize() async {
    await _clock?.start();
    await _entitlementState?.initialize();
  }

  @override
  Future<void> configure({required String androidApiKey}) async {}

  @override
  Future<PaywallOfferingResult> currentOffering() async =>
      const PaywallOfferingResult.noCurrentOffering();

  @override
  Future<void> logIn(String uid) async {
    await initialize();
    final state = _entitlementState;
    if (state != null && await state.readOwner() != uid) {
      await state.clear();
    }
  }

  @override
  Future<void> clearIdentity() async {
    await _entitlementState?.clear();
  }

  @override
  Future<void> logOut() => clearIdentity();

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
