// ignore_for_file: directives_ordering

import 'package:cse_cet_reviewer/app/router_refresh_listenable.dart';
import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/sync/local_state_wiper.dart';
import 'package:cse_cet_reviewer/core/storage/age_gate.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/features/assessment/assessment.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:cse_cet_reviewer/features/legal/legal.dart';
import 'package:cse_cet_reviewer/features/legal/presentation/legal_document_page.dart';
import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:cse_cet_reviewer/features/notifications/application/notifications_providers.dart';
import 'package:cse_cet_reviewer/features/notifications/presentation/permission_rationale_page.dart';
import 'package:cse_cet_reviewer/features/onboarding/onboarding.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/progress_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/drill_subtopic_browser.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
import 'package:cse_cet_reviewer/features/shell/presentation/app_shell.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/about_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/account_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/backup_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/delete_account_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/settings_home_page.dart';
import 'package:cse_cet_reviewer/features/study_plan/presentation/plan_page.dart';
import 'package:cse_cet_reviewer/features/wrapped/presentation/wrapped_reveal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref, [
    passedAgeGateProvider,
    activeExamFocusProvider,
    entitlementProvider,
    notificationRationaleShownProvider,
  ]);
  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final passedAsync = ref.read(passedAgeGateProvider);
      final focusAsync = ref.read(activeExamFocusProvider);
      final passed = passedAsync.valueOrNull;
      final focus = focusAsync.valueOrNull;
      if (passed == null || focus == null) return null;
      final atOnboarding = state.matchedLocation == '/onboarding';
      final atNotificationRationale =
          state.matchedLocation == '/notifications/rationale';
      final atPaywall = state.matchedLocation == '/paywall';
      final needsSelection = focus.needsSelection;
      if (!passed && !atOnboarding) return '/onboarding';
      if (passed && needsSelection && !atOnboarding) return '/onboarding';
      if (passed && !needsSelection && atOnboarding) {
        final rationaleShown =
            ref.read(notificationRationaleShownProvider).valueOrNull;
        if (rationaleShown == false) return '/notifications/rationale';
        return '/home';
      }
      if (passed && !needsSelection && atNotificationRationale) {
        final rationaleShown =
            ref.read(notificationRationaleShownProvider).valueOrNull;
        if (rationaleShown ?? false) return '/home';
      }
      if (_isProRoute(state.matchedLocation) && !atPaywall) {
        final entitlement = ref.read(entitlementProvider).valueOrNull;
        if (entitlement == null) return null;
        if (!entitlement.proIsActive) {
          final returnTo = Uri.encodeComponent(state.uri.toString());
          return '/paywall?returnTo=$returnTo';
        }
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const AssessmentHomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study',
                builder: (_, __) => const StudyTabHome(),
                routes: [
                  GoRoute(
                    path: 'topic/:topicId',
                    builder: (_, state) => LessonListPage(
                      topicId: state.pathParameters['topicId']!,
                      examId: state.uri.queryParameters['examId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quiz',
                builder: (_, __) => const QuizTabHome(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (_, __) {
                  final entitlement =
                      ref.watch(entitlementProvider).valueOrNull ??
                          const Entitlement.free();
                  return ProgressPage(proIsActive: entitlement.proIsActive);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/notifications/rationale',
        builder: (_, __) => const PermissionRationalePage(),
      ),
      GoRoute(
        path: '/plan',
        builder: (_, __) => const PlanPage(),
      ),
      GoRoute(
        path: '/plan/dossier/:mockId',
        builder: (_, state) => _Stub(
          'Pro dossier: ${state.pathParameters['mockId']}',
        ),
      ),
      GoRoute(
        path: '/quiz/today/:examId',
        builder: (_, state) => QuizPage(
          examId: state.pathParameters['examId']!,
          mode: QuizPageMode.today,
          topicId: state.uri.queryParameters['topicId'],
        ),
      ),
      GoRoute(
        path: '/quiz/quick/:examId',
        builder: (_, state) => QuizPage(
          examId: state.pathParameters['examId']!,
          topicId: state.uri.queryParameters['topicId'],
        ),
      ),
      GoRoute(
        path: '/quiz/drill/:examId',
        builder: (_, state) {
          final examId = state.pathParameters['examId']!;
          final topicId = state.uri.queryParameters['topicId'];
          if (topicId != null) {
            return QuizPage(
              examId: examId,
              topicId: topicId,
              mode: QuizPageMode.drill,
            );
          }
          return DrillSubtopicBrowser(examId: examId);
        },
      ),
      GoRoute(
        path: '/quiz/retake/:examId',
        builder: (_, state) => QuizPage(
          examId: state.pathParameters['examId']!,
          mode: QuizPageMode.retake,
        ),
      ),
      GoRoute(
        path: '/quiz/inline/:examId/:lessonId',
        builder: (_, state) => QuizPage(
          examId: state.pathParameters['examId']!,
          lessonId: state.pathParameters['lessonId'],
          mode: QuizPageMode.inline,
        ),
      ),
      GoRoute(
        path: '/quiz/results/:attemptId',
        builder: (_, state) =>
            QuizResultsPage(attemptId: state.pathParameters['attemptId']!),
      ),
      GoRoute(
        path: '/quiz/mock/setup',
        builder: (_, __) => const MockSetupPlaceholderPage(),
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (_, state) => LessonPage(
          lessonId: state.pathParameters['lessonId']!,
          examId: state.uri.queryParameters['examId'],
        ),
      ),
      GoRoute(
        path: '/assessment/:examId',
        builder: (_, state) =>
            AssessmentPage(examId: state.pathParameters['examId']!),
        routes: [
          GoRoute(
            path: 'results',
            builder: (_, state) =>
                AssessmentResultsPage(examId: state.pathParameters['examId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/review',
        builder: (_, __) => const _Stub('Review'),
      ),
      GoRoute(
        path: '/mock-exam',
        builder: (_, __) => const _Stub('Mock Exam'),
      ),
      GoRoute(
        path: '/wrapped/:artifactId',
        builder: (_, state) => WrappedRevealPage(
          artifactId: state.pathParameters['artifactId']!,
        ),
      ),
      GoRoute(
        path: '/paywall',
        builder: (_, state) => PaywallPage(
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) {
          final entitlement = ref.watch(entitlementProvider).valueOrNull ??
              const Entitlement.free();
          return SettingsHomePage(
            subscriptionSubtitle: _subscriptionSubtitle(entitlement),
          );
        },
      ),
      GoRoute(
        path: '/more',
        redirect: (_, __) => '/settings',
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
        path: '/settings/subscription',
        builder: (_, __) {
          final entitlement = ref.watch(entitlementProvider).valueOrNull ??
              const Entitlement.free();
          return Scaffold(
            appBar: AppBar(title: const Text('Subscription')),
            body: SubscriptionPanel(entitlement: entitlement),
          );
        },
      ),
      GoRoute(
        path: '/settings/backup',
        builder: (_, __) => const BackupPage(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (_, __) {
          final contact = ref.watch(legalContactProvider);
          return AboutPage(
            version: '0.1.0',
            buildNumber: '1',
            dpoEmail: contact.dpoEmail,
            physicalAddress: contact.physicalAddress,
          );
        },
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
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

bool _isProRoute(String matchedLocation) {
  return matchedLocation.startsWith('/plan/dossier/');
}

String _subscriptionSubtitle(Entitlement entitlement) {
  return switch (entitlement.plan) {
    EntitlementPlan.free => 'Free · Try Pro',
    EntitlementPlan.weekly => 'Pro · Weekly',
    EntitlementPlan.monthly => 'Pro · Monthly',
    EntitlementPlan.yearly => 'Pro · Yearly',
    EntitlementPlan.lifetime => 'Pro · Lifetime',
  };
}

SettingsEntitlementSnapshot _settingsEntitlement(Entitlement entitlement) {
  return SettingsEntitlementSnapshot(
    plan: switch (entitlement.plan) {
      EntitlementPlan.free => SettingsEntitlementPlan.free,
      EntitlementPlan.weekly => SettingsEntitlementPlan.weekly,
      EntitlementPlan.monthly => SettingsEntitlementPlan.monthly,
      EntitlementPlan.yearly => SettingsEntitlementPlan.yearly,
      EntitlementPlan.lifetime => SettingsEntitlementPlan.lifetime,
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

class _Stub extends StatelessWidget {
  const _Stub(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text('$label — placeholder')),
    );
  }
}
