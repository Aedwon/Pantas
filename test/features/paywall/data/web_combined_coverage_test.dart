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
