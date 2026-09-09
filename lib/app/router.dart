// ignore_for_file: directives_ordering

import 'package:pantas/app/build_info.dart';
import 'package:pantas/app/router_refresh_listenable.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/features/shell/presentation/update_required_page.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/reader_transition.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/assessment/assessment.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/pages/topic_ending_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_route.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/notifications/presentation/permission_rationale_page.dart';
import 'package:pantas/features/onboarding/onboarding.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/progress/presentation/pages/how_you_work_page.dart';
import 'package:pantas/features/progress/presentation/pages/your_record_page.dart';
import 'package:pantas/features/progress/presentation/progress_page.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/presentation/pages/debrief_page.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:pantas/features/quiz/presentation/pages/practice_picker_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_results_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_home.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
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
import 'package:pantas/features/study_plan/presentation/plan_page.dart';
import 'package:pantas/features/wrapped/presentation/wrapped_reveal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref, [
    passedAgeGateProvider,
    onboardingCompleteProvider,
    activeExamFocusProvider,
    entitlementProvider,
    notificationRationaleShownProvider,
  ]);
  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      // The stop comes first: a build the server has retired must not
      // reach any route, including a deep link.
      final flags = ref.read(remoteFlagsProvider);
      final blocked = updateIsRequired(
        currentBuild: kBuildNumber,
        minimumSupportedBuild: flags.minimumSupportedBuild,
      );
      final atUpdateRequired = state.matchedLocation == '/update-required';
      if (blocked && !atUpdateRequired) return '/update-required';
      if (!blocked && atUpdateRequired) return '/home';

      final passedAsync = ref.read(passedAgeGateProvider);
      final focusAsync = ref.read(activeExamFocusProvider);
      final completeAsync = ref.read(onboardingCompleteProvider);
      final passed = passedAsync.valueOrNull;
      final focus = focusAsync.valueOrNull;
      final complete = completeAsync.valueOrNull;
      if (passed == null || focus == null || complete == null) return null;
      final atOnboarding = state.matchedLocation == '/onboarding';
      final atNotificationRationale =
          state.matchedLocation == '/notifications/rationale';
      final atPaywall = state.matchedLocation == '/paywall';
      if (!passed && !atOnboarding) return '/onboarding';
      if (passed && !complete && !atOnboarding) return '/onboarding';
      if (passed && complete && atOnboarding) {
        final rationaleShown =
            ref.read(notificationRationaleShownProvider).valueOrNull;
        if (rationaleShown == false) return '/notifications/rationale';
        return '/home';
      }
      if (passed && complete && atNotificationRationale) {
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
    routes: buildAppRoutes(ref),
  );
  ref.onDispose(router.dispose);
  return router;
});

List<RouteBase> buildAppRoutes(Ref ref) {
  return [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/study',
              builder: (_, state) => StudyTabHome(
                openTopicId: state.uri.queryParameters['topicId'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/quiz',
              builder: (_, __) => Consumer(
                builder: (context, ref, _) {
                  final focus = ref.watch(activeExamFocusProvider).valueOrNull;
                  if (focus == null || focus.exam == null) {
                    return const QuizTabHome();
                  }

                  final examId = focus.exam!.id;
                  final request = MockAvailabilityRequest(
                    userId: mockAttemptLocalUserId,
                    examId: examId,
                  );

                  final availability =
                      ref.watch(mockAvailabilityProvider(request)).valueOrNull;
                  if (availability == null) {
                    return const QuizTabHome();
                  }

                  final lastAttempt =
                      ref.watch(lastSubmittedMockProvider(request)).valueOrNull;
                  final proIsActive =
                      ref.watch(entitlementProvider).valueOrNull?.proIsActive ??
                          false;

                  final customTrack = focus.exam!.isCustom
                      ? ref.watch(customMockSummaryProvider(examId)).valueOrNull
                      : null;

                  return QuizTabHome(
                    mockPanel: MockPanel(
                      availability: availability,
                      lastAttempt: lastAttempt,
                      proIsActive: proIsActive,
                      customTrack: customTrack,
                      onSetUpCustom: focus.exam!.isCustom
                          ? () => context.push('/quiz/mock/custom-setup')
                          : null,
                      onChangeCustomSetup: focus.exam!.isCustom
                          ? () => context.push('/quiz/mock/custom-setup')
                          : null,
                      onTake: () {
                        if (focus.exam!.isCustom) {
                          if (customTrack != null) {
                            context.push('/quiz/mock/setup?examId=$examId');
                          } else {
                            context.push('/quiz/mock/custom-setup');
                          }
                        } else {
                          context.push('/quiz/mock/setup?examId=$examId');
                        }
                      },
                      onResume: () {
                        final activeAttempt = availability.activeAttempt;
                        if (activeAttempt != null) {
                          context.push(
                            '/quiz/mock/resume/${activeAttempt.id}',
                          );
                        }
                      },
                      onViewResults: () {
                        if (lastAttempt != null) {
                          context.push('/mock/results/${lastAttempt.id}');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (_, __) => const ProgressPage(),
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
      path: '/onboarding/custom/name',
      builder: (_, __) => const CustomTrackNameStep(),
    ),
    GoRoute(
      path: '/onboarding/custom/subjects',
      builder: (_, state) => CustomTrackSubjectsStep(
        name: state.uri.queryParameters['name'] ?? '',
      ),
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
      path: '/progress/how-you-work',
      builder: (_, __) => const HowYouWorkPage(),
    ),
    GoRoute(
      path: '/progress/your-record',
      builder: (_, __) => const YourRecordPage(),
    ),
    GoRoute(
      path: '/quiz/today/:examId',
      builder: (_, state) => QuizPage(
        examId: state.pathParameters['examId']!,
        mode: QuizPageMode.today,
        topicId: state.uri.queryParameters['topicId'],
        prepared: state.extra is PreparedTodaySession
            ? state.extra! as PreparedTodaySession
            : null,
      ),
    ),
    GoRoute(
      path: '/quiz/resume/:examId',
      builder: (_, state) => QuizPage(
        examId: state.pathParameters['examId']!,
        mode: QuizPageMode.resume,
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
      path: '/quiz/practice/:examId',
      builder: (_, state) => PracticePickerPage(
        examId: state.pathParameters['examId']!,
      ),
    ),
    GoRoute(
      path: '/quiz/practice/:examId/run',
      builder: (_, state) => QuizPage(
        examId: state.pathParameters['examId']!,
        mode: QuizPageMode.practice,
      ),
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
      path: '/quiz/debrief/:attemptId',
      builder: (_, state) =>
          DebriefPage(attemptId: state.pathParameters['attemptId']!),
    ),
    GoRoute(
      path: '/quiz/flagged/:examId',
      builder: (_, state) {
        final examId = state.pathParameters['examId']!;
        final proIsActive =
            ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false;
        return FlaggedListPage(
          examId: examId,
          proIsActive: proIsActive,
        );
      },
    ),
    GoRoute(
      path: '/quiz/results/:attemptId',
      builder: (_, state) =>
          QuizResultsPage(attemptId: state.pathParameters['attemptId']!),
    ),
    GoRoute(
      path: '/quiz/mock/setup',
      builder: (context, state) {
        final examId = state.uri.queryParameters['examId'] ?? '';
        return MockSetupRoute(
          examId: examId,
          onStart: (blueprintId) {
            context.push(
              '/quiz/mock/start?examId=$examId&blueprintId=$blueprintId',
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/quiz/mock/start',
      builder: (_, state) {
        final examId = state.uri.queryParameters['examId']!;
        final blueprintId = state.uri.queryParameters['blueprintId']!;
        return MockStartRoute(
          examId: examId,
          blueprintId: blueprintId,
        );
      },
    ),
    GoRoute(
      path: '/quiz/mock/resume/:attemptId',
      builder: (_, state) => MockStartRoute.resume(
        resumeAttemptId: state.pathParameters['attemptId'],
      ),
    ),
    GoRoute(
      path: '/quiz/mock/custom-setup',
      builder: (_, __) => const CustomMockSetupRoute(),
    ),
    GoRoute(
      path: '/lesson/:lessonId',
      pageBuilder: (_, state) => readerPage(
        key: state.pageKey,
        entry: state.uri.queryParameters['via'] == 'pull'
            ? ReaderEntry.advance
            : ReaderEntry.forward,
        child: LessonPage(
          lessonId: state.pathParameters['lessonId']!,
          origin: state.uri.queryParameters['from'] == 'home'
              ? ReaderOrigin.home
              : ReaderOrigin.study,
        ),
      ),
    ),
    GoRoute(
      path: '/study/ending/:topicId',
      builder: (_, state) => TopicEndingPage(
        topicId: state.pathParameters['topicId']!,
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
      builder: (_, state) {
        final attemptId = state.uri.queryParameters['attemptId'] ?? '';
        final proIsActive =
            ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false;
        return QuizResultsPage(
          attemptId: attemptId,
          proIsActive: proIsActive,
        );
      },
    ),
    GoRoute(
      path: '/mock/results/:attemptId',
      builder: (_, state) {
        return MockResultsRoute(
          attemptId: state.pathParameters['attemptId']!,
        );
      },
    ),
    GoRoute(
      path: '/mock/review/:attemptId',
      builder: (_, state) {
        final attemptId = state.pathParameters['attemptId']!;
        final proIsActive =
            ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false;
        return MockReviewPage(
          attemptId: attemptId,
          proIsActive: proIsActive,
        );
      },
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
        final isAnonymous = ref.watch(isAnonymousProvider).valueOrNull ?? false;
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
      path: '/update-required',
      builder: (_, __) => const UpdateRequiredPage(),
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
}

class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Flattens the router's declared paths. Exists so a test can assert that
/// every Settings row has somewhere to land.
List<String> collectRoutePaths() {
  final paths = <String>[];
  void visit(List<RouteBase> routes) {
    for (final route in routes) {
      if (route is GoRoute) paths.add(route.path);
      visit(route.routes);
    }
  }

  visit(buildAppRoutes(_FakeRef()));
  return paths;
}

bool _isProRoute(String matchedLocation) {
  return matchedLocation.startsWith('/plan/dossier/');
}

SettingsEntitlementSnapshot _settingsEntitlement(Entitlement entitlement) {
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

class _Stub extends StatelessWidget {
  const _Stub(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text('$label: placeholder')),
    );
  }
}
