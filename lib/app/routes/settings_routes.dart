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
import 'package:pantas/features/settings/presentation/pages/appearance_page.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/name_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/domain/exam_change_result.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/features/paywall/domain/switch_outcome.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> settingsRoutes(Ref ref) => [
      GoRoute(path: '/paywall', redirect: (_, __) => '/settings/pro'),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsHomePage(),
      ),
      GoRoute(
        path: '/settings/sessions',
        redirect: (_, __) => '/settings/practice',
      ),
      GoRoute(
        path: '/settings/practice',
        builder: (_, __) => const SessionBuildingPage(),
      ),
      GoRoute(
        path: '/settings/appearance',
        builder: (_, __) => const AppearancePage(),
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
      settingsCarryOverRoute(),
      GoRoute(
        path: '/settings/exam/included',
        builder: (_, __) => const WhatsIncludedPage(),
      ),
      GoRoute(
        path: '/settings/account',
        builder: (_, __) => const AccountPage(),
      ),
      GoRoute(
        path: '/settings/account/name',
        builder: (_, __) => const NamePage(),
      ),
      GoRoute(
        path: '/settings/account/delete',
        builder: (_, __) => Consumer(
          builder: (context, ref, _) {
            final entitlement = ref.watch(entitlementProvider).valueOrNull ??
                const Entitlement.free();
            final isAnonymous =
                ref.watch(isAnonymousProvider).valueOrNull ?? false;
            final contact = ref.watch(legalContactProvider);
            return DeleteAccountPage(
              isAnonymous: isAnonymous,
              entitlement: _settingsEntitlement(entitlement),
              dpoEmail: contact.dpoEmail,
              onDelete: () async {
                final preferences = ref.read(appPreferencesRepositoryProvider);
                final container =
                    ProviderScope.containerOf(context, listen: false);
                await _deleteAccount(ref, isAnonymous: isAnonymous);
                await preferences.setCompletedOnboarding(value: false);
                await preferences.setPassedAgeGate(value: false);
                container
                  ..invalidate(passedAgeGateProvider)
                  ..invalidate(onboardingCompleteProvider)
                  ..invalidate(userSettingsProvider);
                if (context.mounted) context.go('/onboarding');
              },
            );
          },
        ),
      ),
      GoRoute(
        path: '/settings/pro',
        builder: (_, state) => ProPage(checkoutReturnUri: state.uri),
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

Future<void> _deleteAccount(WidgetRef ref, {required bool isAnonymous}) async {
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

class ChangeExamPage extends ConsumerWidget {
  const ChangeExamPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ExamPickerScreen(
        mode: ExamPickerMode.settings,
        onPicked: (examId) async {
          final publish =
              await ref.read(studySettingsCaptureProvider)(examId: examId);
          var targetSaved = false;
          Future<void> saveTarget() async {
            if (targetSaved) return;
            await publish.apply(
              () => ref
                  .read(appPreferencesRepositoryProvider)
                  .setSelectedExamId(examId),
            );
            targetSaved = true;
          }

          final focus = await ref.read(activeExamFocusProvider.future);
          final catalog = ref.read(examPickerCatalogProvider).valueOrNull;
          final from =
              catalog?.where((e) => e.id == focus.exam?.id).firstOrNull;
          final to = catalog?.where((e) => e.id == examId).firstOrNull;
          if (from != null && to != null) {
            final entitlement = await ref.read(entitlementProvider.future);
            final outcome = switchOutcome(from, to, entitlement);
            if (!context.mounted) return;
            if (outcome.kind == SwitchKind.passWarning) {
              final ends = entitlement.passes[from.id]!;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => CenteredDialog(
                  title: 'Your pass stays with ${from.shortName}',
                  inlineActions: true,
                  message: "On ${to.shortName} you'll be on Free. "
                      'Switch back any time before '
                      '${DateFormat.yMMMd().format(ends.toLocal())} '
                      'and your pass is still there.',
                  primaryLabel: 'Switch',
                  secondaryLabel: 'Cancel',
                  onConfirm: () => Navigator.of(dialogContext).pop(true),
                  onCancel: () => Navigator.of(dialogContext).pop(false),
                ),
              );
              if (confirmed != true) return;
            }
            if (outcome.kind == SwitchKind.upgradeOffer) {
              if (!context.mounted) return;
              final proceed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (upgradeContext) => ProPage(
                    targetExam: to,
                    previousExamName: from.shortName,
                    onSwitchOnFree: () async =>
                        Navigator.of(upgradeContext).pop(true),
                    onBeforeUpgrade: saveTarget,
                  ),
                ),
              );
              if (proceed != true || !context.mounted) return;
            }
          }
          await saveTarget();
          final count = await ref.read(carryableCountProvider(examId).future);
          final exams = await ref.read(examListProvider.future);
          if (!context.mounted) return;
          final route = ModalRoute.of(context);
          Navigator.of(context).pop(
            ExamChangeResult(
              examShortName: exams.firstWhere((e) => e.id == examId).shortName,
              carryableCount: count,
              routeSettled: route?.completed ?? Future<void>.value(),
            ),
          );
        },
      );
}

GoRoute settingsCarryOverRoute() => GoRoute(
      path: '/settings/exam/transfer',
      redirect: (_, state) =>
          state.extra is CarryOverRequest ? null : '/settings/exam',
      builder: (_, state) {
        final request = state.extra! as CarryOverRequest;
        return CarryOverScreen(
          exam: request.exam,
          previous: request.previous,
          onCounted: request.onCounted,
          onDecision: request.onDecision,
        );
      },
    );
