import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  test('entitlementProvider returns free when gateway has no cached info',
      () async {
    final container = ProviderContainer(
      overrides: [
        revenueCatGatewayProvider.overrideWithValue(FakeGateway()),
      ],
    );
    addTearDown(container.dispose);

    final entitlement = await container.read(entitlementProvider.future);

    expect(entitlement, const Entitlement.free());
  });

  test('entitlementProvider returns Pro when cached entitlement is active',
      () async {
    final container = ProviderContainer(
      overrides: [
        revenueCatGatewayProvider.overrideWithValue(
          FakeGateway(cached: const Entitlement(plan: EntitlementPlan.yearly)),
        ),
      ],
    );
    addTearDown(container.dispose);

    final entitlement = await container.read(entitlementProvider.future);

    expect(entitlement.proIsActive, isTrue);
  });

  test('paywallPackagesProvider sorts packages weekly monthly yearly',
      () async {
    final container = ProviderContainer(
      overrides: [
        revenueCatGatewayProvider.overrideWithValue(
          FakeGateway(
            packages: const [
              PaywallPackage(
                sku: PaywallSku.yearly,
                productId: 'pantas_pro_yearly',
                priceString: '₱799',
                priceAmount: 799,
              ),
              PaywallPackage(
                sku: PaywallSku.weekly,
                productId: 'pantas_pro_weekly',
                priceString: '₱29',
                priceAmount: 29,
              ),
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_pro_monthly',
                priceString: '₱99',
                priceAmount: 99,
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final packages = await container.read(paywallPackagesProvider.future);

    expect(
      packages.map((package) => package.productId),
      ['pantas_pro_weekly', 'pantas_pro_monthly', 'pantas_pro_yearly'],
    );
  });

  test('the gateway is disabled when no API key is configured', () {
    final container = ProviderContainer(
      overrides: [
        entitlementSnapshotStoreProvider.overrideWithValue(
          EntitlementSnapshotStore.inMemory(),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(
      container.read(revenueCatGatewayProvider),
      isA<DisabledRevenueCatGateway>(),
    );
  });

  test('the disabled gateway does not fabricate Pro on purchase', () async {
    const gateway = DisabledRevenueCatGateway();
    final result = await gateway.purchase(
      const PaywallPackage(
        sku: PaywallSku.monthly,
        productId: 'pantas_pro_monthly',
        priceString: '₱99',
        priceAmount: 99,
      ),
    );
    expect(result.status, PaymentOperationStatus.configurationFailure);
    expect(result.confirmedEntitlement, isNull);
  });

  test('gateway selection reads the config rather than being hard coded', () {
    final container = ProviderContainer(
      overrides: [
        pendingPurchaseStoreProvider.overrideWithValue(
          PendingPurchaseStore.inMemory(),
        ),
        revenueCatConfigProvider.overrideWithValue(
          RevenueCatConfig.fromEnvironment(androidApiKey: 'goog_test_key'),
        ),
        entitlementSnapshotStoreProvider.overrideWithValue(
          EntitlementSnapshotStore.inMemory(),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(
      container.read(revenueCatGatewayProvider),
      isA<LiveRevenueCatGateway>(),
    );
  });
}

class FakeGateway implements RevenueCatGateway {
  FakeGateway({
    Entitlement? cached,
    this.packages = const [],
  }) : cachedEntitlement = cached;

  final List<PaywallPackage> packages;
  @override
  Entitlement? cachedEntitlement;
  final _controller = StreamController<Entitlement>.broadcast();

  @override
  Stream<Entitlement> get customerInfoUpdates => _controller.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> configure({required String androidApiKey}) async {}

  @override
  Future<PaywallOfferingResult> currentOffering() async {
    return PaywallOfferingResult(
      status: packages.isEmpty
          ? PaywallOfferingStatus.emptyCurrentOffering
          : PaywallOfferingStatus.available,
      recognizedPackages: packages,
    );
  }

  @override
  Future<void> logIn(String uid) async {}

  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async {
    return const PaymentOperationResult.authoritative(
      status: PaymentOperationStatus.success,
      entitlement: Entitlement(plan: EntitlementPlan.monthly),
    );
  }

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    return const PaymentOperationResult.authoritative(
      status: PaymentOperationStatus.success,
      entitlement: Entitlement(plan: EntitlementPlan.monthly),
    );
  }
}
