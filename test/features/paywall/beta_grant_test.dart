import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/offline_window.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

void main() {
  test('beta grant covers its exam only and ends at the cutoff', () {
    final end = DateTime.parse('2026-11-16T00:00:00+08:00');
    final rows = <Map<String, dynamic>>[
      {
        'source': 'beta',
        'product': 'beta_pro',
        'tier': 'civilService',
        'examId': 'exam_cse_pro',
        'state': 'active',
        'startsAt': end.millisecondsSinceEpoch - 1000,
        'endsAt': end.millisecondsSinceEpoch,
      }
    ];
    final held = entitlementFromGrants(
      rows,
      at: end.subtract(const Duration(seconds: 1)),
    );
    expect(held.betaPasses.keys, ['exam_cse_pro']);
    expect(entitlementFromGrants(rows, at: end).betaPasses, isEmpty);
  });
  test('cached beta has no offline grace; ordinary passes keep their grace',
      () async {
    final end = DateTime.parse('2026-11-16T00:00:00+08:00');
    final held = entitlementFromGrants(
      [
        <String, dynamic>{
          'source': 'beta',
          'product': 'beta_pro',
          'tier': 'civilService',
          'examId': 'exam_cse_pro',
          'state': 'active',
          'startsAt': end.millisecondsSinceEpoch - 1000,
          'endsAt': end.millisecondsSinceEpoch,
        }
      ],
      at: end.subtract(const Duration(seconds: 1)),
    );
    final store = EntitlementSnapshotStore.inMemory();
    await store.writeConfirmed(held);
    final cached = (await store.readConfirmed())!;
    for (final snapshot in [held, cached]) {
      expect(
        OfflineWindow.apply(
          snapshot,
          effectiveTime: end.subtract(const Duration(milliseconds: 1)),
          windowConsumed: false,
        ).coversExam('exam_cse_pro'),
        isTrue,
      );
      expect(
        OfflineWindow.apply(
          snapshot,
          effectiveTime: end,
          windowConsumed: false,
        ).coversExam('exam_cse_pro'),
        isFalse,
      );
    }
    const exam = 'exam_cse_pro';
    final ordinary =
        Entitlement(plan: EntitlementPlan.free, passes: {exam: end});
    expect(
      OfflineWindow.apply(ordinary, effectiveTime: end, windowConsumed: false)
          .coversExam(exam),
      isTrue,
    );
  });
  test('a purchase queued behind beta does not unlock another exam early', () {
    final end = DateTime.parse('2026-11-16T00:00:00+08:00');
    final rows = <Map<String, dynamic>>[
      {
        'source': 'beta',
        'product': 'beta_pro',
        'tier': 'civilService',
        'examId': 'exam_cse_pro',
        'state': 'active',
        'startsAt': end.millisecondsSinceEpoch - 1000,
        'endsAt': end.millisecondsSinceEpoch,
      },
      {
        'source': 'paymongo',
        'product': 'pantas_cs_monthly',
        'tier': 'civilService',
        'state': 'active',
        'startsAt': end.millisecondsSinceEpoch,
        'endsAt': end.add(const Duration(days: 30)).millisecondsSinceEpoch,
      },
    ];
    expect(
      entitlementFromGrants(
        rows,
        at: end.subtract(const Duration(seconds: 1)),
      ).coversExam(
        'exam_cse_sub',
        at: end.subtract(const Duration(seconds: 1)),
      ),
      isFalse,
    );
    expect(
      entitlementFromGrants(rows, at: end).coversExam(
        'exam_cse_sub',
        examTier: PriceTier.civilService,
        at: end,
      ),
      isTrue,
    );
  });
  test('expired cached beta reports Free to account and sync consumers', () {
    final expired = DateTime.now().subtract(const Duration(seconds: 1));
    final held = Entitlement(
      plan: EntitlementPlan.free,
      betaPasses: {'exam_cse_pro': expired},
    );
    expect(held.proIsActive, isFalse);
  });
}
