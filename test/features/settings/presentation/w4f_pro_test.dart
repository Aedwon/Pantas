import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

void main() {
  testWidgets('CSE page shows gateway prices even when a Student plan is owned',
      (tester) async {
    final gateway = SettingsGateway(
      initial: const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );
    await tester.pumpAppWithProviders(
      const ProPage(),
      overrides: [
        revenueCatGatewayProvider.overrideWithValue(gateway),
        proForActiveExamProvider.overrideWith((ref) async => false),
        activeExamFocusProvider.overrideWith(
          (ref) async => ActiveExamFocus.selected(
            buildExam(id: 'exam_cse_pro', shortName: 'CSE Professional'),
          ),
        ),
        isAnonymousProvider.overrideWith((ref) async => false),
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
          (ref) async => const PaywallOfferingResult(
            status: PaywallOfferingStatus.available,
            recognizedPackages: [
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_cs_monthly',
                priceString: '₱149',
                priceAmount: 149,
              ),
              PaywallPackage(
                sku: PaywallSku.yearly,
                productId: 'pantas_cs_yearly',
                priceString: '₱1,199',
                priceAmount: 1199,
              ),
            ],
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('PLANS FOR CSE PROFESSIONAL'), findsOneWidget);
    expect(find.text('₱149'), findsOneWidget);
    expect(find.text('SAVE 32%'), findsOneWidget);
    expect(find.text('₱100 a month'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('a year')).dy,
      lessThan(tester.getTopLeft(find.text('₱100 a month')).dy),
    );
    expect(find.text('₱99 / month'), findsNothing);
  });
  testWidgets('paused Pro shows the approved line', (tester) async {
    await tester.pumpAppWithProviders(
      const ProPage(),
      overrides: [
        entitlementProvider.overrideWith(
          (ref) => Stream.value(
            const Entitlement(
              plan: EntitlementPlan.monthly,
              state: EntitlementState.paused,
            ),
          ),
        ),
        proForActiveExamProvider.overrideWith((ref) async => false),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Connect once to keep using Pro.'), findsOneWidget);
  });
}
