import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  testWidgets('free panel shows Try Pro and Restore purchases', (tester) async {
    await tester.pumpWidget(
      const _Host(
        SubscriptionPanel(entitlement: Entitlement.free()),
      ),
    );

    expect(find.text("You're on Free."), findsOneWidget);
    expect(find.text('Try Pro'), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('renewing paid panel says renews', (tester) async {
    await tester.pumpWidget(
      _Host(
        SubscriptionPanel(
          entitlement: Entitlement(
            plan: EntitlementPlan.monthly,
            productId: 'pantas_pro_monthly',
            expiresAt: DateTime.utc(2026, 6, 21),
          ),
        ),
      ),
    );

    expect(
      find.textContaining('Pro · Monthly · renews Jun 21'),
      findsOneWidget,
    );
    expect(find.text('Manage in Google Play'), findsOneWidget);
  });

  testWidgets('cancelled but active panel says ends, not renews',
      (tester) async {
    await tester.pumpWidget(
      _Host(
        SubscriptionPanel(
          entitlement: Entitlement(
            plan: EntitlementPlan.monthly,
            productId: 'pantas_pro_monthly',
            expiresAt: DateTime.utc(2026, 6, 21),
            willRenew: false,
          ),
        ),
      ),
    );

    expect(
      find.textContaining('Pro · Monthly · ends Jun 21'),
      findsOneWidget,
    );
    expect(find.textContaining('renews'), findsNothing);
  });

  testWidgets('trial panel identifies trial without stale hardcoded price',
      (tester) async {
    await tester.pumpWidget(
      _Host(
        SubscriptionPanel(
          today: DateTime.utc(2026, 5, 26),
          entitlement: Entitlement(
            plan: EntitlementPlan.yearly,
            productId: 'pantas_pro_yearly',
            expiresAt: DateTime.utc(2026, 5, 28),
            isTrial: true,
          ),
        ),
      ),
    );

    expect(
      find.textContaining('Pro trial · 2 days left · charges May 28'),
      findsOneWidget,
    );
    expect(find.textContaining('₱499'), findsNothing);
  });

  testWidgets('unknown active product is shown as Pro, never Free',
      (tester) async {
    await tester.pumpWidget(
      const _Host(
        SubscriptionPanel(
          entitlement: Entitlement.activeUnknown(productId: 'future_plan'),
        ),
      ),
    );

    expect(find.textContaining('Pro'), findsWidgets);
    expect(find.textContaining("You're on Free"), findsNothing);
    expect(find.textContaining('future_plan'), findsNothing);
  });
}

class _Host extends StatelessWidget {
  const _Host(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));
  }
}
