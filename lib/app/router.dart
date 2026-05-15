import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
import 'package:cse_cet_reviewer/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const _TabStub('Home'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (_, __) => const LearnTabHome(),
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
                path: '/more',
                builder: (_, __) => const _TabStub('More'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const _Stub('Onboarding'),
      ),
      GoRoute(
        path: '/quiz',
        builder: (_, __) => const QuizTabHome(),
        routes: [
          GoRoute(
            path: 'quick/:examId',
            builder: (_, state) =>
                QuizPage(examId: state.pathParameters['examId']!),
          ),
          GoRoute(
            path: 'results/:attemptId',
            builder: (_, state) =>
                QuizResultsPage(attemptId: state.pathParameters['attemptId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (_, state) => LessonPage(
          lessonId: state.pathParameters['lessonId']!,
          examId: state.uri.queryParameters['examId'],
        ),
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
