import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';

void main() {
  tearDown(() => devProOverride.value = null);

  test('the switch is honored in debug builds and local runs only', () {
    expect(devProOverrideEnabled, kDebugMode || localEmulators);
    // A release build with neither must not read the switch.
    expect(kReleaseMode && !localEmulators && devProOverrideEnabled, isFalse);
  });

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
