import 'package:cse_cet_reviewer/app/router_refresh_listenable.dart';
import 'package:cse_cet_reviewer/core/storage/age_gate.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/features/assessment/assessment.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:cse_cet_reviewer/features/onboarding/onboarding.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/drill_subtopic_browser.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
import 'package:cse_cet_reviewer/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref, [
    passedAgeGateProvider,
    activeExamFocusProvider,
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
      final needsSelection = focus.needsSelection;
      if (!passed && !atOnboarding) return '/onboarding';
      if (passed && needsSelection && !atOnboarding) return '/onboarding';
      if (passed && !needsSelection && atOnboarding) return '/home';
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
                path: '/more',
                builder: (_, __) => const _TabStub('More'),
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
        path: '/progress',
        builder: (_, __) => const _Stub('Progress'),
      ),
      GoRoute(
        path: '/paywall',
        builder: (_, __) => const _Stub('Paywall'),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const _Stub('Settings'),
      ),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, state) => _Stub('Legal: ${state.pathParameters['doc']}'),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _TabStub extends StatelessWidget {
  const _TabStub(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$label — placeholder')),
    );
  }
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
