// ignore_for_file: directives_ordering

import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/server_mock_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
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
            onStart: (blueprintId, {required strictMode}) {
              context.push(
                '/quiz/mock/start?examId=$examId&blueprintId=$blueprintId&strict=${strictMode ? 1 : 0}',
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
          return buildMockRunRoute(
            examId: examId,
            blueprintId: blueprintId,
            strictMode: state.uri.queryParameters['strict'] == '1',
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
            fresh: state.uri.queryParameters['fresh'] == '1',
            finaleInput: state.uri.queryParameters['fresh'] == '1' &&
                    state.extra is MockFinaleInput
                ? state.extra! as MockFinaleInput
                : null,
            endedPart: switch (int.tryParse(
              state.uri.queryParameters['endedPart'] ?? '',
            )) {
              final int part when part > 0 => part,
              _ => null
            },
            fromRecord: state.uri.queryParameters['origin'] == 'record',
          );
        },
      ),
      GoRoute(
        path: '/mock/review/:attemptId',
        builder: (_, state) => Consumer(
          builder: (_, ref, __) {
            final attemptId = state.pathParameters['attemptId']!;
            final access = ref.watch(mockReviewAccessProvider(attemptId));
            final granted = access.valueOrNull;
            if (granted == null || !granted.canReview) {
              return MockResultsRoute(
                attemptId: attemptId,
                fromRecord: true,
              );
            }
            return MockReviewPage(
              attemptId: attemptId,
              proIsActive: granted.proCovered,
            );
          },
        ),
      ),
    ];
