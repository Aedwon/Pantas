import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

/// The Pro page (/pro, /settings/pro) at the three widths that matter, light
/// and dark, text 1.0 and 2.0. A layout overflow fails the cell.
final _cells = <DsCell>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
];

const _monthly = PaywallPackage(
  sku: PaywallSku.monthly,
  productId: 'pantas_cs_monthly',
  priceString: '₱149',
  priceAmount: 149,
  trialEligible: true,
);
const _yearly = PaywallPackage(
  sku: PaywallSku.yearly,
  productId: 'pantas_cs_yearly',
  priceString: '₱1,199',
  priceAmount: 1199,
);
const _weekly = PaywallPackage(
  sku: PaywallSku.weekly,
  productId: 'pantas_cs_weekly',
  priceString: '₱49',
  priceAmount: 49,
);
const _pass = PaywallPassPackage(
  productId: 'pantas_pass_cse_pro',
  priceString: '₱499',
  priceAmount: 499,
);

Future<void> _pump(
  WidgetTester tester,
  DsCell cell, {
  Entitlement entitlement = const Entitlement.free(),
  Widget? page,
}) async {
  tester.view
    ..physicalSize = Size(cell.width, 1400)
    ..devicePixelRatio = 1;
  final wide = cell.width >= 1024;
  debugWebPlatformOverride = wide;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  final now = DateTime.now().toUtc().add(const Duration(hours: 8));
  final day =
      DateTime.utc(now.year, now.month, now.day).add(const Duration(days: 30));
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
        entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
        proForActiveExamProvider
            .overrideWith((ref) async => entitlement.proIsActive),
        pendingPurchaseProvider.overrideWithValue(const AsyncData(null)),
        webGrantHistoryProvider.overrideWith((ref) async => const []),
        activeProCatalogEntryProvider.overrideWith(
          (ref) async => ExamCatalogEntry(
            id: 'exam_cse_pro',
            name: 'CSE Professional',
            shortName: 'CSE Professional',
            priceTier: 'Civil Service',
            group: 'Civil service',
            comingSoon: false,
            hasContent: true,
            publishedSittings: [
              PublishedExamSitting(
                firstDay: day,
                lastDay: day,
                sourceUrl: 'https://csc.gov.ph',
              ),
            ],
          ),
        ),
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult(
            status: PaywallOfferingStatus.available,
            recognizedPackages: [_weekly, _monthly, _yearly],
            passPackages: [_pass],
          ),
        ),
      ],
      child: MaterialApp(
        theme:
            cell.dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(cell.width, 1400),
            textScaler: TextScaler.linear(cell.scale),
          ),
          child: page ?? const ProPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadDsFonts);

  for (final cell in _cells) {
    testWidgets('Free with plans and the Season Pass ($cell)', (tester) async {
      await _pump(tester, cell);
      expect(tester.takeException(), isNull);
      expect(find.text('7 DAYS FREE'), findsOneWidget);
      expect(find.text('SAVE 32%'), findsOneWidget);
      expect(find.text('Season Pass'), findsOneWidget);
    });

    testWidgets('Pro owner sees the plan rows ($cell)', (tester) async {
      await _pump(
        tester,
        cell,
        entitlement: Entitlement(
          plan: EntitlementPlan.monthly,
          productId: 'pantas_cs_monthly',
          tier: PriceTier.civilService,
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Monthly'), findsWidgets);
    });
  }
}
