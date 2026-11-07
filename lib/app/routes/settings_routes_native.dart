// ignore_for_file: directives_ordering

import 'package:pantas/app/routes/settings_account_deletion.dart';
export 'package:pantas/app/routes/settings_account_deletion.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/beta_feedback/presentation/exit_survey_page.dart';
import 'package:pantas/features/beta_feedback/presentation/feedback_page.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/domain/switch_outcome.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/domain/exam_change_result.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/appearance_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/presentation/pages/name_page.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/settings.dart';

List<RouteBase> settingsRoutes(Ref ref) => [
      GoRoute(
        path: '/pro',
        redirect: (_, state) =>
            state.uri.replace(path: '/settings/pro').toString(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsHomePage(),
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
        path: '/settings/exam',
        builder: (_, __) => const ExamPage(),
      ),
      GoRoute(
        path: '/settings/exam/change',
        builder: (_, __) => const ChangeExamPage(),
      ),
      GoRoute(
        path: '/settings/exam/upgrade',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            final target = ref
                .watch(examPickerCatalogProvider)
                .valueOrNull
                ?.where((e) => e.id == state.uri.queryParameters['target'])
                .firstOrNull;
            if (target == null) return const ChangeExamPage();
            return ProPage(
              targetExam: target,
              previousExamName: state.uri.queryParameters['from'],
              onSwitchOnFree: () async => context.pop(true),
            );
          },
        ),
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
        path: '/settings/beta-feedback',
        builder: (_, __) => const _TesterOnly(
          child: FeedbackPage(frame: feedbackFrame),
        ),
      ),
      GoRoute(
        path: '/settings/beta-feedback/survey',
        builder: (_, __) => const _TesterOnly(
          child: ExitSurveyPage(frame: feedbackFrame),
        ),
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
        builder: (context, state) {
          final id = state.pathParameters['doc']!;
          return Consumer(
            builder: (context, localRef, _) {
              final onboarding = localRef.watch(legalInOnboardingProvider);
              if (!context.wideWeb) {
                return LegalDocumentPage(
                  documentId: id,
                  contact: ref.watch(legalContactProvider),
                  backLabel: onboarding ? 'Back' : 'About',
                  backFallback: onboarding ? '/onboarding' : '/settings/about',
                );
              }
              if (onboarding) return OnboardingLegalPage(documentId: id);
              return SettingsPanePage(
                section: 'About',
                title: id == 'privacy'
                    ? 'Privacy Policy'
                    : legalDocumentFallbacks[id]?.title ?? 'Legal',
                description: LegalDocumentBody.updatedLine(id),
                backLabel: 'About',
                onBack: () => leavePage(context, fallback: '/settings/about'),
                children: [LegalDocumentBody(documentId: id)],
              );
            },
          );
        },
      ),
    ];

/// The Feedback pages in the Settings pane (phone page or wide two-pane).
/// The pages take this as a function so they never import Settings.
Widget feedbackFrame({
  required String title,
  required List<Widget> children,
  required String backLabel,
  required VoidCallback onBack,
  bool beta = false,
  String? subline,
  double headingGap = 24,
  bool heading = true,
}) =>
    Builder(
      builder: (context) => SettingsPanePage(
        section: 'Feedback',
        title: title,
        description: subline,
        backLabel: backLabel,
        onBack: onBack,
        compactTitle: true,
        bottomInset: 40,
        noHeading: !heading,
        hideHeading: !heading,
        headingGap: headingGap,
        titleSuffix: beta ? const SettingsBetaMark(top: 4) : null,
        headingGlyph: beta
            ? SettingsFeedbackGlyph(
                size: 22,
                color: context.webTokens.colors.accent,
              )
            : null,
        children: children,
      ),
    );

/// A person the server says is not a tester goes back to Settings.
class _TesterOnly extends ConsumerWidget {
  const _TesterOnly({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(betaAccessProvider).valueOrNull;
    if (access != null && !access.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/settings');
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}

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

class ChangeExamPage extends ConsumerStatefulWidget {
  const ChangeExamPage({super.key});
  @override
  ConsumerState<ChangeExamPage> createState() => _ChangeExamPageState();
}

class _ChangeExamPageState extends ConsumerState<ChangeExamPage> {
  // On wide web the picker is a dialog. It plays its exit before the route
  // pops, so leaving goes through here.
  final _exit = WebOverlayExit();

  @override
  Widget build(BuildContext context) {
    final picker = ExamPickerScreen(
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
        final from = catalog?.where((e) => e.id == focus.exam?.id).firstOrNull;
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
            final proceed = await context.push<bool>(
              Uri(
                path: '/settings/exam/upgrade',
                queryParameters: {
                  'target': to.id,
                  'from': from.shortName,
                },
              ).toString(),
            );
            if (proceed != true || !context.mounted) return;
          }
        }
        await saveTarget();
        final count = await ref.read(carryableCountProvider(examId).future);
        final exams = await ref.read(examListProvider.future);
        if (!context.mounted) return;
        final route = ModalRoute.of(context);
        final result = ExamChangeResult(
          examShortName: exams.firstWhere((e) => e.id == examId).shortName,
          carryableCount: count,
          routeSettled: route?.completed ?? Future<void>.value(),
        );
        _exit.close(
          () => leavePage(
            context,
            fallback: '/settings/exam',
            result: result,
            respectPopScope: false,
          ),
        );
      },
      // Only web opens this page directly, with nothing to pop to. Setting
      // onBack also blocks the picker's own pop, which turns off predictive
      // back, so native keeps its default. With it set, leaving must not ask
      // the picker's PopScope again.
      onBack: context.webPlatform
          ? () => _exit.close(
                () => leavePage(
                  context,
                  fallback: '/settings/exam',
                  respectPopScope: false,
                ),
              )
          : null,
    );
    if (!context.wideWeb) return picker;
    void leave() => leavePage(
          context,
          fallback: '/settings/exam',
          respectPopScope: false,
        );
    return WebRootModal(
      exit: _exit,
      onDismiss: () => _exit.close(leave),
      onBack: leave,
      modal: (modalContext) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          width: 820,
          height: (MediaQuery.sizeOf(modalContext).height - 48).clamp(0, 760),
          child: picker,
        ),
      ),
      child: const ExamPage(),
    );
  }
}

GoRoute settingsCarryOverRoute() => GoRoute(
      path: '/settings/exam/transfer',
      redirect: (_, state) =>
          carryOverRequestFor(state.extra) == null ? '/settings/exam' : null,
      builder: (_, state) {
        final request = carryOverRequestFor(state.extra)!;
        return CarryOverScreen(
          exam: request.exam,
          previous: request.previous,
          count: request.count,
          onCounted: request.onCounted,
          onDecision: request.onDecision,
        );
      },
    );
