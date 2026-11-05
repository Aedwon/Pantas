import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

final _now = DateTime.utc(2026, 11, 5, 4);

Map<String, dynamic> _monthlyGrant() => {
      'source': 'paymongo',
      'product': 'pantas_cs_monthly',
      'tier': 'civilService',
      'startsAt': _now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
      'endsAt': _now.add(const Duration(days: 20)).millisecondsSinceEpoch,
      'state': 'active',
    };

/// A paying student reloads the page. The last confirmed Pro is on the device
/// and the server confirms the same Pro. Startup reads the entitlement before
/// the saved copy is loaded, so the screen must still end on Pro.
void main() {
  test('a reload keeps Pro when the saved copy equals the server answer',
      () async {
    final store = EntitlementSnapshotStore.inMemory();
    final saved = PaymentEntitlementState(store);
    await saved.initialize();
    await store.writeOwner('uid-paying');
    await saved.acceptAuthoritative(
      entitlementFromGrants([_monthlyGrant()], at: _now),
    );

    // A fresh page: new state over the same stored copy.
    final gateway = WebPaymentGateway(
      callable: (_, __) async => null,
      readGrants: (_) async => [_monthlyGrant()],
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
      entitlementState: PaymentEntitlementState(store),
      now: () => _now,
    );
    final container = ProviderContainer(
      overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(container.dispose);

    final seen = <bool>[];
    container.listen<AsyncValue<Entitlement>>(
      entitlementProvider,
      (_, next) {
        final value = next.valueOrNull;
        if (value != null) seen.add(value.proIsActive);
      },
      fireImmediately: true,
    );

    // Same order as startup: the provider is read first, then payments start.
    await container.pump();
    await gateway.configure(androidApiKey: 'unused');
    await gateway.logIn('uid-paying');
    await container.pump();

    expect(seen.last, isTrue, reason: 'Pro was lost on reload: $seen');
    expect(
      container.read(entitlementProvider).valueOrNull?.proIsActive,
      isTrue,
    );
  });
}
