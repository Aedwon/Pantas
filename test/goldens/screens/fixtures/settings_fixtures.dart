// Fake data for the Settings screens, lifted from
// test/features/settings/presentation/settings_ds_matrix_test.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../../features/settings/presentation/pro_page_payments_test.dart'
    show SettingsGateway;
import '../../../helpers/pump_app.dart';

const _entry = ExamCatalogEntry(
  id: 'exam_cse_sub',
  name: 'CSE Subprofessional',
  shortName: 'CSE Subprofessional',
  group: 'Civil service',
  priceTier: 'Civil Service',
  comingSoon: false,
  hasContent: true,
  publishedSittings: [],
);

/// The provider overrides every Settings screen needs: a Free student on the
/// CSE Subprofessional exam, signed out, with a fixed offering.
List<Override> settingsOverrides(AppDatabase db) => [
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
                  lessons: [ScopeLesson(id: 'whole', title: 'Whole Numbers')],
                ),
              ],
            ),
          ],
        ),
      ),
      examPickerCatalogProvider.overrideWith((ref) => Stream.value([_entry])),
      currentUserProvider.overrideWith((ref) async => null),
      isAnonymousProvider.overrideWith((ref) async => true),
      userSettingsProvider.overrideWith((ref) async => UserSettings.defaults()),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(
          buildExam(id: 'exam_cse_sub', shortName: 'CSE Subprofessional'),
        ),
      ),
      syncStatusProvider.overrideWith((ref) => Stream.value(const SyncOff())),
      revenueCatGatewayProvider.overrideWithValue(
        SettingsGateway(initial: const Entitlement.free()),
      ),
      proForActiveExamProvider.overrideWith((ref) async => false),
      activeProCatalogEntryProvider.overrideWith((ref) async => _entry),
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
    ];

/// A Settings [page] inside the app frame on the wide layout, bare on the
/// phone, as the app shows it.
Widget settingsFramed(Widget page, {required bool web}) => web
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
    : page;
