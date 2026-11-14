// Route /pro and /settings/pro, a Free student with the plans and the pass.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../features/settings/presentation/pro_page_payments_test.dart'
    show SettingsGateway;
import '../../helpers/in_memory_database.dart';
import 'screen_harness.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen('pro', (tester, width) {
    const entitlement = Entitlement.free();
    final sitting = screenNow.add(const Duration(days: 30));
    final day = DateTime.utc(sitting.year, sitting.month, sitting.day);
    return pumpScreen(
      tester,
      width,
      inShell(const ProPage(), width, ShellTab.settings),
      frames: 12,
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
        paymentsOnWebProvider.overrideWithValue(width >= 1024),
        entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
        proForActiveExamProvider.overrideWith((ref) async => false),
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
    );
  });
}
