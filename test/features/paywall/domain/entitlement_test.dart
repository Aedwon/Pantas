import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('free entitlement reports pro inactive', () {
    const entitlement = Entitlement.free();

    expect(entitlement.proIsActive, isFalse);
    expect(entitlement.plan, EntitlementPlan.free);
  });

  test('active entitlement reports pro active with sku and expiration', () {
    final entitlement = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pro_monthly',
      expiresAt: DateTime.utc(2026, 6),
    );

    expect(entitlement.proIsActive, isTrue);
    expect(entitlement.productId, 'pro_monthly');
    expect(entitlement.expiresAt, DateTime.utc(2026, 6));
  });

  test('lifetime entitlement has no expiration and is active', () {
    const entitlement = Entitlement(
      plan: EntitlementPlan.lifetime,
      productId: 'pro_lifetime',
    );

    expect(entitlement.proIsActive, isTrue);
    expect(entitlement.isLifetime, isTrue);
    expect(entitlement.expiresAt, isNull);
  });

  test('entitlements compare by value', () {
    final first = Entitlement(
      plan: EntitlementPlan.yearly,
      productId: 'pro_yearly',
      expiresAt: DateTime.utc(2027),
      isTrial: true,
    );
    final second = Entitlement(
      plan: EntitlementPlan.yearly,
      productId: 'pro_yearly',
      expiresAt: DateTime.utc(2027),
      isTrial: true,
    );

    expect(first, second);
  });

  test('welcome state fires only on free to pro transition', () {
    expect(
      ProWelcomeState.shouldShow(
        previous: const Entitlement.free(),
        current: const Entitlement(plan: EntitlementPlan.monthly),
        alreadyWelcomed: false,
      ),
      isTrue,
    );
    expect(
      ProWelcomeState.shouldShow(
        previous: const Entitlement(plan: EntitlementPlan.monthly),
        current: const Entitlement(plan: EntitlementPlan.yearly),
        alreadyWelcomed: false,
      ),
      isFalse,
    );
    expect(
      ProWelcomeState.shouldShow(
        previous: const Entitlement.free(),
        current: const Entitlement(plan: EntitlementPlan.yearly),
        alreadyWelcomed: true,
      ),
      isFalse,
    );
  });
}
