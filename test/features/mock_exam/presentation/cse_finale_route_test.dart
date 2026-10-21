import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

import '../../../helpers/pump_app.dart';

void main() {
  for (final scenario in [
    (
      name: 'fresh CSE',
      fresh: true,
      exam: 'exam_cse_pro',
      extra: true,
      reason: MockSubmitReason.timeUp,
      expected: true
    ),
    (
      name: 'fresh Subprofessional',
      fresh: true,
      exam: 'exam_cse_sub',
      extra: true,
      reason: MockSubmitReason.timeUp,
      expected: true
    ),
    (
      name: 'historical CSE',
      fresh: false,
      exam: 'exam_cse_pro',
      extra: true,
      reason: MockSubmitReason.timeUp,
      expected: false
    ),
    (
      name: 'missing snapshot',
      fresh: true,
      exam: 'exam_cse_pro',
      extra: false,
      reason: MockSubmitReason.timeUp,
      expected: false
    ),
    (
      name: 'strict exit keeps static forfeit result',
      fresh: true,
      exam: 'exam_cse_pro',
      extra: true,
      reason: MockSubmitReason.strictBackground,
      expected: false
    ),
    (
      name: 'other exam remains unchanged',
      fresh: true,
      exam: 'exam_upcat',
      extra: true,
      reason: MockSubmitReason.timeUp,
      expected: false
    ),
  ]) {
    testWidgets(scenario.name, (tester) async {
      final attempt = MockAttempt(
        id: 'a',
        userId: 'local',
        examId: scenario.exam,
        blueprintId: 'cse',
        blueprintName: 'CSE Professional simulation',
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
      const result = MockResults(
        scoreRaw: 1,
        scoreTotal: 1,
        percent: 100,
        sections: [],
        topWeak: [],
        totalTimeSeconds: 100,
        wasStrict: false,
      );
      final snapshot = MockFinaleInput(
        reason: scenario.reason,
        currentPartIndex: 0,
        currentQuestionIndex: 0,
        parts: [
          MockFinalePart(
            name: 'CSE',
            questions: const [
              MockFinaleQuestion(id: 'q', outcome: MockFinaleOutcome.correct),
            ],
          ),
        ],
      );
      var refreshAccess = false;
      final accessRefresh = Completer<MockReviewAccess>();
      await tester.pumpAppWithProviders(
        MockResultsRoute(
          attemptId: 'a',
          fresh: scenario.fresh,
          finaleInput: scenario.extra ? snapshot : null,
        ),
        overrides: [
          mockResultsProvider('a').overrideWith(
            (ref) async => MockHistoryEntry(attempt: attempt, results: result),
          ),
          mockReviewAccessProvider('a').overrideWith((ref) async {
            if (refreshAccess) return accessRefresh.future;
            return const MockReviewAccess(canReview: true);
          }),
          mockEarlierResultsProvider('a').overrideWith((ref) async => []),
          entitlementProvider
              .overrideWith((ref) => Stream.value(const Entitlement.free())),
        ],
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      expect(
        find.byType(CseMockFinale),
        scenario.expected ? findsOneWidget : findsNothing,
      );
      if (scenario.expected) {
        await tester.pump(const Duration(seconds: 10));
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MockResultsRoute)),
        );
        refreshAccess = true;
        container.invalidate(mockReviewAccessProvider('a'));
        for (var i = 0; i < 3; i++) {
          await tester.pump();
        }
        expect(find.byType(CseMockFinale), findsNothing);
        accessRefresh.complete(const MockReviewAccess(canReview: true));
        for (var i = 0; i < 5; i++) {
          await tester.pump();
        }
        expect(
          find.byType(CseMockFinale),
          findsNothing,
          reason: 'An access refresh must not replay a consumed submission',
        );
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
