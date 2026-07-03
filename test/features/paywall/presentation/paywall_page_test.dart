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
    priceString: '₱499',
    priceAmount: 499,
  );
  testWidgets(
    'paywall renders Weekly Monthly Yearly in stable order',
    (tester) async {
      await tester.pumpWidget(
        const _Host(
          PaywallPage(
            packages: [yearly, monthly, weekly],
          ),
        ),
      );

      expect(
        _textTop(tester, 'Weekly'),
        lessThan(_textTop(tester, 'Monthly')),
      );
      expect(
        _textTop(tester, 'Monthly'),
        lessThan(_textTop(tester, 'Yearly')),
      );
    },
  );

  testWidgets(
    'weekly card states weekly renewal and monthly equivalent',
    (tester) async {
      await tester.pumpWidget(
        const _Host(
          PaywallPage(
            packages: [weekly, monthly, yearly],
          ),
        ),
      );

      expect(
        find.text(
          '₱29/week · ≈₱126/month · Renews every week · Cancel anytime',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'weekly recommendation selects weekly by default',
    (tester) async {
      await tester.pumpWidget(
        const _Host(
          PaywallPage(
            packages: [weekly, monthly, yearly],
            recommendedSku: PaywallSku.weekly,
          ),
        ),
      );

      expect(find.text('Best for your exam date'), findsOneWidget);
      expect(find.text('Get Pro. ₱29 a week.'), findsOneWidget);
    },
  );

  testWidgets('recommended package is selected by default', (tester) async {
    await tester.pumpWidget(
      const _Host(
        PaywallPage(
          packages: [monthly, yearly],
          recommendedSku: PaywallSku.monthly,
        ),
      ),
    );

    expect(find.text('Best for your exam date'), findsOneWidget);
    expect(find.text('Get Pro. ₱99 a month.'), findsOneWidget);
  });

  testWidgets(
    'yearly card always shows seven day free trial pill',
    (tester) async {
      await tester.pumpWidget(
        const _Host(
          PaywallPage(
            packages: [monthly, yearly],
            recommendedSku: PaywallSku.monthly,
          ),
        ),
      );

      expect(find.text('7 days free'), findsOneWidget);
    },
  );

  testWidgets('CTA changes when selected package changes', (tester) async {
    await tester.pumpWidget(
      const _Host(
        PaywallPage(
          packages: [monthly, yearly],
          recommendedSku: PaywallSku.monthly,
        ),
      ),
    );

    await tester.tap(find.text('Yearly'));
    await tester.pump();

    expect(find.text('Start my free trial'), findsOneWidget);
  });

  testWidgets('restore link calls restore command', (tester) async {
    var restored = false;
    await tester.pumpWidget(
      _Host(
        PaywallPage(
          packages: const [monthly, yearly],
          onRestore: () async => restored = true,
        ),
      ),
    );

    await tester.tap(find.text('Restore'));
    await tester.pump();

    expect(restored, isTrue);
  });

  testWidgets(
    'purchase error renders offline copy and keeps page open',
    (tester) async {
      await tester.pumpWidget(
        _Host(
          PaywallPage(
            packages: const [monthly, yearly],
            onPurchase: (_) async => const PaywallCommandResult(
              entitlement: Entitlement.free(),
              errorMessage:
                  'You need a connection to subscribe. Try again when '
                  "you're back online.",
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start my free trial'));
      await tester.pump();

      expect(find.text('Try Pro'), findsOneWidget);
      expect(
        find.text(
          "You need a connection to subscribe. Try again when you're back "
          'online.',
        ),
        findsOneWidget,
      );
    },
  );
}

class _Host extends StatelessWidget {
  const _Host(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(theme: buildLightTheme(), home: child),
    );
  }
}

double _textTop(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}
