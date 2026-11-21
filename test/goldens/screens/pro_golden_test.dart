// Route /pro and /settings/pro, a Free student with the plans and the pass.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/settings.dart';

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
const _studentMonthly = PaywallPackage(
  sku: PaywallSku.monthly,
  productId: 'pantas_pro_monthly',
  priceString: '₱149',
  priceAmount: 149,
);
const _pshsPass = PaywallPassPackage(
  productId: 'pantas_pass_pshs_nce',
  priceString: '₱1,499',
  priceAmount: 1499,
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

  // Under-13 build T9: a child's PSHS-NCE pass, with the checkout box ticked
  // off and the child's name under the buy button. The client product table
  // has no PSHS-NCE product yet, so the page looks it up through a fake one.
  goldenScreen('pro_pshs_box', (tester, width) async {
    const entitlement = Entitlement.free();
    final sitting = screenNow.add(const Duration(days: 30));
    final day = DateTime.utc(sitting.year, sitting.month, sitting.day);
    final target = await pumpScreen(
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
        ageGroupProvider.overrideWith((ref) async => AgeGroup.child),
        userSettingsProvider.overrideWith(
          (ref) async => const UserSettings(
            name: 'Sample',
            dailyReminderTime: null,
            studyDays: StudyDays.all,
            examDate: null,
            strictMockMode: false,
            helpImproveApp: false,
            carryOverProgress: true,
            sessionOrdering: SessionOrdering.interleavedTail,
            retainTableOrder: true,
            updatedAt: null,
          ),
        ),
        proPageProductLookupProvider.overrideWithValue(
          (id) => id == _pshsPass.productId
              ? const ProductDefinition(
                  tier: PriceTier.student,
                  kind: ProductKind.pass,
                  examId: 'exam_pshs_nce',
                )
              : productForId(id),
        ),
        entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
        proForActiveExamProvider.overrideWith((ref) async => false),
        pendingPurchaseProvider.overrideWithValue(const AsyncData(null)),
        webGrantHistoryProvider.overrideWith((ref) async => const []),
        activeProCatalogEntryProvider.overrideWith(
          (ref) async => ExamCatalogEntry(
            id: 'exam_pshs_nce',
            name: 'PSHS-NCE',
            shortName: 'PSHS-NCE',
            priceTier: 'Student',
            group: 'High school',
            comingSoon: false,
            hasContent: true,
            publishedSittings: [
              PublishedExamSitting(
                firstDay: day,
                lastDay: day,
                sourceUrl: 'https://pshs.example.test',
              ),
            ],
          ),
        ),
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult(
            status: PaywallOfferingStatus.available,
            recognizedPackages: [_studentMonthly],
            passPackages: [_pshsPass],
          ),
        ),
      ],
    );
    await tester.tap(find.text('Season Pass').first);
    await settleFrames(tester, 4);
    // The box sits under the plans; bring it into view.
    await tester.ensureVisible(find.byType(CheckboxRow));
    await settleFrames(tester, 4);
    return target;
  });
}
