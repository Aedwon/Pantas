import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/presentation/paywall_page.dart';

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
                  priceAmount: 149,
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

      // The paywall now opens on screen 1, which sells Pro without reading
      // any student data. The purchase CTA lives on screen 2.
      await tester.ensureVisible(find.text('See plans'));
      await tester.tap(find.text('See plans'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Get Pro. ₱149 a month.'));
      await tester.tap(find.text('Get Pro. ₱149 a month.'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "You need a connection to subscribe. Try again when you're back "
          'online.',
        ),
        findsOneWidget,
      );
      // The CTA stays. A failed purchase that removes the only way to try
      // again strands a student who just lost signal for a moment.
      expect(find.text('Get Pro. ₱149 a month.'), findsOneWidget);
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
