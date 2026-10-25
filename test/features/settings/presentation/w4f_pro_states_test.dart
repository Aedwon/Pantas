import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
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
  bool web = false,
  bool dated = true,
  bool eligible = false,
  bool upgrade = false,
  bool playRenews = false,
  bool identityLoading = false,
  VoidCallback? checkoutSeen,
  int daysUntil = 5,
  List<WebGrantHistory> history = const [],
  Future<List<WebGrantHistory>> Function(Ref ref)? historyRead,
  Entitlement entitlement = const Entitlement.free(),
  PendingPurchase? pending,
}) async {
  final now = DateTime.now().toUtc().add(const Duration(hours: 8));
  final day =
      DateTime.utc(now.year, now.month, now.day).add(Duration(days: daysUntil));
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final webGateway = WebPaymentGateway(
    callable: (name, __) async {
      if (name == 'createPaymongoCheckout') checkoutSeen?.call();
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
    ProPage(
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
    overrides: [
      contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      revenueCatGatewayProvider.overrideWithValue(
        web ? webGateway : _CancelGateway(initial: entitlement),
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
  testWidgets('web upgrade waits while account identity is loading',
      (tester) async {
    var checkouts = 0;
    await _pump(
      tester,
      web: true,
      upgrade: true,
      identityLoading: true,
      checkoutSeen: () => checkouts++,
    );
    await tester.tap(find.text('Upgrade for ₱149 a Month'));
    await tester.pump();
    expect(checkouts, 0);
    expect(
      tester
          .widget<PantasButton>(
            find.byWidgetPredicate(
              (w) => w is PantasButton && w.label == 'Upgrade for ₱149 a Month',
            ),
          )
          .busy,
      isFalse,
    );
  });

  testWidgets('Pro uses curly apostrophes in student text', (tester) async {
    await _pump(tester, web: true, eligible: true);
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(
        RegExp("[A-Za-z]'[A-Za-z]").hasMatch(text.data ?? ''),
        isFalse,
        reason: text.data,
      );
    }
  });

  testWidgets('web trial offer says no payment needed before starting',
      (tester) async {
    await _pump(tester, web: true, eligible: true);
    expect(find.text('Try 7 Days Free'), findsOneWidget);
    expect(find.text('No payment needed.'), findsOneWidget);
    expect(find.text("You won't be charged"), findsNothing);
  });

  testWidgets(
      'active web trial uses the approved no-charge wording with its real end',
      (tester) async {
    await _pump(
      tester,
      web: true,
      entitlement: Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_cs_monthly',
        isTrial: true,
        willRenew: false,
        expiresAt: DateTime.utc(2030),
      ),
    );
    expect(
      find.text('Your free trial ends on Jan 1, 2030. You won’t be charged.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'native upgrade cancellation does not save the target before purchase',
      (tester) async {
    await _pump(tester, upgrade: true);
    await tester.tap(find.text('Upgrade for ₱149 a Month'));
    await tester.pumpAndSettle();
    expect(
      find.text('CSE Professional has its own price tier'),
      findsOneWidget,
    );
    expect(find.text('Upgrade for ₱149 a Month'), findsOneWidget);
  });
  testWidgets('web hides old history while the new owner history loads',
      (tester) async {
    final nextOwner = StateProvider<bool>((ref) => false);
    final pending = Completer<List<WebGrantHistory>>();
    await _pump(
      tester,
      web: true,
      historyRead: (ref) => ref.watch(nextOwner)
          ? pending.future
          : Future.value([
              WebGrantHistory(
                productId: 'pantas_pass_cse_pro',
                endsAt: DateTime.utc(2026),
                state: 'active',
                isTrial: false,
              ),
            ]),
    );
    expect(
      find.text('It ended after your exam on Jan 1, 2026.'),
      findsOneWidget,
    );
    final container =
        ProviderScope.containerOf(tester.element(find.byType(ProPage)));
    container.read(nextOwner.notifier).state = true;
    await tester.pump();
    expect(find.text('It ended after your exam on Jan 1, 2026.'), findsNothing);
    pending.complete([]);
    await tester.pumpAndSettle();
  });
  testWidgets(
      'target exam upgrade offers its plans and a Free switch without trial',
      (tester) async {
    await _pump(tester, web: true, upgrade: true, eligible: true);
    expect(
      find.text('CSE Professional has its own price tier'),
      findsOneWidget,
    );
    expect(find.text('Switch on Free'), findsOneWidget);
    expect(find.text('Upgrade for ₱149 a Month'), findsOneWidget);
    expect(find.text('Try 7 Days Free'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Monthly')).dy,
      tester.getTopLeft(find.text('Season Pass')).dy,
    );
  });
  testWidgets('web shows real expired pass history without granting access',
      (tester) async {
    await _pump(
      tester,
      web: true,
      history: [
        WebGrantHistory(
          productId: 'pantas_pass_cse_pro',
          endsAt: DateTime.utc(2026),
          state: 'active',
          isTrial: false,
        ),
      ],
    );
    expect(find.text('Your Season Pass ended'), findsOneWidget);
    expect(
      find.text('It ended after your exam on Jan 1, 2026.'),
      findsOneWidget,
    );
    expect(find.text('Buy Season Pass'), findsNothing);
  });
  testWidgets('web warns that an existing Play subscription keeps renewing',
      (tester) async {
    await _pump(
      tester,
      web: true,
      playRenews: true,
      entitlement: Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
        tier: PriceTier.student,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
    );
    expect(
      find.text(
        'Your Google Play plan keeps renewing. '
        'Cancel it in Google Play if you no longer need it.',
      ),
      findsOneWidget,
    );
  });
  for (final days in [0, 1, 7, 8]) {
    testWidgets('upgrade pass countdown at $days days', (tester) async {
      await _pump(tester, upgrade: true, daysUntil: days);
      expect(find.text('Ends in 0 days'), findsNothing);
      if (days > 0 && days <= 7) {
        expect(
          find.text('Ends in $days ${days == 1 ? 'day' : 'days'}'),
          findsOneWidget,
        );
      } else {
        expect(find.textContaining('Until '), findsOneWidget);
      }
    });
  }
  for (final days in [1, 7, 8]) {
    testWidgets('pass countdown threshold at $days days', (tester) async {
      await _pump(tester, daysUntil: days);
      if (days <= 7) {
        expect(
          find.text('Ends in $days ${days == 1 ? 'day' : 'days'}'),
          findsOneWidget,
        );
      }
      if (days == 8) expect(find.textContaining('Until '), findsOneWidget);
    });
  }

  testWidgets('Pro uses the five feature glyphs drawn on the approved board',
      (tester) async {
    await _pump(tester);
    for (final icon in [
      PantasIcons.unlimitedMocks,
      PantasIcons.answerNotes,
      PantasIcons.studyHabits,
      PantasIcons.proBackup,
      PantasIcons.topicResults,
    ]) {
      expect(find.byIcon(icon), findsOneWidget);
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
    expect(
      find.text(
        'A one-time purchase. It ends after the exam and never renews.',
      ),
      findsNWidgets(2),
    );
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
