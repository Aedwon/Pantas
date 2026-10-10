import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
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

import '../data/verified_fixture.dart';

void main() {
  PaymentEntitlementState stateFor() {
    final values = <String, String>{};
    return PaymentEntitlementState(
      EntitlementSnapshotStore(
        readValue: (key) async => values[key],
        writeValue: (key, value) async => values[key] = value,
      ),
    );
  }

  test(
    'successful purchase is immediately observable through entitlementProvider',
    () async {
      final sdk = RuntimeSdk(
        purchaseInfo: const RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_monthly',
        ),
      );
      final gateway = LiveRevenueCatGateway(
        sdk: sdk,
        entitlementState: stateFor(),
      );
      await gateway.logIn('test-account');
      await gateway.initialize();
      final container = ProviderContainer(
        overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(container.dispose);
      container.listen(entitlementProvider, (_, __) {});
      await container.read(entitlementProvider.future);

      final result = await PaywallController(gateway).purchase(monthlyPackage);

      expect(result.status, PaymentOperationStatus.success);
      expect(
        container.read(entitlementProvider).value?.plan,
        EntitlementPlan.monthly,
      );
      expect(
        container.read(entitlementProvider).value?.productId,
        'pantas_pro_monthly',
      );
      expect(container.read(entitlementProvider).value?.verifiedAt, isNotNull);
    },
  );

  test(
    'successful restore is immediately observable through entitlementProvider',
    () async {
      final sdk = RuntimeSdk(
        restoreInfo: const RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_yearly',
        ),
      );
      final gateway = LiveRevenueCatGateway(
        sdk: sdk,
        entitlementState: stateFor(),
      );
      await gateway.logIn('test-account');
      await gateway.initialize();
      final container = ProviderContainer(
        overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(container.dispose);
      container.listen(entitlementProvider, (_, __) {});
      await container.read(entitlementProvider.future);

      final result = await PaywallController(gateway).restore();

      expect(result.status, PaymentOperationStatus.success);
      expect(
        container.read(entitlementProvider).value?.plan,
        EntitlementPlan.yearly,
      );
      expect(
        container.read(entitlementProvider).value?.productId,
        'pantas_pro_yearly',
      );
      expect(container.read(entitlementProvider).value?.verifiedAt, isNotNull);
    },
  );

  test('later duplicate listener delivery does not corrupt confirmed Pro',
      () async {
    final sdk = RuntimeSdk(
      purchaseInfo: const RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
      ),
    );
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      entitlementState: stateFor(),
    );
    await gateway.logIn('test-account');
    await gateway.initialize();
    final container = ProviderContainer(
      overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(container.dispose);
    container.listen(entitlementProvider, (_, __) {});
    await container.read(entitlementProvider.future);

    await PaywallController(gateway).purchase(monthlyPackage);
    sdk.emit(
      const RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
      ),
    );
    await pumpEventQueue();

    expect(
      container.read(entitlementProvider).value?.plan,
      EntitlementPlan.monthly,
    );
    expect(
      container.read(entitlementProvider).value?.productId,
      'pantas_pro_monthly',
    );
    expect(container.read(entitlementProvider).value?.verifiedAt, isNotNull);
    expect(container.read(entitlementProvider).hasError, isFalse);
  });

  test('RevenueCat configuration failure cannot escape bootstrap', () async {
    final gateway = LiveRevenueCatGateway(
      sdk: RuntimeSdk(configureFailure: RevenueCatFailureKind.configuration),
      entitlementState: stateFor(),
    );
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.configure(
      RevenueCatConfig.fromEnvironment(androidApiKey: 'rc_key'),
    );

    expect(gateway.cachedEntitlement, const Entitlement.free());
  });

  test('initial CustomerInfo failure cannot escape bootstrap', () async {
    final gateway = LiveRevenueCatGateway(
      sdk: RuntimeSdk(customerInfoFailure: RevenueCatFailureKind.network),
      entitlementState: stateFor(),
    );
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.configure(
      RevenueCatConfig.fromEnvironment(androidApiKey: 'rc_key'),
    );

    expect(gateway.cachedEntitlement, const Entitlement.free());
  });

  test('bootstrap hydrates durable entitlement even when API key is missing',
      () async {
    final values = <String, String>{};
    final seedStore = EntitlementSnapshotStore(
      readValue: (key) async => values[key],
      writeValue: (key, value) async => values[key] = value,
    );
    await seedStore.writeOwner('test-account');
    await seedStore.writeConfirmed(
      const Entitlement(
        plan: EntitlementPlan.yearly,
        productId: 'pantas_pro_yearly',
      ),
    );
    final gateway = LiveRevenueCatGateway(
      sdk: RuntimeSdk(),
      entitlementState: PaymentEntitlementState(
        EntitlementSnapshotStore(
          readValue: (key) async => values[key],
          writeValue: (key, value) async => values[key] = value,
        ),
      ),
    );

    await RevenueCatBootstrapper(gateway).configure(
      RevenueCatConfig.fromEnvironment(),
    );

    expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
  });

  test('canonical Android API-key define name stays stable', () {
    expect(revenueCatAndroidApiKeyDefine, 'REVENUECAT_ANDROID_API_KEY');
  });
}

const monthlyPackage = PaywallPackage(
  sku: PaywallSku.monthly,
  productId: 'pantas_pro_monthly',
  priceString: '₱99',
  priceAmount: 99,
);

class RuntimeSdk implements RevenueCatSdk {
  RuntimeSdk({
    this.customerInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
    this.purchaseInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
    this.restoreInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
    this.configureFailure,
    this.customerInfoFailure,
  });

  RevenueCatCustomerInfoSnapshot customerInfo;
  RevenueCatCustomerInfoSnapshot purchaseInfo;
  RevenueCatCustomerInfoSnapshot restoreInfo;
  RevenueCatFailureKind? configureFailure;
  RevenueCatFailureKind? customerInfoFailure;
  void Function(RevenueCatCustomerInfoSnapshot)? listener;

  @override
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfoSnapshot) onUpdate,
  ) {
    listener = onUpdate;
  }

  void emit(RevenueCatCustomerInfoSnapshot info) =>
      listener?.call(verifiedFixture(info));

  @override
  Future<void> logOut() async {}

  @override
  Future<void> invalidateCustomerInfoCache() async {}

  @override
  Future<void> configure(String androidApiKey) async {
    final failure = configureFailure;
    if (failure != null) throw RevenueCatSdkException(failure);
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() async {
    final failure = customerInfoFailure;
    if (failure != null) throw RevenueCatSdkException(failure);
    return verifiedFixture(customerInfo);
  }

  @override
  Future<RevenueCatOfferingSnapshot?> getCurrentOffering() async => null;

  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) async =>
      verifiedFixture(customerInfo);

  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(
    String productId, {
    String? oldProductId,
    bool allowTrial = true,
  }) async =>
      verifiedFixture(purchaseInfo);

  @override
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases() async =>
      verifiedFixture(restoreInfo);
}
