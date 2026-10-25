import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
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

Future<void> _pump(
  WidgetTester tester, {
  bool web = false,
  bool dated = true,
  bool eligible = false,
  Entitlement entitlement = const Entitlement.free(),
  PendingPurchase? pending,
}) async {
  final now = DateTime.now().toUtc().add(const Duration(hours: 8));
  final day =
      DateTime.utc(now.year, now.month, now.day).add(const Duration(days: 5));
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpAppWithProviders(
    const ProPage(),
    overrides: [
      contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      revenueCatGatewayProvider
          .overrideWithValue(SettingsGateway(initial: entitlement)),
      currentUserProvider.overrideWith(
        (ref) async => const AuthUser(
          uid: 'owner',
          email: 'owner@example.com',
          displayName: 'Owner',
        ),
      ),
      isAnonymousProvider.overrideWith((ref) async => false),
      paymentsOnWebProvider.overrideWithValue(web),
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
      paywallOfferingProvider.overrideWith(
        (ref) async => PaywallOfferingResult(
          status: PaywallOfferingStatus.available,
          recognizedPackages: [
            eligible
                ? const PaywallPackage(
                    sku: PaywallSku.monthly,
                    productId: 'pantas_cs_monthly',
                    priceString: '₱149',
                    priceAmount: 149,
                    trialEligible: true,
                  )
                : _monthly,
          ],
          passPackages: [_pass],
        ),
      ),
    ],
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Pro uses the five feature glyphs drawn on the approved board',
      (tester) async {
    await _pump(tester);
    for (final code in [0xe634, 0xe34c, 0xe156, 0xe1ae, 0xeadc]) {
      expect(
        find.byIcon(IconData(code, fontFamily: 'Phosphor')),
        findsOneWidget,
      );
    }
  });
  testWidgets('eligible Monthly badge sits above the card', (tester) async {
    await _pump(tester, eligible: true);
    final card = find
        .ancestor(of: find.text('Monthly'), matching: find.byType(InkWell))
        .first;
    expect(
      tester.getTopLeft(find.text('7 DAYS FREE')).dy,
      lessThan(tester.getTopLeft(card).dy),
    );
  });
  testWidgets('each owned pass shows its own exam and end date',
      (tester) async {
    await _pump(
      tester,
      entitlement: Entitlement(
        plan: EntitlementPlan.free,
        passes: {
          'exam_cse_pro': DateTime.utc(2027, 3),
          'exam_cse_sub': DateTime.utc(2027, 8, 8),
        },
      ),
    );
    expect(find.text('CSE Professional'), findsOneWidget);
    expect(find.text('CSE Subprofessional'), findsOneWidget);
    expect(find.text('Mar 1, 2027'), findsOneWidget);
    expect(find.text('Aug 8, 2027'), findsOneWidget);
    expect(find.text('Season Pass'), findsNWidgets(2));
    expect(find.text('Renews'), findsNothing);
  });
  testWidgets(
      'plan cards use the approved type sizes and keep the action visible',
      (tester) async {
    await _pump(tester);
    expect(tester.widget<Text>(find.text('₱149')).style?.fontSize, 22);
    expect(tester.widget<Text>(find.text('Monthly')).style?.fontSize, 14);
    expect(
      find.text('Subscribe for ₱149 a Month').hitTestable(),
      findsOneWidget,
    );
    expect(
      tester.getRect(find.text('Restore purchases')).bottom,
      lessThanOrEqualTo(844),
    );
  });
  testWidgets('selected pass names its real price and published end date',
      (tester) async {
    await _pump(tester);
    await tester.ensureVisible(find.text('Season Pass'));
    await tester.tap(find.text('Season Pass'));
    await tester.pumpAndSettle();
    expect(find.text('Buy Season Pass'), findsOneWidget);
    expect(
      find.textContaining('₱499 once. Ends after the exam on'),
      findsOneWidget,
    );
  });
  testWidgets('pass without a published sitting cannot be selected or bought',
      (tester) async {
    await _pump(tester, dated: false);
    expect(find.text('Once the next date is out'), findsOneWidget);
    await tester.ensureVisible(find.text('Season Pass'));
    await tester.tap(find.text('Season Pass'));
    await tester.pumpAndSettle();
    expect(find.text('Buy Season Pass'), findsNothing);
    expect(find.text('Subscribe for ₱149 a Month'), findsOneWidget);
  });
  testWidgets(
      'native pending purchase replaces plans and prevents another purchase',
      (tester) async {
    await _pump(
      tester,
      pending: PendingPurchase(
        uid: 'owner',
        productId: 'pantas_cs_monthly',
        startedAt: DateTime.now(),
      ),
    );
    expect(find.text('Waiting for your payment'), findsOneWidget);
    expect(find.text('Open Google Play'), findsOneWidget);
    expect(find.text('Season Pass'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is PantasButton && w.label.startsWith('Subscribe'),
      ),
      findsNothing,
    );
  });
  testWidgets('web never displays the native pending card or Play management',
      (tester) async {
    await _pump(
      tester,
      web: true,
      pending: PendingPurchase(
        uid: 'owner',
        productId: 'pantas_cs_monthly',
        startedAt: DateTime.now(),
      ),
    );
    expect(find.text('Waiting for your payment'), findsNothing);
    expect(find.text('Open Google Play'), findsNothing);
    expect(find.text('Manage in Google Play'), findsNothing);
    expect(find.text('Subscribe for ₱149 a Month'), findsOneWidget);
  });
  testWidgets('a grant has an end date and no renewal or management promise',
      (tester) async {
    await _pump(
      tester,
      entitlement: Entitlement(
        plan: EntitlementPlan.free,
        state: EntitlementState.grant,
        endsAt: DateTime.utc(2027),
        promotions: [
          CoveragePeriod(
            id: 'promo_civil_service',
            endsAt: DateTime.utc(2027),
          ),
        ],
      ),
    );
    expect(find.text('Ends'), findsOneWidget);
    expect(find.text('Renews'), findsNothing);
    expect(find.text('Manage in Google Play'), findsNothing);
  });
}
