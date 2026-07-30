import 'package:pantas/features/paywall/paywall.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('trial notice starts on day five and reports days remaining', () {
    final entitlement = Entitlement(
      plan: EntitlementPlan.yearly,
      productId: 'pro_yearly',
      expiresAt: DateTime.utc(2026, 5, 28),
      isTrial: true,
    );

    final notice = TrialNotice.fromEntitlement(
      entitlement,
      today: DateTime.utc(2026, 5, 26),
    );

    expect(notice, isNotNull);
    expect(notice!.daysRemaining, 2);
    expect(notice.chargeDate, DateTime.utc(2026, 5, 28));
  });

  test('trial notice is hidden before day five', () {
    final entitlement = Entitlement(
      plan: EntitlementPlan.yearly,
      expiresAt: DateTime.utc(2026, 5, 28),
      isTrial: true,
    );

    expect(
      TrialNotice.fromEntitlement(
        entitlement,
        today: DateTime.utc(2026, 5, 24),
      ),
      isNull,
    );
  });

  test('trial notice is hidden after conversion cancellation or expiration',
      () {
    final converted = Entitlement(
      plan: EntitlementPlan.yearly,
      expiresAt: DateTime.utc(2026, 5, 28),
    );
    final cancelled = Entitlement(
      plan: EntitlementPlan.yearly,
      expiresAt: DateTime.utc(2026, 5, 28),
      isTrial: true,
      willRenew: false,
    );
    final expired = Entitlement(
      plan: EntitlementPlan.free,
      expiresAt: DateTime.utc(2026, 5, 20),
      isTrial: true,
      willRenew: false,
    );

    expect(
      TrialNotice.fromEntitlement(
        converted,
        today: DateTime.utc(2026, 5, 26),
      ),
      isNull,
    );
    expect(
      TrialNotice.fromEntitlement(
        cancelled,
        today: DateTime.utc(2026, 5, 26),
      ),
      isNull,
    );
    expect(
      TrialNotice.fromEntitlement(
        expired,
        today: DateTime.utc(2026, 5, 26),
      ),
      isNull,
    );
  });
}
