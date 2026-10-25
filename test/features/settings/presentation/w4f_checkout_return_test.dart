import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('checkout return waits for the original signed-in identity',
      (tester) async {
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
      find.text("We found a purchase, but Pro couldn't be confirmed yet. "
          'Try again in a moment.'),
      findsOneWidget,
    );
    expect(find.text('No purchases found for this account.'), findsNothing);
    expect(find.text('Manage in Google Play'), findsNothing);
  });
}
