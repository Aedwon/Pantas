import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pro_monthly',
    priceString: '₱99',
  );
  const yearly = PaywallPackage(
    sku: PaywallSku.yearly,
    productId: 'pro_yearly',
    priceString: '₱499',
  );
  const lifetime = PaywallPackage(
    sku: PaywallSku.lifetime,
    productId: 'pro_lifetime',
    priceString: '₱1,499',
  );

  testWidgets('paywall renders Monthly Yearly Lifetime in stable order',
      (tester) async {
    await tester.pumpWidget(
      _Host(
        PaywallPage(
          packages: const [lifetime, yearly, monthly],
          recommendedSku: PaywallSku.yearly,
        ),
      ),
    );

    expect(_textTop(tester, 'Monthly'), lessThan(_textTop(tester, 'Yearly')));
    expect(_textTop(tester, 'Yearly'), lessThan(_textTop(tester, 'Lifetime')));
  });

  testWidgets('recommended package is selected by default', (tester) async {
    await tester.pumpWidget(
      _Host(
        PaywallPage(
          packages: const [monthly, yearly, lifetime],
          recommendedSku: PaywallSku.monthly,
        ),
      ),
    );

    expect(find.text('Best for your exam date'), findsOneWidget);
    expect(find.text('Get Pro - ₱99/month'), findsOneWidget);
  });

  testWidgets('yearly card always shows seven day free trial pill',
      (tester) async {
    await tester.pumpWidget(
      _Host(
        PaywallPage(
          packages: const [monthly, yearly, lifetime],
          recommendedSku: PaywallSku.monthly,
        ),
      ),
    );

    expect(find.text('7 days free'), findsOneWidget);
  });

  testWidgets('CTA changes when selected package changes', (tester) async {
    await tester.pumpWidget(
      _Host(
        PaywallPage(
          packages: const [monthly, yearly, lifetime],
          recommendedSku: PaywallSku.monthly,
        ),
      ),
    );

    await tester.tap(find.text('Lifetime'));
    await tester.pump();

    expect(find.text('Get Pro - ₱1,499 one-time'), findsOneWidget);
  });

  testWidgets('restore link calls restore command', (tester) async {
    var restored = false;
    await tester.pumpWidget(
      _Host(
        PaywallPage(
          packages: const [monthly, yearly, lifetime],
          recommendedSku: PaywallSku.yearly,
          onRestore: () async => restored = true,
        ),
      ),
    );

    await tester.tap(find.text('Restore'));
    await tester.pump();

    expect(restored, isTrue);
  });

  testWidgets('purchase error renders offline copy and keeps page open',
      (tester) async {
    await tester.pumpWidget(
      _Host(
        PaywallPage(
          packages: const [monthly, yearly, lifetime],
          recommendedSku: PaywallSku.yearly,
          onPurchase: (_) async => const PaywallCommandResult(
            entitlement: Entitlement.free(),
            errorMessage:
                "Couldn't reach Google Play. Check your connection and try again.",
          ),
        ),
      ),
    );

    await tester.tap(find.text('Start 7-day free trial'));
    await tester.pump();

    expect(find.text('Try Pro'), findsOneWidget);
    expect(
      find.text(
          "Couldn't reach Google Play. Check your connection and try again."),
      findsOneWidget,
    );
  });
}

class _Host extends StatelessWidget {
  const _Host(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: child);
  }
}

double _textTop(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}
