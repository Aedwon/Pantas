import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const weekly = PaywallPackage(
    sku: PaywallSku.weekly,
    productId: 'pro_weekly',
    priceString: '₱29',
    priceAmount: 29,
  );
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );
  const yearly = PaywallPackage(
    sku: PaywallSku.yearly,
    productId: 'pro_yearly',
    priceString: '₱999',
    priceAmount: 999,
  );
  final packages = [weekly, monthly, yearly];

  Future<void> pumpPaywall(
    WidgetTester tester, {
    Future<PaywallCommandResult> Function(PaywallPackage)? onPurchase,
    Future<void> Function()? onRestore,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLightTheme(),
          home: PaywallPage(
            packages: packages,
            onPurchase: onPurchase,
            onRestore: onRestore,
          ),
        ),
      ),
    );
  }

  testWidgets('starts on screen 1 and See plans advances to screen 2',
      (tester) async {
    await pumpPaywall(tester);
    expect(find.text('Pro also adds'), findsOneWidget);
    await tester.ensureVisible(find.text('See plans'));
    await tester.tap(find.text('See plans'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly'), findsOneWidget);
  });

  testWidgets('choosing Yearly routes through the trial screen',
      (tester) async {
    await pumpPaywall(tester);
    await tester.ensureVisible(find.text('See plans'));
    await tester.tap(find.text('See plans'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Yearly'));
    await tester.tap(find.text('Yearly'));
    await tester.pump();
    await tester.ensureVisible(find.text('Start my free trial'));
    await tester.tap(find.text('Start my free trial'));
    await tester.pumpAndSettle();
    expect(find.text('How your free trial works'), findsOneWidget);
  });

  testWidgets(
      'choosing Monthly goes straight to purchase, with no trial screen',
      (tester) async {
    var purchased = 0;
    await pumpPaywall(tester, onPurchase: (_) async {
      purchased++;
      return const PaywallCommandResult(entitlement: Entitlement.free());
    });
    await tester.ensureVisible(find.text('See plans'));
    await tester.tap(find.text('See plans'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Monthly'));
    await tester.tap(find.text('Monthly'));
    await tester.pump();
    await tester.ensureVisible(find.textContaining('Get Pro.'));
    await tester.tap(find.textContaining('Get Pro.'));
    await tester.pumpAndSettle();
    expect(find.text('How your free trial works'), findsNothing);
    expect(purchased, 1);
  });

  testWidgets('restore link calls restore command', (tester) async {
    var restored = false;
    await pumpPaywall(tester, onRestore: () async => restored = true);

    await tester.tap(find.text('Restore'));
    await tester.pump();

    expect(restored, isTrue);
  });

  testWidgets('purchase error renders offline copy and keeps page open',
      (tester) async {
    await pumpPaywall(
      tester,
      onPurchase: (_) async => const PaywallCommandResult(
        entitlement: Entitlement.free(),
        errorMessage:
            'You need a connection to subscribe. Try again when '
            "you're back online.",
      ),
    );

    await tester.ensureVisible(find.text('See plans'));
    await tester.tap(find.text('See plans'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Monthly'));
    await tester.tap(find.text('Monthly'));
    await tester.pump();
    await tester.ensureVisible(find.textContaining('Get Pro.'));
    await tester.tap(find.textContaining('Get Pro.'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "You need a connection to subscribe. Try again when you're back "
        'online.',
      ),
      findsOneWidget,
    );
  });
}
