import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final outcome in ['success', 'cancelled']) {
    testWidgets('PayMongo $outcome reaches Pro through the real router',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      var refreshes = 0;
      final gateway = WebPaymentGateway(
        callable: (_, __) async => <String, Object?>{'plans': <Object?>[]},
        readGrants: (_) async => [],
        refreshClaims: (_) async {
          refreshes++;
        },
        openUrl: (_) async => true,
      );
      await gateway.logIn('owner');
      final routes = Provider(
        (ref) => GoRouter(
          initialLocation: '/pro?checkout=$outcome&token=a%2Bb&token=c',
          routes: settingsRoutes(ref),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          currentUserProvider.overrideWith(
            (ref) async => const AuthUser(
              uid: 'owner',
              email: 'o@example.com',
              displayName: 'Owner',
            ),
          ),
          isAnonymousProvider.overrideWith((ref) async => false),
          paymentsOnWebProvider.overrideWithValue(true),
          revenueCatGatewayProvider.overrideWithValue(gateway),
          proForActiveExamProvider.overrideWith((ref) async => false),
          activeProCatalogEntryProvider.overrideWith((ref) async => null),
          paywallOfferingProvider.overrideWith(
            (ref) async => const PaywallOfferingResult.noCurrentOffering(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: appLightTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProPage), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/settings/pro?checkout=$outcome&token=a%2Bb&token=c',
      );
      expect(refreshes, outcome == 'success' ? 1 : 0);
      expect(
        find.textContaining('Pro couldn'),
        outcome == 'success' ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('checkout return waits for the original signed-in identity',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final user = Completer<AuthUser?>();
    final grants = Completer<List<Map<String, dynamic>>>();
    var reads = 0;
    final gateway = WebPaymentGateway(
      callable: (_, __) async => <String, Object?>{'plans': <Object?>[]},
      readGrants: (_) {
        reads++;
        return reads == 1
            ? Future.value(<Map<String, dynamic>>[])
            : grants.future;
      },
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
    );
    await gateway.logIn('owner');
    await tester.pumpAppWithProviders(
      ProPage(checkoutReturnUri: Uri.parse('/settings/pro?checkout=success')),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentUserProvider.overrideWith((ref) => user.future),
        isAnonymousProvider.overrideWith((ref) async => false),
        paymentsOnWebProvider.overrideWithValue(true),
        revenueCatGatewayProvider.overrideWithValue(gateway),
        proForActiveExamProvider.overrideWith((ref) async => false),
        activeProCatalogEntryProvider.overrideWith((ref) async => null),
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult.noCurrentOffering(),
        ),
      ],
    );
    user.complete(
      const AuthUser(
        uid: 'owner',
        email: 'owner@example.com',
        displayName: 'Owner',
      ),
    );
    await tester.pump();
    grants.complete(<Map<String, dynamic>>[]);
    await tester.pumpAndSettle();
    // Login, checkout return, and grant history each read the ledger.
    expect(reads, 3);
    expect(
      find.text('We found a purchase, but Pro couldn’t be confirmed yet. '
          'Try again in a moment.'),
      findsOneWidget,
    );
    expect(find.text('No purchases found for this account.'), findsNothing);
    expect(find.text('Manage in Google Play'), findsNothing);
  });
}
