import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

/// Audit ENT-06: the server's coverageAt counts an active `beta_reward` grant
/// with an exam id as that exam's coverage, for any catalog exam, from its
/// start to its end. The web mapper must agree.
void main() {
  final now = DateTime.parse('2026-11-25T12:00:00+08:00');
  const day = Duration(days: 1);

  Map<String, dynamic> reward(
    String examId, {
    String tier = 'licensure',
    String state = 'active',
    DateTime? startsAt,
    DateTime? endsAt,
  }) =>
      {
        'source': 'beta_reward',
        'product': 'beta_reward',
        'tier': tier,
        'examId': examId,
        'state': state,
        'startsAt': (startsAt ?? now.subtract(day)).millisecondsSinceEpoch,
        'endsAt': (endsAt ?? now.add(day * 365)).millisecondsSinceEpoch,
      };

  test('an active reward covers its own exam, for any exam, and no other', () {
    final held = entitlementFromGrants(
      [
        reward('exam_let'),
        reward('exam_pshs_nce', tier: 'nce'),
        reward('exam_cse_pro', tier: 'civilService'),
      ],
      at: now,
    );
    expect(held.proIsActive, isTrue);
    for (final exam in ['exam_let', 'exam_pshs_nce', 'exam_cse_pro']) {
      expect(held.coversExam(exam, at: now), isTrue, reason: exam);
    }
    expect(
      held.coversExam('exam_pnle', examTier: PriceTier.licensure, at: now),
      isFalse,
    );
    expect(
      held.coversExam(
        'exam_cse_sub',
        examTier: PriceTier.civilService,
        at: now,
      ),
      isFalse,
    );
  });

  test('a reward ends at its end time', () {
    final end = now.add(day);
    final rows = [reward('exam_let', endsAt: end)];
    expect(
      entitlementFromGrants(rows, at: now).coversExam('exam_let', at: now),
      isTrue,
    );
    final after = entitlementFromGrants(rows, at: end);
    expect(after.coversExam('exam_let', at: end), isFalse);
    expect(after.proIsActive, isFalse);
  });

  test('queued, expired, revoked and exam-less rewards cover nothing', () {
    for (final row in [
      reward('exam_let', startsAt: now.add(day)),
      reward('exam_let', endsAt: now),
      reward('exam_let', state: 'revoked'),
      reward('exam_let')..remove('examId'),
      reward(''),
    ]) {
      final held = entitlementFromGrants([row], at: now);
      expect(held.betaPasses, isEmpty, reason: '$row');
      expect(held.proIsActive, isFalse, reason: '$row');
      expect(
        held.coversExam('exam_let', examTier: PriceTier.licensure),
        isFalse,
      );
    }
  });

  test('two rewards for one exam keep the later end', () {
    final later = now.add(day * 400);
    final held = entitlementFromGrants(
      [reward('exam_let'), reward('exam_let', endsAt: later)],
      at: now,
    );
    expect(held.betaPasses['exam_let'], later.toUtc());
  });
}
