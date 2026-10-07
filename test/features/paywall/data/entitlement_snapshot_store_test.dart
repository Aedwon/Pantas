import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

void main() {
  EntitlementSnapshotStore storeFor(Map<String, String> values) {
    return EntitlementSnapshotStore(
      readValue: (key) async => values[key],
      writeValue: (key, value) async => values[key] = value,
    );
  }

  test('new tier, ledger, state and dates survive a snapshot round trip',
      () async {
    final values = <String, String>{};
    final end = DateTime.utc(2027, 3, 14);
    final confirmed = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_pro_monthly',
      tier: PriceTier.student,
      state: EntitlementState.billingIssue,
      expiresAt: DateTime.utc(2026, 11, 7),
      endsAt: end,
      renewsAt: DateTime.utc(2026, 11, 7),
      passes: {'exam_cse_pro': end},
      subscriptions: [
        CoveragePeriod(id: 'pantas_pro_monthly', endsAt: end),
      ],
      promotions: [CoveragePeriod(id: 'promo_student', endsAt: end)],
      examTiers: const {'exam_upcat': PriceTier.student},
    );
    await storeFor(values).writeConfirmed(confirmed);
    expect(await storeFor(values).readConfirmed(), confirmed);
  });

  test('old snapshot derives the known product tier and cancellation state',
      () async {
    final values = {
      EntitlementSnapshotStore.storageKey: jsonEncode({
        'plan': 'monthly',
        'productId': 'pantas_cs_monthly',
        'expiresAt': '2026-11-07T00:00:00Z',
        'willRenew': false,
        'isTrial': false,
        'unknown': false,
      }),
    };
    final recovered = await storeFor(values).readConfirmed();
    expect(recovered!.tier, PriceTier.civilService);
    expect(recovered.state, EntitlementState.canceledActive);
    expect(recovered.passes, isEmpty);
  });

  test('confirmed Pro survives a fresh snapshot-store instance', () async {
    final values = <String, String>{};
    final first = storeFor(values);
    final confirmed = Entitlement(
      plan: EntitlementPlan.yearly,
      productId: 'pantas_pro_yearly',
      expiresAt: DateTime.utc(2027, 8, 28),
      isTrial: true,
      willRenew: false,
    );

    await first.writeConfirmed(confirmed);

    final second = storeFor(values);
    expect(await second.readConfirmed(), confirmed);
  });

  test('authoritative Free revokes a persisted Pro snapshot', () async {
    final values = <String, String>{};
    await storeFor(values).writeConfirmed(
      const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );

    await storeFor(values).writeConfirmed(const Entitlement.free());

    expect(
      await storeFor(values).readConfirmed(),
      const Entitlement.free(),
    );
  });

  test('unknown active product round-trips without losing its raw id',
      () async {
    final values = <String, String>{};
    final unknown = Entitlement.activeUnknown(
      productId: 'pantas_pro_future:future-base-plan',
      expiresAt: DateTime.utc(2027, 9),
    );

    await storeFor(values).writeConfirmed(unknown);
    final recovered = await storeFor(values).readConfirmed();

    expect(recovered?.proIsActive, isTrue);
    expect(recovered?.isUnknownPlan, isTrue);
    expect(recovered?.productId, 'pantas_pro_future:future-base-plan');
  });
}
