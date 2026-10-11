// ignore_for_file: directives_ordering

import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_route.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> mockRoutes(Ref ref) => [
      GoRoute(path: '/mock-exam', redirect: (_, __) => '/home'),
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
        path: '/mock/results/:attemptId',
        builder: (_, state) {
          return MockResultsRoute(
            attemptId: state.pathParameters['attemptId']!,
          );
        },
      ),
      GoRoute(
        path: '/mock/review/:attemptId',
        builder: (_, state) => Consumer(
          builder: (_, ref, __) => MockReviewPage(
            attemptId: state.pathParameters['attemptId']!,
            proIsActive:
                ref.watch(proForActiveExamProvider).valueOrNull ?? false,
          ),
        ),
      ),
    ];
