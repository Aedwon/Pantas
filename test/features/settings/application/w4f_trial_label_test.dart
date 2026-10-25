import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

void main() {
  for (final days in [1, 2]) {
    test('trial root label uses correct day count for $days', () async {
      final container = ProviderContainer(
        overrides: [
          entitlementProvider.overrideWith(
            (ref) => Stream.value(
              Entitlement(
                plan: EntitlementPlan.monthly,
                isTrial: true,
                endsAt: DateTime.now().add(Duration(hours: days * 24 - 1)),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(entitlementProvider.future);
      expect(
        container.read(proRowValueProvider),
        'Trial, $days ${days == 1 ? 'day' : 'days'} left',
      );
    });
  }
}
