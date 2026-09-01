import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pantas_pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );

  Future<void> pumpOffering(
    WidgetTester tester,
    Future<PaywallOfferingResult> offeringFuture,
  ) async {
    final gateway = OfferingGateway(offeringFuture);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          revenueCatGatewayProvider.overrideWithValue(gateway),
          entitlementSnapshotStoreProvider.overrideWithValue(
            EntitlementSnapshotStore.inMemory(),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const PaywallPage(),
        ),
      ),
    );
  }

  testWidgets('loading offering shows loading state, not an error',
      (tester) async {
    final completer = Completer<PaywallOfferingResult>();
    await pumpOffering(tester, completer.future);
    await tester.pump();

    expect(find.text('Loading subscriptions...'), findsOneWidget);
    expect(find.textContaining('connection'), findsNothing);

    completer.complete(const PaywallOfferingResult.noCurrentOffering());
    await tester.pumpAndSettle();
  });

  testWidgets('available offering shows recognized plans', (tester) async {
    await pumpOffering(
      tester,
      Future.value(
        const PaywallOfferingResult(
          status: PaywallOfferingStatus.available,
          recognizedPackages: [monthly],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pro also adds'), findsOneWidget);
  });

  testWidgets('mixed offering still shows recognized plans', (tester) async {
    await pumpOffering(
      tester,
      Future.value(
        const PaywallOfferingResult(
          status: PaywallOfferingStatus.mixedProducts,
          recognizedPackages: [monthly],
          unrecognizedProductIds: ['future_plan'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pro also adds'), findsOneWidget);
    expect(find.textContaining('future_plan'), findsNothing);
  });

  testWidgets('no current offering is unavailable without claiming offline',
      (tester) async {
    await pumpOffering(
      tester,
      Future.value(const PaywallOfferingResult.noCurrentOffering()),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Subscriptions aren't available right now."),
      findsOneWidget,
    );
    expect(find.textContaining('connection'), findsNothing);
  });

  testWidgets('empty current offering is treated as unavailable',
      (tester) async {
    await pumpOffering(
      tester,
      Future.value(const PaywallOfferingResult.emptyCurrentOffering()),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Subscriptions aren't available right now."),
      findsOneWidget,
    );
  });

  testWidgets('all-unrecognized offering shows safe update-style state',
      (tester) async {
    await pumpOffering(
      tester,
      Future.value(
        const PaywallOfferingResult(
          status: PaywallOfferingStatus.allProductsUnrecognized,
          unrecognizedProductIds: ['future_plan'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Subscriptions are not available in this version of Pantas right now.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('future_plan'), findsNothing);
  });

  testWidgets('network offering failure is the only state labeled connection',
      (tester) async {
    await pumpOffering(
      tester,
      Future.value(
        const PaywallOfferingResult(
          status: PaywallOfferingStatus.networkFailure,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        "You need a connection to load subscriptions. Try again when you're "
        'back online.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('store offering failure is not labeled offline', (tester) async {
    await pumpOffering(
      tester,
      Future.value(
        const PaywallOfferingResult(
          status: PaywallOfferingStatus.storeFailure,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Google Play couldn't load subscriptions right now."),
      findsOneWidget,
    );
    expect(find.textContaining('connection'), findsNothing);
  });

  testWidgets('configuration failure uses generic student-safe copy',
      (tester) async {
    await pumpOffering(
      tester,
      Future.value(
        const PaywallOfferingResult(
          status: PaywallOfferingStatus.configurationFailure,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Subscriptions aren't available right now."),
      findsOneWidget,
    );
    expect(find.textContaining('configuration'), findsNothing);
    expect(find.textContaining('API'), findsNothing);
  });
}

class OfferingGateway implements RevenueCatGateway {
  OfferingGateway(this.offeringFuture);

  final Future<PaywallOfferingResult> offeringFuture;

  @override
  Entitlement? get cachedEntitlement => const Entitlement.free();

  @override
  Stream<Entitlement> get customerInfoUpdates =>
      Stream.value(const Entitlement.free());

  @override
  Future<PaywallOfferingResult> currentOffering() => offeringFuture;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
