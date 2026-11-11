import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

const _label = 'I am the parent or guardian and accept the Terms.';
const _oldLine = 'Ask your parent or guardian to complete this payment';
const _buy = 'Buy 1 Month for ₱149';

void main() {
  late List<(String, Map<String, Object?>)> calls;
  Exception? refusal;

  setUp(() {
    calls = [];
    refusal = null;
  });

  Future<void> pumpPro(
    WidgetTester tester, {
    required String? group,
    required bool wide,
    bool trialEligible = false,
    bool router = false,
  }) async {
    if (wide) {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
    }
    tester.view
      ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final gateway = WebPaymentGateway(
      callable: (name, data) async {
        calls.add((name, data));
        final failure = refusal;
        if (failure != null) throw failure;
        return <String, Object?>{
          'checkoutUrl': 'https://pay.example.test/ck_1',
          'sessionId': 'cs_1',
          'reference': 'ref_1',
        };
      },
      readGrants: (_) async => [],
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
    );
    await gateway.logIn('owner');
    final overrides = [
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
      ageGroupProvider.overrideWith((ref) async => group),
      revenueCatGatewayProvider.overrideWithValue(gateway),
      proForActiveExamProvider.overrideWith((ref) async => false),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(
          buildExam(id: 'exam_cse_pro', shortName: 'CSE Professional'),
        ),
      ),
      activeProCatalogEntryProvider.overrideWith(
        (ref) async => const ExamCatalogEntry(
          id: 'exam_cse_pro',
          name: 'CSE Professional',
          shortName: 'CSE Professional',
          priceTier: 'Civil Service',
          group: 'Civil service',
          comingSoon: false,
          publishedSittings: [],
          hasContent: true,
        ),
      ),
      paywallOfferingProvider.overrideWith(
        (ref) async => PaywallOfferingResult(
          status: PaywallOfferingStatus.available,
          recognizedPackages: [
            PaywallPackage(
              sku: PaywallSku.monthly,
              productId: 'pantas_cs_monthly',
              priceString: '₱149',
              priceAmount: 149,
              trialEligible: trialEligible,
            ),
            const PaywallPackage(
              sku: PaywallSku.yearly,
              productId: 'pantas_cs_yearly',
              priceString: '₱1,199',
              priceAmount: 1199,
            ),
          ],
        ),
      ),
    ];
    if (router) {
      final goRouter = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => const ProPage()),
          GoRoute(
            path: '/legal/terms',
            builder: (_, __) => const Scaffold(body: Text('The Terms page')),
          ),
        ],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp.router(
            theme: appLightTheme(),
            routerConfig: goRouter,
          ),
        ),
      );
    } else {
      await tester.pumpAppWithProviders(const ProPage(), overrides: overrides);
    }
    await tester.pumpAndSettle();
    // Test fonts overflow one wide-web row in some cases; not under test.
    tester.takeException();
  }

  VoidCallback? buyPressed(WidgetTester tester, {required bool wide}) => wide
      ? tester.widget<WebButton>(find.widgetWithText(WebButton, _buy)).onPressed
      : tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, _buy))
          .onPressed;

  /// A started checkout leaves the page spinning until the tab leaves, so
  /// the page never settles; a few frames are enough for the call and result.
  Future<void> afterBuy(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Finder box() => find.byWidgetPredicate(
        (w) => w is CheckboxRow && w.title == _label,
      );

  Future<void> tick(WidgetTester tester) async {
    await tester.ensureVisible(box());
    await tester.tap(box());
    await tester.pump();
  }

  for (final wide in [false, true]) {
    final where = wide ? 'wide web' : 'phone';

    testWidgets('a minor sees the box, not the old line, on $where',
        (tester) async {
      await pumpPro(tester, group: 'minor', wide: wide);
      expect(box(), findsOneWidget);
      expect(find.text(_oldLine), findsNothing);
      expect(
        tester.widget<CheckboxRow>(box()).selected,
        isFalse,
        reason: 'The box starts unticked.',
      );
    });

    testWidgets('the buy button is disabled until the box is ticked, $where',
        (tester) async {
      await pumpPro(tester, group: 'minor', wide: wide);
      expect(buyPressed(tester, wide: wide), isNull);
      await tick(tester);
      expect(buyPressed(tester, wide: wide), isNotNull);
      await tick(tester);
      expect(buyPressed(tester, wide: wide), isNull);
    });

    testWidgets(
        'buying sends the guardian attestation with the Terms version, '
        '$where', (tester) async {
      await pumpPro(tester, group: 'minor', wide: wide);
      await tick(tester);
      final buy = wide
          ? find.widgetWithText(WebButton, _buy)
          : find.widgetWithText(PantasButton, _buy);
      await tester.tap(buy);
      await afterBuy(tester);
      expect(calls.single.$1, 'createPaymongoCheckout');
      expect(calls.single.$2, {
        'product': 'pantas_cs_monthly',
        'guardianAttestation': {
          'termsVersion': guardianDocumentVersions['terms'],
        },
      });
    });

    testWidgets('an adult sees no box and buys without an attestation, $where',
        (tester) async {
      await pumpPro(tester, group: 'adult', wide: wide);
      expect(box(), findsNothing);
      expect(find.text(_oldLine), findsNothing);
      expect(buyPressed(tester, wide: wide), isNotNull);
      final buy = wide
          ? find.widgetWithText(WebButton, _buy)
          : find.widgetWithText(PantasButton, _buy);
      await tester.tap(buy);
      await afterBuy(tester);
      expect(calls.single.$2, {'product': 'pantas_cs_monthly'});
    });

    testWidgets('an unknown age group shows no box, $where', (tester) async {
      await pumpPro(tester, group: null, wide: wide);
      expect(box(), findsNothing);
      expect(buyPressed(tester, wide: wide), isNotNull);
    });

    testWidgets(
        'the free trial takes no payment, so a minor sees no box, '
        '$where', (tester) async {
      await pumpPro(tester, group: 'minor', wide: wide, trialEligible: true);
      expect(find.text('Try 7 Days Free'), findsWidgets);
      expect(box(), findsNothing);
      expect(find.text(_oldLine), findsNothing);
    });

    testWidgets(
        'the server refusing the attestation shows the checkout '
        'failure line, $where', (tester) async {
      refusal = FirebaseFunctionsException(
        message: 'A parent or guardian must confirm this purchase.',
        code: 'failed-precondition',
        details: const {'reason': 'guardian-attestation-required'},
      );
      await pumpPro(tester, group: 'minor', wide: wide);
      await tick(tester);
      final buy = wide
          ? find.widgetWithText(WebButton, _buy)
          : find.widgetWithText(PantasButton, _buy);
      await tester.tap(buy);
      await afterBuy(tester);
      expect(
        find.text("We couldn't confirm your subscription. Try again."),
        findsOneWidget,
      );
    });
  }

  testWidgets('Terms in the label opens the Terms', (tester) async {
    await pumpPro(tester, group: 'minor', wide: false, router: true);
    await tester.ensureVisible(find.text('Terms'));
    await tester.tap(find.text('Terms'));
    await tester.pumpAndSettle();
    expect(find.text('The Terms page'), findsOneWidget);
  });
}
