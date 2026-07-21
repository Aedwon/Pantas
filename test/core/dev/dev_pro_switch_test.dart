import 'package:cse_cet_reviewer/core/dev/dev_pro_switch.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:cse_cet_reviewer/features/paywall/data/revenuecat_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => devProOverride.value = null);

  test('no override leaves the store entitlement in charge', () {
    final container = ProviderContainer(
      overrides: [
        revenueCatGatewayProvider
            .overrideWithValue(const DisabledRevenueCatGateway()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(devProOverrideProvider), isNull);
  });

  test('the switch turns Pro on without a restart', () async {
    final container = ProviderContainer(
      overrides: [
        revenueCatGatewayProvider
            .overrideWithValue(const DisabledRevenueCatGateway()),
      ],
    );
    addTearDown(container.dispose);

    // Something has to be listening, or the entitlement is never built.
    final subscription = container.listen(entitlementProvider, (_, __) {});
    addTearDown(subscription.close);

    devProOverride.value = true;
    await container.read(entitlementProvider.future);

    expect(
      container.read(entitlementProvider).valueOrNull?.proIsActive,
      isTrue,
    );
  });

  test('the switch turns Pro back off', () async {
    final container = ProviderContainer(
      overrides: [
        revenueCatGatewayProvider
            .overrideWithValue(const DisabledRevenueCatGateway()),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(entitlementProvider, (_, __) {});
    addTearDown(subscription.close);

    devProOverride.value = false;
    await container.read(entitlementProvider.future);

    expect(
      container.read(entitlementProvider).valueOrNull?.proIsActive,
      isFalse,
    );
  });
}
