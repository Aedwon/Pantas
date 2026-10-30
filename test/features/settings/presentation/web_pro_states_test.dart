import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

const _monthly = PaywallPackage(
  sku: PaywallSku.monthly,
  productId: 'pantas_cs_monthly',
  priceString: '₱149',
  priceAmount: 149,
);
const _pass = PaywallPassPackage(
  productId: 'pantas_pass_cse_pro',
  priceString: '₱499',
  priceAmount: 499,
);

class _CancelGateway extends SettingsGateway {
  _CancelGateway({required super.initial});
  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async =>
      const PaymentOperationResult.failure(
        status: PaymentOperationStatus.userCancelled,
      );
}

Future<void> _pump(
  WidgetTester tester, {
  SettingsGateway? operationGateway,
  bool dark = false,
  bool web = true,
  bool dated = true,
  bool eligible = false,
  bool upgrade = false,
  bool playRenews = false,
  bool identityLoading = false,
  VoidCallback? checkoutSeen,
  VoidCallback? trialSeen,
  AppPreferencesRepository? preferences,
  int daysUntil = 5,
  List<WebGrantHistory> history = const [],
  Future<List<WebGrantHistory>> Function(Ref ref)? historyRead,
  Entitlement entitlement = const Entitlement.free(),
  PendingPurchase? pending,
}) async {
  final now = DateTime.now().toUtc().add(const Duration(hours: 8));
  final day =
      DateTime.utc(now.year, now.month, now.day).add(Duration(days: daysUntil));
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final webGateway = WebPaymentGateway(
    callable: (name, __) async {
      if (name == 'createPaymongoCheckout') checkoutSeen?.call();
      if (name == 'startWebTrial') trialSeen?.call();
      return {'plans': <Object?>[], 'googlePlayPlanRenews': playRenews};
    },
    readGrants: (_) async => [],
    refreshClaims: (_) async {},
    openUrl: (_) async => true,
  );
  if (web) {
    await webGateway.logIn('owner');
    await webGateway.currentOffering();
  }
  await tester.pumpAppWithProviders(
    Theme(
      data: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
      child: ProPage(
        targetExam: upgrade
            ? ExamCatalogEntry(
                id: 'exam_cse_pro',
                name: 'CSE Professional',
                shortName: 'CSE Professional',
                priceTier: 'Civil Service',
                group: 'Civil service',
                comingSoon: false,
                hasContent: true,
                publishedSittings: dated
                    ? [
                        PublishedExamSitting(
                          firstDay: day,
                          lastDay: day,
                          sourceUrl: 'https://csc.gov.ph',
                        ),
                      ]
                    : [],
              )
            : null,
        previousExamName: 'UPCAT',
        onSwitchOnFree: () async {},
      ),
    ),
    overrides: [
      if (preferences != null)
        appPreferencesRepositoryProvider.overrideWithValue(preferences),
      contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      revenueCatGatewayProvider.overrideWithValue(
        operationGateway ??
            (web ? webGateway : _CancelGateway(initial: entitlement)),
      ),
      currentUserProvider.overrideWith(
        (ref) async => identityLoading
            ? Completer<AuthUser?>().future
            : const AuthUser(
                uid: 'owner',
                email: 'owner@example.com',
                displayName: 'Owner',
              ),
      ),
      isAnonymousProvider.overrideWith((ref) async => false),
      paymentsOnWebProvider.overrideWithValue(web),
      webGrantHistoryProvider.overrideWith(
        (ref) => historyRead?.call(ref) ?? Future.value(history),
      ),
      entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
      proForActiveExamProvider
          .overrideWith((ref) async => entitlement.proIsActive),
      pendingPurchaseProvider.overrideWithValue(AsyncData(pending)),
      activeProCatalogEntryProvider.overrideWith(
        (ref) async => ExamCatalogEntry(
          id: 'exam_cse_pro',
          name: 'CSE Professional',
          shortName: 'CSE Professional',
          priceTier: 'Civil Service',
          group: 'Civil service',
          comingSoon: false,
          hasContent: true,
          publishedSittings: dated
              ? [
                  PublishedExamSitting(
                    firstDay: day,
                    lastDay: day,
                    sourceUrl: 'https://csc.gov.ph',
                  ),
                ]
              : [],
        ),
      ),
      (upgrade ? unfilteredPaywallOfferingProvider : paywallOfferingProvider)
          .overrideWith(
        (ref) async => PaywallOfferingResult(
          status: PaywallOfferingStatus.available,
          recognizedPackages: [
            if (eligible)
              const PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_cs_monthly',
                priceString: '₱149',
                priceAmount: 149,
                trialEligible: true,
              )
            else
              _monthly,
          ],
          passPackages: [_pass],
        ),
      ),
    ],
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  for (final dark in [false, true]) {
    for (final plan in [EntitlementPlan.monthly, EntitlementPlan.yearly]) {
      testWidgets('owned $plan dark=$dark keeps web end date', (tester) async {
        await _pump(
          tester,
          dark: dark,
          entitlement: Entitlement(
            plan: plan,
            productId: plan == EntitlementPlan.monthly
                ? 'pantas_cs_monthly'
                : 'pantas_cs_yearly',
            expiresAt: DateTime.now().add(const Duration(days: 20)),
          ),
        );
        expect(find.byKey(const ValueKey('pro-hero')), findsOneWidget);
        expect(find.text("You're on Pro."), findsOneWidget);
        expect(find.text('Ends'), findsOneWidget);
        expect(find.text('Manage Subscription'), findsNothing);
        expect(find.text('Manage in Google Play'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('pass with no published date dark=$dark', (tester) async {
      await _pump(tester, dark: dark, dated: false);
      expect(find.text('Once the next date is out'), findsOneWidget);
      expect(find.text('Buy Season Pass'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Season Pass choice keeps its end date dark=$dark',
        (tester) async {
      await _pump(tester, dark: dark);
      expect(
        tester.getTopLeft(find.text('Season Pass')).dy,
        tester.getTopLeft(find.text('Monthly')).dy,
      );
      expect(tester.widget<Text>(find.text('₱499')).style?.fontSize, 26);
      await tester.tap(find.text('Season Pass'));
      await tester.pumpAndSettle();
      expect(find.text('Buy Season Pass'), findsOneWidget);
      expect(
        find.textContaining('₱499 once. Ends after the exam on'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('restore uses a busy verb dark=$dark', (tester) async {
      final result = Completer<PaymentOperationResult>();
      await _pump(
        tester,
        dark: dark,
        operationGateway: SettingsGateway(
          initial: const Entitlement.free(),
          restoreCompleter: result,
        ),
      );
      await tester.tap(find.text('Restore Purchases'));
      await tester.pump();
      expect(find.text('Restoring purchases'), findsOneWidget);
      result.complete(
        const PaymentOperationResult.authoritative(
          status: PaymentOperationStatus.noActiveSubscription,
          entitlement: Entitlement.free(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No purchases found for this account.'), findsOneWidget);
    });
    testWidgets('trial uses prepaid terms dark=$dark', (tester) async {
      await _pump(tester, dark: dark, eligible: true);
      expect(find.text('Try 7 Days Free'), findsOneWidget);
      expect(find.text('No payment needed.'), findsOneWidget);
      expect(find.textContaining('Cancel any time.'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
