import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

MockAttempt _attempt() => MockAttempt(
      id: 'a',
      userId: 'local',
      examId: 'exam_upcat',
      blueprintId: 'b',
      blueprintName: 'UPCAT',
      durationMinutes: 180,
      status: MockAttemptStatus.completed,
      strictMode: false,
      sampledQuestionsJson: '[]',
      elapsedSeconds: 100,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{}',
      flagsJson: '[]',
      currentIndex: 0,
      startedAt: DateTime.utc(2026, 10, 21),
      lastFlushedAt: DateTime.utc(2026, 10, 21),
      updatedAt: DateTime.utc(2026, 10, 21),
      submittedAt: DateTime.utc(2026, 10, 21),
    );

const _results = MockResults(
  scoreRaw: 1,
  scoreTotal: 1,
  percent: 100,
  sections: [],
  topWeak: [],
  totalTimeSeconds: 100,
  wasStrict: false,
);

void main() {
  // A mock opens its results from its run, which replaced the page it started
  // from, so the setup page is still underneath. Done must not land on it.
  for (final scenario in [
    (
      name: 'a mock just submitted',
      open: 'replace',
      query: '?fresh=1',
      expected: 'quiz tab',
    ),
    (
      name: 'a past result opened from another page',
      open: 'push',
      query: '',
      expected: 'other page',
    ),
  ]) {
    testWidgets('Done after ${scenario.name} goes to ${scenario.expected}',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/quiz',
        routes: [
          GoRoute(path: '/quiz', builder: (_, __) => const Text('quiz tab')),
          GoRoute(path: '/setup', builder: (_, __) => const Text('setup')),
          GoRoute(path: '/run', builder: (_, __) => const Text('run')),
          GoRoute(
            path: '/other',
            builder: (_, __) => const Text('other page'),
          ),
          GoRoute(
            path: '/mock/results/:id',
            builder: (_, state) => MockResultsRoute(
              attemptId: state.pathParameters['id']!,
              fresh: state.uri.queryParameters['fresh'] == '1',
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockResultsProvider('a').overrideWith(
              (ref) async =>
                  MockHistoryEntry(attempt: _attempt(), results: _results),
            ),
            mockReviewAccessProvider('a').overrideWith(
              (ref) async => const MockReviewAccess(canReview: true),
            ),
            mockEarlierResultsProvider('a').overrideWith((ref) async => []),
            entitlementProvider
                .overrideWith((ref) => Stream.value(const Entitlement.free())),
          ],
          child: MaterialApp.router(
            theme: buildLightTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final results = '/mock/results/a${scenario.query}';
      if (scenario.open == 'replace') {
        // Quiz tab, then setup, then the run, which the results replace.
        unawaited(router.push<void>('/setup'));
        await tester.pumpAndSettle();
        unawaited(router.push<void>('/run'));
        await tester.pumpAndSettle();
        unawaited(router.pushReplacement<void>(results));
      } else {
        unawaited(router.push<void>('/other'));
        await tester.pumpAndSettle();
        unawaited(router.push<void>(results));
      }
      await tester.pumpAndSettle();
      expect(find.byType(MockResultsRoute), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text(scenario.expected), findsOneWidget);
    });
  }
}
