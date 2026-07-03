import 'dart:async';

import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('offeringsProvider sorts packages weekly monthly yearly', () async {
    final container = ProviderContainer(
      overrides: [
        revenueCatGatewayProvider.overrideWithValue(
          FakeGateway(
            packages: const [
              PaywallPackage(
                sku: PaywallSku.yearly,
                productId: 'pro_yearly',
                priceString: '₱499',
              ),
              PaywallPackage(
                sku: PaywallSku.weekly,
                productId: 'pro_weekly',
                priceString: '₱29',
              ),
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pro_monthly',
                priceString: '₱99',
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
      ['pro_weekly', 'pro_monthly', 'pro_yearly'],
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
  Future<void> configure({required String androidApiKey}) async {}

  @override
  Future<List<PaywallPackage>> currentOffering() async => packages;

  @override
  Future<void> logIn(String uid) async {}

  @override
  Future<Entitlement> purchase(PaywallPackage package) async {
    return const Entitlement(plan: EntitlementPlan.monthly);
  }

  @override
  Future<Entitlement> restorePurchases() async {
    return const Entitlement(plan: EntitlementPlan.monthly);
  }
}
