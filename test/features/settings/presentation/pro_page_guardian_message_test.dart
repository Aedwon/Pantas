import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

const message = 'Ask your parent or guardian to complete this payment';

void main() {
  for (final entry in {'phone': false, 'wide web': true}.entries) {
    for (final group in ['minor', 'adult', null]) {
      testWidgets('checkout message for $group on ${entry.key}',
          (tester) async {
        if (entry.value) {
          debugWebPlatformOverride = true;
          addTearDown(() => debugWebPlatformOverride = null);
          tester.view
            ..physicalSize = const Size(1440, 900)
            ..devicePixelRatio = 1;
          addTearDown(() {
            tester.view
              ..resetPhysicalSize()
              ..resetDevicePixelRatio();
          });
        }
        final gateway = SettingsGateway(
          initial: const Entitlement(
            plan: EntitlementPlan.monthly,
            productId: 'pantas_pro_monthly',
          ),
        );
        await tester.pumpAppWithProviders(
          const ProPage(),
          overrides: [
            ageGroupProvider.overrideWith((ref) async => group),
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
        expect(
          find.text(message),
          group == 'minor' ? findsOneWidget : findsNothing,
        );
        // The message never blocks checkout: the offers still show.
        expect(find.text('₱149'), findsOneWidget);
        // Test fonts overflow one wide-web row in every case; not under test.
        tester.takeException();
      });
    }
  }
}
