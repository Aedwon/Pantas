// ignore_for_file: directives_ordering

import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/pages/change_exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> settingsRoutes(Ref ref) => [
      GoRoute(path: '/paywall', redirect: (_, __) => '/settings/pro'),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsHomePage(),
      ),
      GoRoute(
        path: '/settings/sessions',
        builder: (_, __) => const SessionBuildingPage(),
      ),
      GoRoute(
        path: '/more',
        redirect: (_, __) => '/settings',
      ),
      GoRoute(
        path: '/settings/exam',
        builder: (_, __) => const ExamPage(),
      ),
      GoRoute(
        path: '/settings/exam/change',
        builder: (_, __) => const ChangeExamPage(),
      ),
      GoRoute(
        path: '/settings/exam/included',
        builder: (_, __) => const WhatsIncludedPage(),
      ),
      GoRoute(
        path: '/settings/account',
        builder: (_, __) => const AccountPage(),
      ),
      GoRoute(
        path: '/settings/account/delete',
        builder: (_, __) {
          final entitlement = ref.watch(entitlementProvider).valueOrNull ??
              const Entitlement.free();
          final isAnonymous =
              ref.watch(isAnonymousProvider).valueOrNull ?? false;
          final contact = ref.watch(legalContactProvider);
          return DeleteAccountPage(
            isAnonymous: isAnonymous,
            entitlement: _settingsEntitlement(entitlement),
            dpoEmail: contact.dpoEmail,
            onDelete: () => _deleteAccount(ref, isAnonymous: isAnonymous),
          );
        },
      ),
      GoRoute(
        path: '/settings/pro',
        builder: (_, __) => const ProPage(),
      ),
      GoRoute(
        path: '/settings/subscription',
        redirect: (_, __) => '/settings/pro',
      ),
      GoRoute(
        path: '/settings/backup',
        builder: (_, __) => const BackupPage(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (_, __) => const AboutPage(),
      ),
      GoRoute(
        path: '/settings/_debug',
        builder: (_, __) => const DebugSettingsPage(),
      ),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, state) => LegalDocumentPage(
          documentId: state.pathParameters['doc']!,
          contact: ref.watch(legalContactProvider),
        ),
      ),
    ];

SettingsEntitlementSnapshot _settingsEntitlement(Entitlement entitlement) {
  // Passes, grants and unknown products are not recurring subscriptions.
  if (entitlement.plan == EntitlementPlan.free) {
    return const SettingsEntitlementSnapshot.free();
  }
  return SettingsEntitlementSnapshot(
    plan: switch (entitlement.plan) {
      EntitlementPlan.free => SettingsEntitlementPlan.free,
      EntitlementPlan.weekly => SettingsEntitlementPlan.weekly,
      EntitlementPlan.monthly => SettingsEntitlementPlan.monthly,
      EntitlementPlan.yearly => SettingsEntitlementPlan.yearly,
    },
    expiresAt: entitlement.expiresAt,
    isTrial: entitlement.isTrial,
    willRenew: entitlement.willRenew,
  );
}

Future<void> _deleteAccount(Ref ref, {required bool isAnonymous}) async {
  await deleteAccountFromSettings(
    isAnonymous: isAnonymous,
    cancelNotifications: ref.read(notificationServiceProvider).cancelAll,
    deleteNamedAccount: ref.read(authRepositoryProvider).deleteAccount,
    wipeAnonymousData: SyncLocalStateWiper(
      ref.read(appDatabaseProvider),
    ).wipeAll,
  );
}

Future<void> deleteAccountFromSettings({
  required bool isAnonymous,
  required Future<void> Function() cancelNotifications,
  required Future<void> Function() deleteNamedAccount,
  required Future<void> Function() wipeAnonymousData,
}) async {
  await cancelNotifications();
  if (isAnonymous) {
    await wipeAnonymousData();
    return;
  }
  await deleteNamedAccount();
}
