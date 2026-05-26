import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('free panel shows Try Pro and Restore Purchases', (tester) async {
    await tester.pumpWidget(
      const _Host(
        SubscriptionPanel(entitlement: Entitlement.free()),
      ),
    );

    expect(find.text("You're on Free."), findsOneWidget);
    expect(find.text('Try Pro'), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
  });

  testWidgets('monthly panel shows renews date and manage action',
      (tester) async {
    await tester.pumpWidget(
      _Host(
        SubscriptionPanel(
          entitlement: Entitlement(
            plan: EntitlementPlan.monthly,
            productId: 'pro_monthly',
            expiresAt: DateTime.utc(2026, 6, 21),
          ),
        ),
      ),
    );

    expect(
        find.textContaining('Pro · Monthly · renews Jun 21'), findsOneWidget);
    expect(find.text('Manage in Google Play'), findsOneWidget);
  });

  testWidgets('yearly trial panel shows days left and charge date',
      (tester) async {
    await tester.pumpWidget(
      _Host(
        SubscriptionPanel(
          today: DateTime.utc(2026, 5, 26),
          entitlement: Entitlement(
            plan: EntitlementPlan.yearly,
            productId: 'pro_yearly',
            expiresAt: DateTime.utc(2026, 5, 28),
            isTrial: true,
          ),
        ),
      ),
    );

    expect(
      find.textContaining('Pro trial · 2 days left · then ₱499/year on May 28'),
      findsOneWidget,
    );
  });

  testWidgets('lifetime panel shows yours forever and no manage action',
      (tester) async {
    await tester.pumpWidget(
      const _Host(
        SubscriptionPanel(
          entitlement: Entitlement(plan: EntitlementPlan.lifetime),
        ),
      ),
    );

    expect(find.text('Pro · Lifetime · yours forever.'), findsOneWidget);
    expect(find.text('Manage in Google Play'), findsNothing);
  });

  testWidgets('cancelled but active panel says ends date', (tester) async {
    await tester.pumpWidget(
      _Host(
        SubscriptionPanel(
          entitlement: Entitlement(
            plan: EntitlementPlan.monthly,
            expiresAt: DateTime.utc(2026, 6, 21),
            willRenew: false,
          ),
        ),
      ),
    );

    expect(find.textContaining("ends Jun 21 (won't renew)"), findsOneWidget);
  });
}

class _Host extends StatelessWidget {
  const _Host(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
