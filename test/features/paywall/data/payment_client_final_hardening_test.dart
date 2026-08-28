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

    failWrites = false;
    await state.acceptAuthoritative(const Entitlement.free());
    expect(await store.readConfirmed(), const Entitlement.free());
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
    );

    await gateway.initialize();
    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    await gateway.configure(androidApiKey: 'rc_key');

    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    expect(
      (await stateFor(values)..initialize()).current?.plan,
      EntitlementPlan.yearly,
    );
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
    );
    await gateway.configure(androidApiKey: 'rc_key');

    sdk.emit(const RevenueCatCustomerInfoSnapshot.inactive());
    await pumpEventQueue();

    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    final freshProcess = stateFor(values);
    await freshProcess.initialize();
    expect(freshProcess.current?.plan, EntitlementPlan.yearly);
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
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() async => customerInfo;

  @override
  Future<RevenueCatOfferingSnapshot?> getCurrentOffering() async => null;

  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) async => customerInfo;

  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(String productId) async =>
      purchaseInfo;

  @override
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases() async => restoreInfo;
}
