// Design system 4.0, Settings family: every Settings screen and the legal
// pages at 390, 1100 and 1440 wide, light and dark, at text scale 1.0 and 2.0,
// with no layout overflow. The wide widths sit inside the app frame, as in the
// app; the phone width does not.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/appearance_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/name_page.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

/// A phone, the compact sidebar range and the full width.
final _cells = <DsCell>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
];

final _pages = <String, Widget Function()>{
  'SettingsHomePage': () => const SettingsHomePage(),
  'AccountPage': () => const AccountPage(),
  'NamePage': () => const NamePage(),
  'DeleteAccountPage': () => DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot.free(),
        dpoEmail: defaultLegalContact.dpoEmail,
        onDelete: () async {},
      ),
  'ExamPage': () => const ExamPage(),
  'ChangeExamPage': () => const ChangeExamPage(),
  'WhatsIncludedPage': () => const WhatsIncludedPage(),
  'CarryOverScreen': () => CarryOverScreen(
        exam: 'CSE Professional',
        previous: 'CSE Subprofessional',
        onCounted: () {},
      ),
  'SessionBuildingPage': () => const SessionBuildingPage(),
  'AppearancePage': () => const AppearancePage(),
  'BackupPage': () => const BackupPage(),
  'AboutPage': () => const AboutPage(),
  'DebugSettingsPage': () => const DebugSettingsPage(),
  'PrivacyPolicy': () => const LegalDocumentPage(
        documentId: 'privacy',
        contact: defaultLegalContact,
      ),
  'TermsOfService': () => SettingsPanePage(
        section: 'About',
        title: 'Terms of Service',
        description: LegalDocumentBody.updatedLine('terms'),
        children: const [LegalDocumentBody(documentId: 'terms')],
      ),
  'OnboardingLegalPage': () => const OnboardingLegalPage(documentId: 'privacy'),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  tearDown(() => debugWebPlatformOverride = null);

  for (final cell in _cells) {
    for (final entry in _pages.entries) {
      // The wide-only pages have no phone form.
      final wideOnly =
          entry.key == 'ChangeExamPage' || entry.key == 'OnboardingLegalPage';
      if (wideOnly && cell.width < 1024) continue;
      testWidgets('${entry.key} ($cell) without overflow', (tester) async {
        final web = cell.width >= 1024;
        debugWebPlatformOverride = web;
        final db = inMemoryDatabase();
        addTearDown(db.close);
        tester.view
          ..physicalSize = Size(cell.width, 1000)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final page = entry.value();
        await tester.pumpAppWithProviders(
          Theme(
            data: cell.dark
                ? buildDarkTheme(web: web)
                : buildLightTheme(web: web),
            child: MediaQuery(
              data: MediaQueryData(
                size: Size(cell.width, 1000),
                textScaler: TextScaler.linear(cell.scale),
                disableAnimations: true,
              ),
              child: web && entry.key != 'OnboardingLegalPage'
                  ? WebShellFrame(
                      activeIndex: 3,
                      person: 'Student',
                      exam: 'CSE Subprofessional',
                      plan: 'Free',
                      web: true,
                      onNavigate: (_) {},
                      onSearch: () {},
                      child: page,
                    )
                  : page,
            ),
          ),
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            whatsIncludedDataProvider.overrideWith(
              (ref, examId) async => (
                exam: buildExam(id: examId, shortName: 'CSE Subprofessional'),
                excluded: <String>{},
                excludedLessons: <String>{},
                subjects: const [
                  ScopeSubject(
                    title: 'Numerical Ability',
                    topics: [
                      ScopeTopic(
                        id: 'numbers',
                        title: 'Number Sense',
                        lessons: [
                          ScopeLesson(id: 'whole', title: 'Whole Numbers'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            examPickerCatalogProvider.overrideWith(
              (ref) => Stream.value([
                const ExamCatalogEntry(
                  id: 'exam_cse_sub',
                  name: 'CSE Subprofessional',
                  shortName: 'CSE Subprofessional',
                  group: 'Civil service',
                  priceTier: 'Civil Service',
                  comingSoon: false,
                  hasContent: true,
                  publishedSittings: [],
                ),
              ]),
            ),
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
      });
    }
  }
}
