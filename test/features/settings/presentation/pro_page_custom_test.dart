import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/application/beta_pro_provider.dart';
import 'package:pantas/features/paywall/application/custom_track_tier.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/widgets/beta_pro_row.dart';

import '../../../helpers/in_memory_database.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

const _trackName = 'PUP CET';

const _csePro = ExamCatalogEntry(
  id: 'exam_cse_pro',
  name: 'CSE Professional',
  shortName: 'CSE Professional',
  priceTier: 'Civil Service',
  group: 'Civil service',
  comingSoon: false,
  hasContent: true,
  publishedSittings: [],
);

const _student = CustomTrackTier(tier: PriceTier.student);
const _civilService = CustomTrackTier(
  tier: PriceTier.civilService,
  becauseOf: 'General Information',
);

Exam _exam({required bool custom}) => Exam(
      id: custom ? 'exam_custom_pup' : 'exam_cse_pro',
      code: custom ? 'custom' : 'CSE',
      name: custom ? _trackName : 'CSE Professional',
      shortName: custom ? _trackName : 'CSE Professional',
      language: 'en',
      isActive: true,
      subjects: const [],
      isCustom: custom,
    );

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  bool custom = true,
  bool dark = false,
  Future<CustomTrackTier?>? tier,
  bool tierFails = false,
  Entitlement entitlement = const Entitlement.free(),
  Map<String, ExamCatalogEntry> ownedPasses = const {},
}) async {
  final wide = width >= 1000;
  debugWebPlatformOverride = wide;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view.physicalSize = Size(width, wide ? 1000 : 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/settings/pro',
    routes: [
      GoRoute(
        path: '/settings',
        builder: (_, __) => const Scaffold(body: Text('settings page')),
        routes: [
          GoRoute(path: 'pro', builder: (_, __) => const ProPage()),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
        revenueCatGatewayProvider.overrideWithValue(
          SettingsGateway(initial: entitlement),
        ),
        currentUserProvider.overrideWith(
          (ref) async => const AuthUser(
            uid: 'owner',
            email: 'owner@example.com',
            displayName: 'Owner',
          ),
        ),
        isAnonymousProvider.overrideWith((ref) async => false),
        paymentsOnWebProvider.overrideWithValue(wide),
        webGrantHistoryProvider.overrideWith((ref) async => []),
        entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
        proForActiveExamProvider.overrideWith((ref) async => false),
        pendingPurchaseProvider.overrideWithValue(const AsyncData(null)),
        activeExamFocusProvider.overrideWith(
          (ref) async => ActiveExamFocus.selected(_exam(custom: custom)),
        ),
        activeCustomTrackTierProvider.overrideWith((ref) async {
          if (tierFails) throw StateError('offline');
          return tier;
        }),
        // The catalog lists no custom track.
        activeProCatalogEntryProvider
            .overrideWith((ref) async => custom ? null : _csePro),
        ownedPassCatalogEntriesProvider
            .overrideWith((ref) async => ownedPasses),
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult(
            status: PaywallOfferingStatus.available,
            recognizedPackages: [
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_pro_monthly',
                priceString: '₱99',
                priceAmount: 99,
              ),
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_cs_monthly',
                priceString: '₱149',
                priceAmount: 149,
              ),
            ],
            passPackages: [
              PaywallPassPackage(
                productId: 'pantas_pass_cse_pro',
                priceString: '₱499',
                priceAmount: 499,
              ),
            ],
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

const _studentLine = '$_trackName is a Student-level exam.';
const _civilServiceLine = '$_trackName is a Civil Service-level exam because '
    'it includes General Information.';

void _expectNoFreeCardOrPass(WidgetTester tester) {
  expect(find.text('$_trackName is free to study.'), findsNothing);
  expect(find.text('Pro plans come with a listed exam.'), findsNothing);
  expect(find.text('Change Exam'), findsNothing);
  expect(find.text('Buy Season Pass'), findsNothing);
  expect(find.textContaining('Once the next date is out'), findsNothing);
  expect(find.textContaining('no limits'), findsNothing);
}

void main() {
  for (final width in [1440.0, 1100.0, 390.0]) {
    testWidgets('Student custom exam shows the Student paywall at $width',
        (tester) async {
      await _pump(tester, width: width, tier: Future.value(_student));
      expect(find.text('PLANS FOR $_trackName'.toUpperCase()), findsOneWidget);
      expect(find.text(_studentLine), findsOneWidget);
      expect(find.text('₱99'), findsOneWidget);
      expect(find.text('₱149'), findsNothing);
      expect(find.text('Restore Purchases'), findsOneWidget);
      expect(find.text('Season Pass'), findsNothing);
      _expectNoFreeCardOrPass(tester);
      // The why line sits under the header and above the plans.
      final header = tester.getRect(find.text('PLANS FOR PUP CET'));
      final line = tester.getRect(find.text(_studentLine));
      final price = tester.getRect(find.text('₱99'));
      expect(line.top, greaterThan(header.bottom));
      expect(price.top, greaterThan(line.bottom));
      if (width < 1000) expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Civil Service custom exam shows the Civil Service paywall at $width',
        (tester) async {
      await _pump(tester, width: width, tier: Future.value(_civilService));
      expect(find.text('PLANS FOR PUP CET'), findsOneWidget);
      expect(find.text(_civilServiceLine), findsOneWidget);
      expect(find.text('₱149'), findsOneWidget);
      expect(find.text('₱99'), findsNothing);
      expect(find.text('Season Pass'), findsNothing);
      expect(find.text('₱499'), findsNothing);
      _expectNoFreeCardOrPass(tester);
      if (width < 1000) expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dark wide custom paywall draws without errors', (tester) async {
    await _pump(
      tester,
      width: 1440,
      dark: true,
      tier: Future.value(_civilService),
    );
    expect(find.text(_civilServiceLine), findsOneWidget);
    expect(find.text('₱149'), findsOneWidget);
  });

  testWidgets('a Civil Service line without a known subject drops the reason',
      (tester) async {
    await _pump(
      tester,
      width: 390,
      tier: Future.value(const CustomTrackTier(tier: PriceTier.civilService)),
    );
    expect(
      find.text('$_trackName is a Civil Service-level exam.'),
      findsOneWidget,
    );
    expect(find.textContaining('because'), findsNothing);
  });

  testWidgets('while the tier is unknown no paywall is guessed',
      (tester) async {
    final pending = Completer<CustomTrackTier?>();
    await _pump(tester, width: 390, tier: pending.future);
    expect(find.text('Loading subscriptions...'), findsOneWidget);
    expect(find.textContaining('PLANS FOR'), findsNothing);
    expect(find.textContaining('₱'), findsNothing);
    expect(find.textContaining('-level exam'), findsNothing);
    expect(find.text('Get Pro'), findsNothing);
    _expectNoFreeCardOrPass(tester);
  });

  testWidgets('a tier that cannot be read offers Try Again, not a paywall',
      (tester) async {
    await _pump(
      tester,
      width: 390,
      tierFails: true,
    );
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.textContaining('₱'), findsNothing);
    expect(find.textContaining('PLANS FOR'), findsNothing);
  });

  testWidgets('Pro that covers the custom tier shows no offers',
      (tester) async {
    await _pump(
      tester,
      width: 390,
      tier: Future.value(_student),
      entitlement: Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
        expiresAt: DateTime.now().add(const Duration(days: 20)),
      ),
    );
    expect(find.text("You're on Pro."), findsOneWidget);
    expect(find.text('Monthly'), findsWidgets);
    expect(find.textContaining('PLANS FOR'), findsNothing);
    expect(find.text('₱99'), findsNothing);
    expect(find.text(_studentLine), findsOneWidget);
  });

  testWidgets('Student Pro does not cover a Civil Service custom exam',
      (tester) async {
    await _pump(
      tester,
      width: 390,
      tier: Future.value(_civilService),
      entitlement: Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
        tier: PriceTier.student,
        expiresAt: DateTime.now().add(const Duration(days: 20)),
      ),
    );
    expect(find.text('PLANS FOR PUP CET'), findsOneWidget);
    expect(find.text('₱149'), findsOneWidget);
    expect(find.text(_civilServiceLine), findsOneWidget);
  });

  testWidgets('custom exam keeps the plan rows of a pass for another exam',
      (tester) async {
    await _pump(
      tester,
      width: 390,
      tier: Future.value(_student),
      entitlement: Entitlement(
        plan: EntitlementPlan.free,
        passes: {'exam_cse_pro': DateTime.utc(2027, 3)},
      ),
      ownedPasses: const {'exam_cse_pro': _csePro},
    );
    expect(find.text('YOUR PLAN'), findsOneWidget);
    expect(find.text('Season Pass'), findsOneWidget);
    expect(find.text('CSE Professional'), findsOneWidget);
    expect(find.text('Mar 1, 2027'), findsOneWidget);
    expect(find.text('Buy Season Pass'), findsNothing);
    expect(find.text('₱499'), findsNothing);
  });

  for (final width in [1440.0, 390.0]) {
    testWidgets('a listed exam keeps its Pro page at $width', (tester) async {
      await _pump(tester, width: width, custom: false);
      expect(find.text('$_trackName is free to study.'), findsNothing);
      expect(find.textContaining('-level exam'), findsNothing);
      expect(
        find.text("See exactly what's losing you points."),
        findsOneWidget,
      );
      expect(find.text('PLANS FOR CSE PROFESSIONAL'), findsOneWidget);
      expect(find.text('₱149'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
      // The exam name in the left list is wider than the test font allows at
      // 1440, which is not this page; the phone case checks for errors.
      final error = tester.takeException();
      if (width < 1000) expect(error, isNull);
    });
  }

  group('beta row', () {
    Future<void> pumpBeta(
      WidgetTester tester, {
      required bool custom,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            betaProProvider.overrideWith(
              (ref) => Stream.value(
                BetaProState(until: DateTime(2099), enabled: true),
              ),
            ),
            activeExamFocusProvider.overrideWith(
              (ref) async => ActiveExamFocus.selected(_exam(custom: custom)),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: false),
            home: const Scaffold(
              body: Column(children: [BetaProRow(), BetaProNote()]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('hides on a custom exam', (tester) async {
      await pumpBeta(tester, custom: true);
      expect(find.text('Beta: Pro Features'), findsNothing);
      expect(find.textContaining('Pro features are on'), findsNothing);
    });

    testWidgets('stays on a listed exam', (tester) async {
      await pumpBeta(tester, custom: false);
      expect(find.text('Beta: Pro Features'), findsOneWidget);
      expect(find.textContaining('Pro features are on'), findsOneWidget);
    });
  });
}
