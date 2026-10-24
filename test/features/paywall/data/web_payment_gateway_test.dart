import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

final _now = DateTime.utc(2026, 11, 2, 4);
const _day = Duration(days: 1);

Map<String, dynamic> _grant(
  String product, {
  required DateTime ends,
  DateTime? starts,
  String state = 'active',
  String source = 'paymongo',
  String tier = 'civilService',
}) =>
    {
      'source': source,
      'product': product,
      'tier': tier,
      'startsAt': (starts ?? _now).millisecondsSinceEpoch,
      'endsAt': ends.millisecondsSinceEpoch,
      'state': state,
      'createdAt': _now.millisecondsSinceEpoch,
    };

Map<String, dynamic> _trial({
  required DateTime ends,
  String state = 'active',
}) =>
    _grant(
      'web_trial',
      ends: ends,
      state: state,
      source: 'trial',
    );

void main() {
  group('grant ledger mapping', () {
    test('an active subscription grant becomes a prepaid plan', () {
      final ends = _now.add(const Duration(days: 30));
      final entitlement = entitlementFromGrants(
        [_grant('pantas_cs_monthly', ends: ends)],
        at: _now,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.plan, EntitlementPlan.monthly);
      expect(entitlement.productId, 'pantas_cs_monthly');
      expect(entitlement.tier, PriceTier.civilService);
      expect(entitlement.isTrial, isFalse);
      expect(entitlement.expiresAt, ends);
      expect(entitlement.endsAt, ends);
      // Prepaid access never renews, so no renewal or charge date is shown.
      expect(entitlement.willRenew, isFalse);
      expect(entitlement.renewsAt, isNull);
      expect(entitlement.chargesAt, isNull);
      expect(
        entitlement.coversExam(
          'exam_cse_pro',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isTrue,
      );
      expect(
        entitlement.coversExam(
          'exam_lic',
          examTier: PriceTier.licensure,
          at: _now,
        ),
        isFalse,
      );
    });

    test('a trial grant is a trial that never charges', () {
      final ends = _now.add(const Duration(days: 7));
      final entitlement = entitlementFromGrants(
        [_trial(ends: ends)],
        at: _now,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.isTrial, isTrue);
      expect(entitlement.state, EntitlementState.trial);
      expect(entitlement.tier, PriceTier.civilService);
      expect(entitlement.endsAt, ends);
      expect(entitlement.chargesAt, isNull);
      expect(entitlement.renewsAt, isNull);
      expect(
        entitlement.coversExam(
          'exam_cse_sub',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isTrue,
      );
    });

    test('a pass grant covers only its own exam', () {
      final ends = _now.add(const Duration(days: 120));
      final entitlement = entitlementFromGrants(
        [_grant('pantas_pass_cse_pro', ends: ends)],
        at: _now,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.passes, {'exam_cse_pro': ends});
      expect(entitlement.subscriptions, isEmpty);
      expect(entitlement.coversExam('exam_cse_pro', at: _now), isTrue);
      expect(
        entitlement.coversExam(
          'exam_cse_sub',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isFalse,
      );
    });

    test('a revoked grant covers nothing', () {
      final entitlement = entitlementFromGrants(
        [
          _grant(
            'pantas_cs_yearly',
            ends: _now.add(const Duration(days: 300)),
            state: 'revoked',
          ),
          _trial(ends: _now.add(_day), state: 'revoked'),
        ],
        at: _now,
      );

      expect(entitlement, const Entitlement.free());
      expect(entitlement.proIsActive, isFalse);
    });

    test('an expired grant covers nothing', () {
      final entitlement = entitlementFromGrants(
        [
          _grant('pantas_cs_weekly', ends: _now.subtract(_day)),
          _grant('pantas_cs_monthly', ends: _now),
        ],
        at: _now,
      );

      expect(entitlement, const Entitlement.free());
    });

    test('stacked grants cover until the latest end', () {
      final first = _now.add(const Duration(days: 7));
      final second = _now.add(const Duration(days: 37));
      final entitlement = entitlementFromGrants(
        [
          _grant('pantas_cs_monthly', ends: second, starts: first),
          _grant('pantas_cs_weekly', ends: first),
        ],
        at: _now,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.subscriptions, hasLength(2));
      expect(entitlement.endsAt, second);
      expect(entitlement.plan, EntitlementPlan.monthly);
      expect(entitlement.expiresAt, second);
      // Both grants stay covered as time passes, with no second read.
      expect(
        entitlement.coversExam(
          'exam_cse_pro',
          examTier: PriceTier.civilService,
          at: first.add(_day),
        ),
        isTrue,
      );
    });

    test('rows that are not recognized grants are ignored', () {
      final ends = _now.add(const Duration(days: 30));
      final entitlement = entitlementFromGrants(
        [
          _grant('pantas_future_plan', ends: ends),
          _grant('promo_civil_service', ends: ends),
          _trial(ends: ends)..['tier'] = 'licensure',
          {'product': 'pantas_cs_monthly', 'state': 'active'},
          {
            ..._grant('pantas_cs_monthly', ends: ends),
            'endsAt': 'soon',
          },
        ],
        at: _now,
      );

      expect(entitlement, const Entitlement.free());
    });
  });
}
