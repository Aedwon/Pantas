import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';

import 'live_revenuecat_gateway_hardening_test.dart';

void main() {
  test('AC-5 changing owner alone never relabels durable Pro evidence',
      () async {
    final values = <String, String>{};
    EntitlementSnapshotStore store() => EntitlementSnapshotStore(
          readValue: (key) async => values[key],
          writeValue: (key, value) async => values[key] = value,
        );
    final first = store();
    await first.writeOwner('account-a');
    await first.writeConfirmed(
      const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );
    await first.writeOwner('account-b');
    expect(await store().readOwner(), 'account-a');
  });

  test('AC-5 clearing wins over an older cache read', () async {
    final values = <String, String>{};
    final first = EntitlementSnapshotStore(
      readValue: (key) async => values[key],
      writeValue: (key, value) async => values[key] = value,
    );
    await first.writeOwner('account-a');
    await first.writeConfirmed(
      const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );
    final oldSnapshot = values[EntitlementSnapshotStore.storageKey];
    final read = Completer<String?>();
    final state = PaymentEntitlementState(
      EntitlementSnapshotStore(
        readValue: (_) => read.future,
        writeValue: (key, value) async => values[key] = value,
      ),
    );
    final initialize = state.initialize();
    await pumpEventQueue();
    await state.clear();
    read.complete(oldSnapshot);
    await initialize;
    expect(state.current?.proIsActive, isFalse);
  });

  test('AC-5 clearing during hydration cancels the old identity request',
      () async {
    final read = Completer<String?>();
    final state = PaymentEntitlementState(
      EntitlementSnapshotStore(
        readValue: (_) => read.future,
        writeValue: (_, __) async {},
      ),
    );
    final sdk = IdentitySdk();
    final gateway = LiveRevenueCatGateway(sdk: sdk, entitlementState: state);
    final login = gateway.logIn('account-a');
    await pumpEventQueue();
    await gateway.clearIdentity();
    read.complete(null);
    await login;
    expect(sdk.loginCalls, 0);
  });

  test('AC-5 disabled SDK clears another account but keeps its own cache',
      () async {
    final store = EntitlementSnapshotStore.inMemory();
    final state = PaymentEntitlementState(store);
    await state.writeOwner('account-a');
    await state.acceptAuthoritative(
      const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );
    final gateway = DisabledRevenueCatGateway(state);
    await gateway.logIn('account-a');
    expect(gateway.cachedEntitlement?.proIsActive, isTrue);
    await gateway.logIn('account-b');
    expect(gateway.cachedEntitlement?.proIsActive, isFalse);
  });

  test('AC-5 another account sees Free when its identity fetch is offline',
      () async {
    final store = EntitlementSnapshotStore.inMemory();
    final state = PaymentEntitlementState(store);
    final sdk = IdentitySdk()
      ..customerInfo = const RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
      );
    final gateway = LiveRevenueCatGateway(sdk: sdk, entitlementState: state);
    await gateway.logIn('account-a');
    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.monthly);
    sdk.loginFailure = true;
    await expectLater(
      gateway.logIn('account-b'),
      throwsA(isA<RevenueCatSdkException>()),
    );
    expect(gateway.cachedEntitlement?.proIsActive, isFalse);
    expect((await store.readConfirmed())?.proIsActive ?? false, isFalse);
  });

  test('AC-5 a late old-account login cannot restore cleared payment state',
      () async {
    final sdk = IdentitySdk()
      ..waitForLogin = Completer<void>()
      ..customerInfo = const RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
      );
    final gateway = LiveRevenueCatGateway(sdk: sdk);
    final login = gateway.logIn('account-a');
    await pumpEventQueue();
    await gateway.clearIdentity();
    sdk.waitForLogin!.complete();
    await login;
    expect(gateway.cachedEntitlement?.proIsActive, isFalse);
    expect(
      (await gateway.purchase(monthlyPackage)).status,
      PaymentOperationStatus.operationAlreadyInProgress,
    );
  });

  test('AC-5 clearing during owner binding rejects the old login answer',
      () async {
    final state = HeldOwnerState();
    final sdk = IdentitySdk()
      ..customerInfo = const RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
      );
    final gateway = LiveRevenueCatGateway(sdk: sdk, entitlementState: state);
    final login = gateway.logIn('account-a');
    await pumpEventQueue();
    await gateway.clearIdentity();
    state.release.complete();
    await login;
    expect(gateway.cachedEntitlement?.proIsActive, isFalse);
  });

  test('AC-11 a signed restore grants only the newly associated local account',
      () async {
    final sdk = IdentitySdk();
    final gateway = LiveRevenueCatGateway(sdk: sdk);
    await gateway.logIn('account-a');
    await gateway.logIn('account-b');
    expect(gateway.cachedEntitlement?.proIsActive, isFalse);
    sdk.restoreInfo = const RevenueCatCustomerInfoSnapshot.active(
      productId: 'pantas_pro_monthly',
    );
    expect(
      (await gateway.restorePurchases()).status,
      PaymentOperationStatus.success,
    );
    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.monthly);
  });

  test('AC-5 purchase waits for RevenueCat identity, including initial login',
      () async {
    final sdk = IdentitySdk()..waitForLogin = Completer<void>();
    final gateway = LiveRevenueCatGateway(sdk: sdk);
    expect(
      (await gateway.purchase(monthlyPackage)).status,
      PaymentOperationStatus.operationAlreadyInProgress,
    );
    final login = gateway.logIn('account-a');
    await pumpEventQueue();
    expect(
      (await gateway.purchase(monthlyPackage)).status,
      PaymentOperationStatus.operationAlreadyInProgress,
    );
    expect(sdk.purchases, 0);
    sdk.waitForLogin!.complete();
    await login;
    await gateway.purchase(monthlyPackage);
    expect(sdk.purchases, 1);
  });
}

class IdentitySdk extends FakeRevenueCatSdk {
  bool loginFailure = false;
  Completer<void>? waitForLogin;
  int purchases = 0;
  int loginCalls = 0;
  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) async {
    loginCalls++;
    await waitForLogin?.future;
    if (loginFailure) {
      throw const RevenueCatSdkException(RevenueCatFailureKind.network);
    }
    return super.logIn(uid);
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(
    String productId, {
    String? oldProductId,
    bool allowTrial = true,
  }) async {
    purchases++;
    return super.purchase(
      productId,
      oldProductId: oldProductId,
      allowTrial: allowTrial,
    );
  }
}

class HeldOwnerState extends PaymentEntitlementState {
  HeldOwnerState() : super(EntitlementSnapshotStore.inMemory());
  final release = Completer<void>();
  @override
  Future<void> writeOwner(String uid) async {
    await super.writeOwner(uid);
    await release.future;
  }
}
