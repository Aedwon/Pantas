import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a Pro entitlement reaches the mock cooldown', () async {
    final container = ProviderContainer(
      overrides: [
        ...mockEntitlementOverrides,
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(entitlementProvider.future);
    expect(container.read(mockEntitlementProvider).proIsActive, isTrue);
  });

  test('no entitlement reads as Free', () {
    final container = ProviderContainer(
      overrides: [
        ...mockEntitlementOverrides,
        entitlementProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(mockEntitlementProvider).proIsActive, isFalse);
  });
}
