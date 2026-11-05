// ignore_for_file: directives_ordering

import 'package:pantas/app/routes/settings_account_deletion.dart';
export 'package:pantas/app/routes/settings_account_deletion.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';
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
      // A student's own exam, made from the exam picker. They look and behave
      // as the onboarding steps do, but sit outside `/onboarding/`, which a
      // student who has finished onboarding cannot enter. Each pops with the
      // new exam's id, and the picker saves it like any other pick.
      GoRoute(
        path: '/settings/exam/custom/name',
        builder: (_, __) => const _SettingsCustomName(),
      ),
      GoRoute(
        path: '/settings/exam/custom/subjects',
        // The typed name travels in the route's extra, never in the address.
        // With none, as after a reload or a typed address, there is nothing to
        // make an exam from, so the student goes back to the picker.
        redirect: (_, state) =>
            _customExamName(state.extra) == null ? _customExamBackTo : null,
        builder: (_, state) =>
            _SettingsCustomSubjects(name: _customExamName(state.extra)!),
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
      clearCustomExams: () =>
          deleteCustomContentExams(ref.read(contentDatabaseProvider)),
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
            final confirmed = await _confirmSwitch(
              context,
              title: 'Your pass stays with ${from.shortName}',
              message: "On ${to.shortName} you'll be on Free. "
                  'Switch back any time before '
                  '${DateFormat.yMMMd().format(ends.toLocal())} '
                  'and your pass is still there.',
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
        if (isCustomExamId(examId)) {
          // A student's own exam is free to study. A paying student is told
          // so before moving to one, and the track keeps its place in the list.
          final entitlement = await ref.read(entitlementProvider.future);
          if (entitlement.proIsActive) {
            final name =
                await ref.read(customTrackRepositoryProvider).name(examId);
            if (name == null) throw StateError('Unknown custom exam');
            if (!context.mounted) return;
            final confirmed = await _confirmSwitch(
              context,
              title: 'Your plan stays with your account',
              message: "On $name you'll be on Free. Switch back any time.",
            );
            if (confirmed != true) return;
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

/// The dialog before a switch that changes what the student's plan covers.
Future<bool?> _confirmSwitch(
  BuildContext context, {
  required String title,
  required String message,
}) =>
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => CenteredDialog(
        title: title,
        inlineActions: true,
        message: message,
        primaryLabel: 'Switch',
        secondaryLabel: 'Cancel',
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );

/// The page a student's own exam steps fall back to without a name.
const _customExamBackTo = '/settings/exam/change';

/// The name the subjects step is given through the route's extra, or null.
String? _customExamName(Object? extra) =>
    extra is String && extra.trim().isNotEmpty ? extra : null;

/// The name step of a student's own exam, opened from Settings. It looks and
/// acts as it does in onboarding, and goes on to the subjects step. Whatever id
/// that step ends with passes back to the picker.
class _SettingsCustomName extends StatelessWidget {
  const _SettingsCustomName();
  @override
  Widget build(BuildContext context) => CustomTrackNameStep(
        onContinue: (name) async {
          final made = await context.push<String>(
            '/settings/exam/custom/subjects',
            extra: name,
          );
          if (made != null && context.mounted) context.pop(made);
        },
      );
}

/// The subjects step of a student's own exam, opened from Settings. It makes
/// the track and leaves the exam unchanged: onboarding is already complete,
/// and the picker saves the choice as it does for a listed exam.
class _SettingsCustomSubjects extends StatefulWidget {
  const _SettingsCustomSubjects({required this.name});
  final String name;
  @override
  State<_SettingsCustomSubjects> createState() =>
      _SettingsCustomSubjectsState();
}

class _SettingsCustomSubjectsState extends State<_SettingsCustomSubjects> {
  String? _made;
  @override
  Widget build(BuildContext context) => CustomTrackSubjectsStep(
        name: widget.name,
        fromSettings: true,
        onCreated: (id) => _made = id,
        onCompleted: () {
          final made = _made;
          if (made != null) context.pop(made);
        },
      );
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
