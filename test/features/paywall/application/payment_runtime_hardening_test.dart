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

  test('successful purchase is immediately observable through entitlementProvider',
      () async {
    final sdk = RuntimeSdk(
      purchaseInfo: RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
        willRenew: true,
      ),
    );
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      entitlementState: stateFor(),
    );
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
      container.read(entitlementProvider).value,
      const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );
  });

  test('successful restore is immediately observable through entitlementProvider',
      () async {
    final sdk = RuntimeSdk(
      restoreInfo: RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_yearly',
        willRenew: true,
      ),
    );
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      entitlementState: stateFor(),
    );
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
      container.read(entitlementProvider).value,
      const Entitlement(
        plan: EntitlementPlan.yearly,
        productId: 'pantas_pro_yearly',
      ),
    );
  });

  test('later duplicate listener delivery does not corrupt confirmed Pro',
      () async {
    final sdk = RuntimeSdk(
      purchaseInfo: RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
        willRenew: true,
      ),
    );
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      entitlementState: stateFor(),
    );
    await gateway.initialize();
    final container = ProviderContainer(
      overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(container.dispose);
    container.listen(entitlementProvider, (_, __) {});
    await container.read(entitlementProvider.future);

    await PaywallController(gateway).purchase(monthlyPackage);
    sdk.emit(
      RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
        willRenew: true,
      ),
    );
    await pumpEventQueue();

    expect(
      container.read(entitlementProvider).value,
      const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );
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

  void emit(RevenueCatCustomerInfoSnapshot info) => listener?.call(info);

  @override
  Future<void> configure(String androidApiKey) async {
    final failure = configureFailure;
    if (failure != null) throw RevenueCatSdkException(failure);
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() async {
    final failure = customerInfoFailure;
    if (failure != null) throw RevenueCatSdkException(failure);
    return customerInfo;
  }

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
