import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

void main() {
  Future<void> pumpProPage(
    WidgetTester tester, {
    Entitlement entitlement = const Entitlement.free(),
    SettingsGateway? gateway,
    SubscriptionManagementLauncher? launcher,
  }) async {
    final resolvedGateway = gateway ?? SettingsGateway(initial: entitlement);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          revenueCatGatewayProvider.overrideWithValue(resolvedGateway),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: ProPage(
            subscriptionLauncher:
                launcher ?? launchGooglePlaySubscriptionManagement,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('free Settings has a working Try Pro route', (tester) async {
    final gateway = SettingsGateway(initial: const Entitlement.free());
    final router = GoRouter(
      initialLocation: '/settings/pro',
      routes: [
        GoRoute(path: '/settings/pro', builder: (_, __) => const ProPage()),
        GoRoute(path: '/paywall', builder: (_, __) => const Text('Paywall')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try Pro'));
    await tester.pumpAndSettle();

    expect(find.text('Paywall'), findsOneWidget);
  });

  testWidgets('Settings Restore uses the real payment controller path',
      (tester) async {
    final gateway = SettingsGateway(
      initial: const Entitlement.free(),
      restoreResult: const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.noActiveSubscription,
        entitlement: Entitlement.free(),
      ),
    );
    await pumpProPage(tester, gateway: gateway);

    await tester.tap(find.text('Restore purchases'));
    await tester.pumpAndSettle();

    expect(gateway.restoreCalls, 1);
    expect(
      find.text(
        "We couldn't find an active Pro subscription on this Google Play account.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('successful Settings Restore updates from entitlement provider',
      (tester) async {
    final gateway = SettingsGateway(
      initial: const Entitlement.free(),
      restoreResult: const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.success,
        entitlement: Entitlement(
          plan: EntitlementPlan.monthly,
          productId: 'pantas_pro_monthly',
        ),
      ),
    );
    await pumpProPage(tester, gateway: gateway);

    expect(find.text('Free'), findsOneWidget);
    await tester.tap(find.text('Restore purchases'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly'), findsWidgets);
    expect(find.text('Pro restored.'), findsOneWidget);
  });

  testWidgets('pending Settings Restore disables duplicate invocation',
      (tester) async {
    final completer = Completer<PaymentOperationResult>();
    final gateway = SettingsGateway(
      initial: const Entitlement.free(),
      restoreCompleter: completer,
    );
    await pumpProPage(tester, gateway: gateway);

    await tester.tap(find.text('Restore purchases'));
    await tester.pump();

    expect(find.text('Restoring...'), findsOneWidget);
    expect(gateway.restoreCalls, 1);
    await tester.tap(find.text('Restoring...'));
    await tester.pump();
    expect(gateway.restoreCalls, 1);

    completer.complete(
      const PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.noActiveSubscription,
        entitlement: Entitlement.free(),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Manage uses specific Play URL and strips base-plan suffix',
      (tester) async {
    Uri? launched;
    await pumpProPage(
      tester,
      entitlement: const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly:monthly-autorenewing',
      ),
      launcher: (uri) async {
        launched = uri;
        return true;
      },
    );

    await tester.tap(find.text('Manage in Google Play'));
    await tester.pumpAndSettle();

    expect(launched?.scheme, 'https');
    expect(launched?.host, 'play.google.com');
    expect(launched?.path, '/store/account/subscriptions');
    expect(launched?.queryParameters['sku'], 'pantas_pro_monthly');
    expect(launched?.queryParameters['package'], 'com.aedwon.pantas');
  });

  testWidgets('Manage launcher failure is graceful', (tester) async {
    await pumpProPage(
      tester,
      entitlement: const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
      launcher: (_) async => false,
    );

    await tester.tap(find.text('Manage in Google Play'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "We couldn't open Google Play. You can manage your subscription in the Google Play app.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('cancelled active subscription says Ends, not Renews',
      (tester) async {
    await pumpProPage(
      tester,
      entitlement: Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
        expiresAt: DateTime.utc(2026, 9, 30),
        willRenew: false,
      ),
    );

    expect(find.text('Ends'), findsOneWidget);
    expect(find.text('Renews'), findsNothing);
  });

  testWidgets('active trial is identified as trial with a charge date',
      (tester) async {
    await pumpProPage(
      tester,
      entitlement: Entitlement(
        plan: EntitlementPlan.yearly,
        productId: 'pantas_pro_yearly',
        expiresAt: DateTime.utc(2026, 9, 4),
        isTrial: true,
        willRenew: true,
      ),
    );

    expect(find.text('Yearly trial'), findsOneWidget);
    expect(find.text('Charges'), findsOneWidget);
    expect(find.textContaining('₱799'), findsOneWidget);
  });

  testWidgets('unknown active product is Pro, not Free', (tester) async {
    await pumpProPage(
      tester,
      entitlement: const Entitlement.activeUnknown(productId: 'future_plan'),
    );

    expect(find.text('Pro'), findsOneWidget);
    expect(find.text('Free'), findsNothing);
    expect(find.textContaining('future_plan'), findsNothing);
  });
}

class SettingsGateway implements RevenueCatGateway {
  SettingsGateway({
    required Entitlement initial,
    this.restoreResult = const PaymentOperationResult.authoritative(
      status: PaymentOperationStatus.noActiveSubscription,
      entitlement: Entitlement.free(),
    ),
    this.restoreCompleter,
  }) : _cached = initial;

  Entitlement _cached;
  final PaymentOperationResult restoreResult;
  final Completer<PaymentOperationResult>? restoreCompleter;
  final _updates = StreamController<Entitlement>.broadcast();
  int restoreCalls = 0;

  @override
  Entitlement? get cachedEntitlement => _cached;

  @override
  Stream<Entitlement> get customerInfoUpdates => _updates.stream;

  @override
  Future<PaywallOfferingResult> currentOffering() async =>
      const PaywallOfferingResult.noCurrentOffering();

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    restoreCalls++;
    final result = await (restoreCompleter?.future ?? Future.value(restoreResult));
    final confirmed = result.confirmedEntitlement;
    if (confirmed != null) {
      _cached = confirmed;
      _updates.add(confirmed);
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
