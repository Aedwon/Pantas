import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/application/revenuecat_bootstrap.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

final referenceTime = DateTime.utc(2026, 8, 28, 4, 30);

void main() {
  test('purchase stays successful and publishes Pro when persistence fails',
      () async {
    final state = PaymentEntitlementState(failingWriteStore());
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        purchaseInfo: const RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_monthly',
        ),
      ),
      entitlementState: state,
    );
    await gateway.initialize();
    final container = ProviderContainer(
      overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(container.dispose);
    container.listen(entitlementProvider, (_, __) {});
    await container.read(entitlementProvider.future);

    final result = await gateway.purchase(monthlyPackage);
    await pumpEventQueue();

    expect(result.status, PaymentOperationStatus.success);
    expect(result.confirmedEntitlement?.plan, EntitlementPlan.monthly);
    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.monthly);
    expect(
      container.read(entitlementProvider).value?.plan,
      EntitlementPlan.monthly,
    );
    expect(state.hasPendingPersistence, isTrue);
  });

  test('restore stays successful and publishes Pro when persistence fails',
      () async {
    final state = PaymentEntitlementState(failingWriteStore());
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        restoreInfo: const RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_yearly',
        ),
      ),
      entitlementState: state,
    );
    await gateway.initialize();
    final container = ProviderContainer(
      overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(container.dispose);
    container.listen(entitlementProvider, (_, __) {});
    await container.read(entitlementProvider.future);

    final result = await gateway.restorePurchases();
    await pumpEventQueue();

    expect(result.status, PaymentOperationStatus.success);
    expect(result.confirmedEntitlement?.plan, EntitlementPlan.yearly);
    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    expect(
      container.read(entitlementProvider).value?.plan,
      EntitlementPlan.yearly,
    );
    expect(state.hasPendingPersistence, isTrue);
  });

  test('authoritative Free wins in memory and later converges to storage',
      () async {
    final values = <String, String>{};
    var failWrites = false;
    final store = EntitlementSnapshotStore(
      readValue: (key) async => values[key],
      writeValue: (key, value) async {
        if (failWrites) throw StateError('device preferences unavailable');
        values[key] = value;
      },
    );
    final state = PaymentEntitlementState(store);
    await state.acceptAuthoritative(
      const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );

    failWrites = true;
    await expectLater(
      state.acceptAuthoritative(const Entitlement.free()),
      completes,
    );
    expect(state.current, const Entitlement.free());
    expect(state.hasPendingPersistence, isTrue);

    failWrites = false;
    await state.acceptAuthoritative(const Entitlement.free());
    expect(await store.readConfirmed(), const Entitlement.free());
    expect(state.hasPendingPersistence, isFalse);
  });

  test('bootstrap keeps authoritative Pro when local persistence fails',
      () async {
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        customerInfo: const RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_monthly',
        ),
      ),
      entitlementState: PaymentEntitlementState(failingWriteStore()),
    );

    await RevenueCatBootstrapper(gateway).configure(
      RevenueCatConfig.fromEnvironment(androidApiKey: 'rc_key'),
    );

    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.monthly);
  });

  test('persisted Pro survives inactive CustomerInfo without fresh metadata',
      () async {
    final values = <String, String>{};
    await seedPro(values);
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(),
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );

    await gateway.initialize();
    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    await gateway.configure(androidApiKey: 'rc_key');

    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    final freshProcess = stateFor(values);
    await freshProcess.initialize();
    expect(freshProcess.current?.plan, EntitlementPlan.yearly);
  });

  test('stale inactive startup data cannot revoke hydrated Pro', () async {
    final values = <String, String>{};
    await seedPro(values);
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        customerInfo: RevenueCatCustomerInfoSnapshot.inactive(
          requestDate: referenceTime.subtract(const Duration(minutes: 6)),
        ),
      ),
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );

    await gateway.configure(androidApiKey: 'rc_key');

    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    final freshProcess = stateFor(values);
    await freshProcess.initialize();
    expect(freshProcess.current?.plan, EntitlementPlan.yearly);
  });

  test('fresh inactive startup data revokes hydrated Pro', () async {
    final values = <String, String>{};
    await seedPro(values);
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        customerInfo: RevenueCatCustomerInfoSnapshot.inactive(
          requestDate: referenceTime.subtract(const Duration(minutes: 4)),
        ),
      ),
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );

    await gateway.configure(androidApiKey: 'rc_key');

    expect(gateway.cachedEntitlement, const Entitlement.free());
    final freshProcess = stateFor(values);
    await freshProcess.initialize();
    expect(freshProcess.current, const Entitlement.free());
  });

  test('inactive listener without fresh metadata cannot revoke persisted Pro',
      () async {
    final values = <String, String>{};
    await seedPro(values);
    final sdk = FinalHardeningSdk(
      customerInfo: const RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_yearly',
      ),
    );
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );
    await gateway.configure(androidApiKey: 'rc_key');

    sdk.emit(const RevenueCatCustomerInfoSnapshot.inactive());
    await pumpEventQueue();

    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    final freshProcess = stateFor(values);
    await freshProcess.initialize();
    expect(freshProcess.current?.plan, EntitlementPlan.yearly);
  });

  test('fresh inactive listener revokes persisted Pro', () async {
    final values = <String, String>{};
    await seedPro(values);
    final sdk = FinalHardeningSdk(
      customerInfo: const RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_yearly',
      ),
    );
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );
    await gateway.configure(androidApiKey: 'rc_key');

    sdk.emit(
      RevenueCatCustomerInfoSnapshot.inactive(
        requestDate: referenceTime.subtract(const Duration(minutes: 1)),
      ),
    );
    await pumpEventQueue();

    expect(gateway.cachedEntitlement, const Entitlement.free());
    final freshProcess = stateFor(values);
    await freshProcess.initialize();
    expect(freshProcess.current, const Entitlement.free());
  });

  test('stale inactive purchase keeps Pro but reports entitlement not active',
      () async {
    final values = <String, String>{};
    await seedPro(values);
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        purchaseInfo: RevenueCatCustomerInfoSnapshot.inactive(
          requestDate: referenceTime.subtract(const Duration(minutes: 6)),
        ),
      ),
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );

    final result = await gateway.purchase(monthlyPackage);

    expect(result.status, PaymentOperationStatus.entitlementNotActive);
    expect(result.confirmedEntitlement?.plan, EntitlementPlan.yearly);
    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
  });

  test('fresh inactive purchase revokes Pro with typed inactive result',
      () async {
    final values = <String, String>{};
    await seedPro(values);
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        purchaseInfo: RevenueCatCustomerInfoSnapshot.inactive(
          requestDate: referenceTime.subtract(const Duration(minutes: 1)),
        ),
      ),
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );

    final result = await gateway.purchase(monthlyPackage);

    expect(result.status, PaymentOperationStatus.entitlementNotActive);
    expect(result.confirmedEntitlement, const Entitlement.free());
    expect(gateway.cachedEntitlement, const Entitlement.free());
  });

  test('stale inactive restore keeps Pro but reports no active subscription',
      () async {
    final values = <String, String>{};
    await seedPro(values);
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        restoreInfo: RevenueCatCustomerInfoSnapshot.inactive(
          requestDate: referenceTime.subtract(const Duration(minutes: 6)),
        ),
      ),
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );

    final result = await gateway.restorePurchases();

    expect(result.status, PaymentOperationStatus.noActiveSubscription);
    expect(result.confirmedEntitlement?.plan, EntitlementPlan.yearly);
    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
  });

  test('fresh inactive restore revokes Pro with typed no-active result',
      () async {
    final values = <String, String>{};
    await seedPro(values);
    final gateway = LiveRevenueCatGateway(
      sdk: FinalHardeningSdk(
        restoreInfo: RevenueCatCustomerInfoSnapshot.inactive(
          requestDate: referenceTime.subtract(const Duration(minutes: 1)),
        ),
      ),
      entitlementState: stateFor(values),
      referenceTime: () => referenceTime,
    );

    final result = await gateway.restorePurchases();

    expect(result.status, PaymentOperationStatus.noActiveSubscription);
    expect(result.confirmedEntitlement, const Entitlement.free());
    expect(gateway.cachedEntitlement, const Entitlement.free());
  });
}

const monthlyPackage = PaywallPackage(
  sku: PaywallSku.monthly,
  productId: 'pantas_pro_monthly',
  priceString: '₱99',
  priceAmount: 99,
);

EntitlementSnapshotStore failingWriteStore() {
  return EntitlementSnapshotStore(
    readValue: (key) async => null,
    writeValue: (key, value) async {
      throw StateError('device preferences unavailable');
    },
  );
}

PaymentEntitlementState stateFor(Map<String, String> values) {
  return PaymentEntitlementState(
    EntitlementSnapshotStore(
      readValue: (key) async => values[key],
      writeValue: (key, value) async => values[key] = value,
    ),
  );
}

Future<void> seedPro(Map<String, String> values) async {
  final state = stateFor(values);
  await state.acceptAuthoritative(
    const Entitlement(
      plan: EntitlementPlan.yearly,
      productId: 'pantas_pro_yearly',
    ),
  );
}

class FinalHardeningSdk implements RevenueCatSdk {
  FinalHardeningSdk({
    this.customerInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
    this.purchaseInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
    this.restoreInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
  });

  RevenueCatCustomerInfoSnapshot customerInfo;
  RevenueCatCustomerInfoSnapshot purchaseInfo;
  RevenueCatCustomerInfoSnapshot restoreInfo;
  void Function(RevenueCatCustomerInfoSnapshot)? listener;

  @override
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfoSnapshot) onUpdate,
  ) {
    listener = onUpdate;
  }

  void emit(RevenueCatCustomerInfoSnapshot info) => listener?.call(info);

  @override
  Future<void> configure(String androidApiKey) async {}

  @override
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() async {
    return customerInfo;
  }

  @override
  Future<RevenueCatOfferingSnapshot?> getCurrentOffering() async => null;

  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) async {
    return customerInfo;
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(String productId) async =>
      purchaseInfo;

  @override
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases() async {
    return restoreInfo;
  }
}
