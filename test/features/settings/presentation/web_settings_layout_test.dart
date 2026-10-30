import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
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
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/name_page.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  testWidgets('large settings row wraps its label and stacks its value',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(1440, 1000),
            textScaler: TextScaler.linear(2),
          ),
          child: Material(
            child: Center(
              child: SizedBox(
                width: 300,
                child: SettingsRow(
                  title: 'Remember table order for all topics and lessons',
                  value: 'Automatic follows your computer',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final label = find.text('Remember table order for all topics and lessons');
    final value = find.text('Automatic follows your computer');
    expect(tester.widget<Text>(label).maxLines, isNull);
    expect(tester.getSize(label).height, greaterThan(60));
    expect(
      tester.getTopLeft(value).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(label).dy),
    );
    expect(tester.takeException(), isNull);
  });
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final page in <Widget>[
        CarryOverScreen(
          exam: 'CSE Professional',
          previous: 'CSE Subprofessional',
          onCounted: () {},
        ),
        DeleteAccountPage(
          isAnonymous: false,
          entitlement: const SettingsEntitlementSnapshot.free(),
          dpoEmail: defaultLegalContact.dpoEmail,
          onDelete: () async {},
        ),
        const SettingsPanePage(
          section: 'About',
          title: 'Privacy policy',
          children: [LegalDocumentBody(documentId: 'privacy')],
        ),
        const SettingsPanePage(
          section: 'About',
          title: 'Terms of service',
          children: [LegalDocumentBody(documentId: 'terms')],
        ),
        const SettingsHomePage(),
        const WhatsIncludedPage(),
        const ExamPage(),
        const ChangeExamPage(),
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
          tester.view.physicalSize = const Size(1440, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpAppWithProviders(
            Theme(
              data:
                  dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
              child: MediaQuery(
                data: MediaQueryData(
                  size: const Size(1440, 1000),
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: WebShellFrame(
                  activeIndex: 3,
                  person: 'Student',
                  exam: 'CSE Subprofessional',
                  plan: 'Free',
                  web: true,
                  onNavigate: (_) {},
                  onSearch: () {},
                  child: page,
                ),
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
          expect(
            find.byKey(const ValueKey('settings-navigation')),
            findsOneWidget,
          );
          expect(find.byKey(const ValueKey('settings-detail')), findsOneWidget);
          expect(find.text('Settings'), findsNWidgets(2));
          expect(find.text('Reminders'), findsNothing);
          if (page is SessionBuildingPage) {
            final selector = find.byType(SegmentedSwitch);
            expect(tester.getSize(selector).width, 420);
            final padding = tester.widget<Padding>(
              find.ancestor(of: selector, matching: find.byType(Padding)).first,
            );
            expect(
              padding.padding,
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            );
          }
          if (page is ExamPage && scale == 1) {
            final label = find.text('Study days');
            final sunday = find.byKey(const ValueKey('study-day-7'));
            expect(tester.getSize(sunday), const Size(44, 44));
            expect(tester.getCenter(label).dy, tester.getCenter(sunday).dy);
            final monday = find.byKey(const ValueKey('study-day-1'));
            expect(
              tester.getTopLeft(monday).dx - tester.getTopLeft(sunday).dx,
              52,
            );
          }
          if (page is AppearancePage) {
            expect(
              find.text('Automatic follows your computer: '
                  'light by day, dark at night.'),
              findsOneWidget,
            );
            expect(
              find.text('Lessons and questions use this size. '
                  'Ctrl + and Ctrl − still zoom the whole page.'),
              findsOneWidget,
            );
          }
          if (page is DeleteAccountPage) {
            expect(find.byType(Dialog), findsOneWidget);
            expect(find.text('Delete your account?'), findsOneWidget);
          }
          if (page is WhatsIncludedPage) {
            expect(find.text('NUMERICAL ABILITY'), findsOneWidget);
            expect(find.text('Number Sense'), findsOneWidget);
            final mark = tester.widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byKey(const ValueKey('scope-select-numbers')),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            );
            expect(
              (mark.decoration as BoxDecoration).shape,
              BoxShape.rectangle,
            );
            await tester
                .tap(find.byKey(const ValueKey('scope-select-numbers')));
            await tester.pumpAndSettle();
            expect(
              find.text('At least one topic stays ticked.'),
              findsOneWidget,
            );
          }
          if (page is SettingsPanePage) {
            expect(find.textContaining('Updated '), findsOneWidget);
          }
          if (page is CarryOverScreen) {
            await tester.ensureVisible(find.text('Count Them'));
            await tester.tap(find.text('Count Them'));
            await tester.pumpAndSettle();
            expect(find.text('You pick up where you are'), findsOneWidget);
            expect(find.text('Done'), findsOneWidget);
          }
          if (page is ChangeExamPage) {
            expect(find.byType(Dialog), findsOneWidget);
            expect(find.text('Search exams'), findsOneWidget);
          }
          if (page is ProPage) {
            expect(find.byKey(const ValueKey('pro-hero')), findsOneWidget);
            expect(find.text('Restore Purchases'), findsOneWidget);
            expect(tester.widget<Text>(find.text('₱149')).style?.fontSize, 26);
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}
