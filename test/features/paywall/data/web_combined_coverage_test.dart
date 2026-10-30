import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';

void main() {
  final now = DateTime.utc(2026, 10, 20);
  Map<String, dynamic> row(String product, DateTime start, DateTime end) => {
        'source': 'paymongo',
        'product': product,
        'tier': 'civilService',
        'state': 'active',
        'startsAt': start.millisecondsSinceEpoch,
        'endsAt': end.millisecondsSinceEpoch,
      };
  test('an active promotion-only account shows Pro on web', () {
    final end = now.add(const Duration(days: 10));
    final entitlement = entitlementFromGrants(
      [row('promo_civil_service', now, end)],
      at: now,
    );
    expect(entitlement.proIsActive, isTrue);
    expect(entitlement.coverage(at: now).hasKnownCoverage, isTrue);
    expect(entitlement.endsAt, end);
    expect(entitlement.willRenew, isFalse);
  });
  for (final anchor in [
    'promo_civil_service',
    'pantas_cs_monthly',
    'pantas_pass_cse_pro',
  ]) {
    test('refresh keeps Pro through Monthly queued behind $anchor', () async {
      final end = now.add(const Duration(days: 10));
      final queuedEnd = end.add(const Duration(days: 30));
      final gateway = WebPaymentGateway(
        callable: (_, __) async => null,
        readGrants: (_) async => [
          row('pantas_cs_monthly', end, queuedEnd),
          row(anchor, now, end),
        ],
        refreshClaims: (_) async {},
        openUrl: (_) async => false,
        now: () => now,
      );
      await gateway.logIn('owner');
      final refreshed = await gateway.restorePurchases();
      final entitlement = refreshed.confirmedEntitlement!;
      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.expiresAt, queuedEnd);
      expect(entitlement.coverage(at: now).hasKnownCoverage, isTrue);
      expect(entitlement.coverage(at: end).hasKnownCoverage, isTrue);
      expect(entitlement.coverage(at: queuedEnd).hasKnownCoverage, isFalse);
    });
  }
  test('a future prepaid grant does not grant coverage before it starts', () {
    final entitlement = entitlementFromGrants(
      [
        row(
          'pantas_cs_monthly',
          now.add(const Duration(days: 10)),
          now.add(const Duration(days: 40)),
        ),
      ],
      at: now,
    );
    expect(entitlement.proIsActive, isFalse);
  });
  test('a gap does not extend current coverage', () {
    final end = now.add(const Duration(days: 10));
    final entitlement = entitlementFromGrants(
      [
        row('pantas_cs_monthly', now, end),
        row(
          'pantas_cs_monthly',
          end.add(const Duration(days: 1)),
          end.add(const Duration(days: 31)),
        ),
      ],
      at: now,
    );
    expect(entitlement.expiresAt, end);
  });
}
