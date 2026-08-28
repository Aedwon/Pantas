import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  const weekly = PaywallPackage(
    sku: PaywallSku.weekly,
    productId: 'pantas_pro_weekly',
    priceString: '₱29',
    priceAmount: 29,
  );
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pantas_pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );
  const yearly = PaywallPackage(
    sku: PaywallSku.yearly,
    productId: 'pantas_pro_yearly',
    priceString: '₱799',
    priceAmount: 799,
  );
  const packages = [weekly, monthly, yearly];

  Widget paymentScope(Widget child, RecordingGateway gateway) {
    return ProviderScope(
      overrides: [
        revenueCatGatewayProvider.overrideWithValue(gateway),
        entitlementSnapshotStoreProvider.overrideWithValue(
          EntitlementSnapshotStore.inMemory(),
        ),
      ],
      child: child,
    );
  }

  Future<void> pumpPaywall(
    WidgetTester tester, {
    RecordingGateway? gateway,
    Future<PaywallCommandResult> Function(PaywallPackage)? onPurchase,
    Future<PaywallCommandResult> Function()? onRestore,
  }) {
    final resolvedGateway = gateway ?? RecordingGateway();
    return tester.pumpWidget(
      paymentScope(
        MaterialApp(
          theme: buildLightTheme(),
          home: PaywallPage(
            packages: packages,
            onPurchase: onPurchase,
            onRestore: onRestore,
          ),
        ),
        resolvedGateway,
      ),
    );
  }

  Future<void> goToMonthlyPurchase(WidgetTester tester) async {
    await tester.ensureVisible(find.text('See plans'));
    await tester.tap(find.text('See plans'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Monthly'));
    await tester.tap(find.text('Monthly'));
    await tester.pump();
  }

  testWidgets('production Restore calls the payment controller', (tester) async {
    final gateway = RecordingGateway(
      restoreResult: const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.noActiveSubscription,
        entitlement: Entitlement.free(),
      ),
    );
    await pumpPaywall(tester, gateway: gateway);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(gateway.restoreCalls, 1);
  });

  testWidgets('restore with active Pro honors returnTo', (tester) async {
    final gateway = RecordingGateway(
      restoreResult: const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.success,
        entitlement: Entitlement(plan: EntitlementPlan.monthly),
      ),
    );
    final router = GoRouter(
      initialLocation: '/paywall?returnTo=%2Fprogress',
      routes: [
        GoRoute(
          path: '/paywall',
          builder: (_, state) => PaywallPage(
            packages: packages,
            returnTo: state.uri.queryParameters['returnTo'],
          ),
        ),
        GoRoute(path: '/progress', builder: (_, __) => const Text('Progress')),
        GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      paymentScope(
        MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
        gateway,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsOneWidget);
    expect(gateway.restoreCalls, 1);
  });

  testWidgets('restore with no active purchase stays and explains calmly',
      (tester) async {
    final gateway = RecordingGateway(
      restoreResult: const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.noActiveSubscription,
        entitlement: Entitlement.free(),
      ),
    );
    await pumpPaywall(tester, gateway: gateway);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Try Pro'), findsOneWidget);
    expect(
      find.text(
        "We couldn't find an active Pro subscription on this Google Play account.",
      ),
      findsOneWidget,
    );
    expect(find.textContaining('connection'), findsNothing);
  });

  testWidgets('pending restore disables duplicate invocation', (tester) async {
    final completer = Completer<PaymentOperationResult>();
    final gateway = RecordingGateway(restoreCompleter: completer);
    await pumpPaywall(tester, gateway: gateway);

    await tester.tap(find.text('Restore'));
    await tester.pump();

    expect(find.text('Restoring...'), findsOneWidget);
    expect(gateway.restoreCalls, 1);
    final restoreButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Restoring...'),
    );
    expect(restoreButton.onPressed, isNull);

    completer.complete(
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.noActiveSubscription,
        entitlement: Entitlement.free(),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('purchase cancellation shows no error and stays on paywall',
      (tester) async {
    await pumpPaywall(
      tester,
      onPurchase: (_) async => const PaywallCommandResult(
        status: PaymentOperationStatus.userCancelled,
        entitlement: Entitlement.free(),
      ),
    );
    await goToMonthlyPurchase(tester);

    await tester.tap(find.text('Get Pro. ₱99 a month.'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly'), findsOneWidget);
    expect(find.textContaining('failed'), findsNothing);
    expect(find.textContaining("couldn't"), findsNothing);
  });

  testWidgets('network purchase failure replaces CTA with retry action',
      (tester) async {
    await pumpPaywall(
      tester,
      onPurchase: (_) async => const PaywallCommandResult(
        status: PaymentOperationStatus.networkFailure,
        entitlement: Entitlement.free(),
      ),
    );
    await goToMonthlyPurchase(tester);

    await tester.tap(find.text('Get Pro. ₱99 a month.'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "You need a connection to subscribe. Try again when you're back online.",
      ),
      findsOneWidget,
    );
    expect(find.text('Get Pro. ₱99 a month.'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.text('Get Pro. ₱99 a month.'), findsOneWidget);
  });

  testWidgets('pending purchase disables duplicate invocation', (tester) async {
    final completer = Completer<PaywallCommandResult>();
    var calls = 0;
    await pumpPaywall(
      tester,
      onPurchase: (_) {
        calls++;
        return completer.future;
      },
    );
    await goToMonthlyPurchase(tester);

    await tester.tap(find.text('Get Pro. ₱99 a month.'));
    await tester.pump();

    expect(find.text('Processing...'), findsOneWidget);
    expect(calls, 1);
    final pendingInkWell = tester.widget<InkWell>(
      find
          .ancestor(
            of: find.text('Processing...'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    expect(pendingInkWell.onTap, isNull);

    completer.complete(
      const PaywallCommandResult(
        status: PaymentOperationStatus.userCancelled,
        entitlement: Entitlement.free(),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('successful purchase honors returnTo even with a stack',
      (tester) async {
    final gateway = RecordingGateway();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
        GoRoute(
          path: '/paywall',
          builder: (_, state) => PaywallPage(
            packages: packages,
            returnTo: state.uri.queryParameters['returnTo'],
            onPurchase: (_) async => const PaywallCommandResult(
              entitlement: Entitlement(plan: EntitlementPlan.monthly),
            ),
          ),
        ),
        GoRoute(path: '/progress', builder: (_, __) => const Text('Progress')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      paymentScope(
        MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
        gateway,
      ),
    );
    await tester.pumpAndSettle();
    router.push('/paywall?returnTo=%2Fprogress');
    await tester.pumpAndSettle();

    await goToMonthlyPurchase(tester);
    await tester.tap(find.text('Get Pro. ₱99 a month.'));
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsOneWidget);
  });

  testWidgets('close does not enter returnTo and has accessible label',
      (tester) async {
    final gateway = RecordingGateway();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
        GoRoute(
          path: '/paywall',
          builder: (_, state) => PaywallPage(
            packages: packages,
            returnTo: state.uri.queryParameters['returnTo'],
          ),
        ),
        GoRoute(path: '/progress', builder: (_, __) => const Text('Progress')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      paymentScope(
        MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
        gateway,
      ),
    );
    await tester.pumpAndSettle();
    router.push('/paywall?returnTo=%2Fprogress');
    await tester.pumpAndSettle();

    expect(find.byTooltip('Close'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Progress'), findsNothing);
  });
}

class RecordingGateway implements RevenueCatGateway {
  RecordingGateway({
    this.restoreResult = const PaymentOperationResult.authoritative(
      status: PaymentOperationStatus.noActiveSubscription,
      entitlement: Entitlement.free(),
    ),
    this.restoreCompleter,
  });

  final PaymentOperationResult restoreResult;
  final Completer<PaymentOperationResult>? restoreCompleter;
  int restoreCalls = 0;

  @override
  Entitlement? get cachedEntitlement => const Entitlement.free();

  @override
  Stream<Entitlement> get customerInfoUpdates =>
      Stream.value(const Entitlement.free());

  @override
  Future<PaywallOfferingResult> currentOffering() async =>
      const PaywallOfferingResult.noCurrentOffering();

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    restoreCalls++;
    if (restoreCompleter != null) return await restoreCompleter!.future;
    return restoreResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
