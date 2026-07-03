import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_controller.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/paywall/presentation/paywall_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Paywall offline copy', () {
    testWidgets('displays copy replacing CTA when purchase fails offline',
        (tester) async {
      await tester.pumpWidget(
        // PaywallPage reads a provider in initState to emit its telemetry
        // event, so it needs a scope even when the test drives it directly.
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: PaywallPage(
              packages: const [
                PaywallPackage(
                  sku: PaywallSku.monthly,
                  productId: 'pro_monthly',
                  priceString: '₱149',
                ),
              ],
              onPurchase: (_) async => const PaywallCommandResult(
                entitlement: Entitlement.free(),
                errorMessage:
                    "You need a connection to subscribe. Try again when you're "
                    'back online.',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Get Pro. ₱149 a month.'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "You need a connection to subscribe. Try again when you're back "
          'online.',
        ),
        findsOneWidget,
      );
      expect(find.text('Get Pro. ₱149 a month.'), findsNothing);
    });

    testWidgets('displays copy when packages list is empty offline',
        (tester) async {
      await tester.pumpWidget(
        // PaywallPage reads a provider in initState to emit its telemetry
        // event, so it needs a scope even when the test drives it directly.
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const PaywallPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          "You need a connection to subscribe. Try again when you're back "
          'online.',
        ),
        findsOneWidget,
      );
    });
  });
}
