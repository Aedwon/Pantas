import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/appearance_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/name_page.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final page in <Widget>[
        const ExamPage(),
        const SessionBuildingPage(),
        const AppearancePage(),
        const AccountPage(),
        const BackupPage(),
        const AboutPage(),
        const NamePage(),
        const ProPage(),
      ]) {
        testWidgets(
            '${page.runtimeType} dark=$dark scale=$scale without overflow',
            (tester) async {
          final db = inMemoryDatabase();
          addTearDown(db.close);
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpAppWithProviders(
            Theme(
              data: dark ? buildDarkTheme() : buildLightTheme(),
              child: MediaQuery(
                data: MediaQueryData(
                  size: const Size(390, 844),
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: page,
              ),
            ),
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              currentUserProvider.overrideWith((ref) async => null),
              isAnonymousProvider.overrideWith((ref) async => true),
              userSettingsProvider
                  .overrideWith((ref) async => UserSettings.defaults()),
              activeExamFocusProvider.overrideWith(
                (ref) async => ActiveExamFocus.selected(
                  buildExam(
                    id: 'exam_cse_sub',
                    shortName: 'CSE Subprofessional',
                  ),
                ),
              ),
              syncStatusProvider
                  .overrideWith((ref) => Stream.value(const SyncOff())),
              revenueCatGatewayProvider.overrideWithValue(
                SettingsGateway(initial: const Entitlement.free()),
              ),
              proForActiveExamProvider.overrideWith((ref) async => false),
              activeProCatalogEntryProvider.overrideWith(
                (ref) async => const ExamCatalogEntry(
                  id: 'exam_cse_sub',
                  name: 'CSE Subprofessional',
                  shortName: 'CSE Subprofessional',
                  group: 'Civil service',
                  priceTier: 'Civil Service',
                  comingSoon: false,
                  hasContent: true,
                  publishedSittings: [],
                ),
              ),
              paywallOfferingProvider.overrideWith(
                (ref) async => const PaywallOfferingResult(
                  status: PaywallOfferingStatus.available,
                  recognizedPackages: [
                    PaywallPackage(
                      sku: PaywallSku.weekly,
                      productId: 'pantas_cs_weekly',
                      priceString: '₱49',
                      priceAmount: 49,
                    ),
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
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}
