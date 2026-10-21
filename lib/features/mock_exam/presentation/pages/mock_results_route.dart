import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

class MockResultsRoute extends ConsumerStatefulWidget {
  const MockResultsRoute({
    required this.attemptId,
    this.fresh = false,
    this.finaleInput,
    this.endedPart,
    this.fromRecord = false,
    super.key,
  });

  final String attemptId;
  final bool fresh;
  final MockFinaleInput? finaleInput;
  final int? endedPart;
  final bool fromRecord;

  @override
  ConsumerState<MockResultsRoute> createState() => _MockResultsRouteState();
}

class _MockResultsRouteState extends ConsumerState<MockResultsRoute> {
  var _finaleStarted = false;
  var _finaleInterrupted = false;

  @override
  void didUpdateWidget(MockResultsRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attemptId != widget.attemptId) {
      _finaleStarted = false;
      _finaleInterrupted = false;
    }
  }

  void _interruptFinale() {
    if (_finaleStarted) _finaleInterrupted = true;
  }

  @override
  Widget build(BuildContext context) {
    final attemptId = widget.attemptId;
    final fresh = widget.fresh;
    final finaleInput = widget.finaleInput;
    final endedPart = widget.endedPart;
    final fromRecord = widget.fromRecord;
    final entry = ref.watch(mockResultsProvider(attemptId));
    final access = ref.watch(mockReviewAccessProvider(attemptId));
    final earlier = ref.watch(mockEarlierResultsProvider(attemptId));
    final paused = ref.watch(entitlementProvider).valueOrNull?.state ==
        EntitlementState.paused;
    if (access.isLoading) {
      _interruptFinale();
      return Scaffold(body: loadingFor(access));
    }
    if (access.hasError) {
      _interruptFinale();
      return Scaffold(
        body: errorFor(
          'mock results',
          () => ref.invalidate(mockReviewAccessProvider(attemptId)),
          error: access.error,
        ),
      );
    }
    return entry.when(
      loading: () {
        _interruptFinale();
        return Scaffold(body: loadingFor(entry));
      },
      error: (error, stack) {
        _interruptFinale();
        return Scaffold(
          body: errorFor(
            'mock results',
            () => ref.invalidate(mockResultsProvider(attemptId)),
            error: error,
          ),
        );
      },
      data: (entry) {
        if (entry == null) {
          _interruptFinale();
          return const Scaffold(
            body: Center(child: Text('Results not available')),
          );
        }
        final attempt = entry.attempt;
        Widget page(Animation<double>? clock) => MockResultsPage(
              finaleClock: clock,
              disableAnimations: _finaleStarted && clock == null,
              results: entry.results,
              proIsActive: access.valueOrNull?.proCovered ?? false,
              examId: attempt.examId,
              canReview: access.valueOrNull?.canReview ?? false,
              reviewUntil: access.valueOrNull?.reviewUntil?.toLocal(),
              proPaused: paused,
              fromRecord: fromRecord,
              forfeitedPart: endedPart,
              onDone: () => context.pop(),
              onSeePro: () => context.push('/settings/pro'),
              pastResults: [
                for (final previous
                    in earlier.valueOrNull ?? <MockHistoryEntry>[])
                  MockPastPoint(
                    percent: previous.results.percent,
                    label: PantasDates.short(
                      previous.attempt.submittedAt!.toLocal(),
                    ),
                  ),
              ],
              blueprintName: attempt.blueprintName,
              dateFormatted: PantasDates.heading(attempt.startedAt.toLocal()),
              forfeited: attempt.status == MockAttemptStatus.forfeited,
              onReviewTap: () => context.push('/mock/review/$attemptId'),
            );
        final input = finaleInput;
        if (!_finaleInterrupted &&
            fresh &&
            !fromRecord &&
            input != null &&
            input.reason != MockSubmitReason.strictBackground &&
            attempt.status == MockAttemptStatus.completed &&
            (attempt.examId == 'exam_cse_pro' ||
                attempt.examId == 'exam_cse_sub')) {
          final questions = [for (final part in input.parts) ...part.questions];
          final correct = questions
              .where((q) => q.outcome == MockFinaleOutcome.correct)
              .length;
          if (questions.isNotEmpty &&
              questions.length == entry.results.scoreTotal &&
              correct == entry.results.scoreRaw) {
            _finaleStarted = true;
            return CseMockFinale(
              key: ValueKey('cse-finale-$attemptId'),
              input: input,
              blueprintName: attempt.blueprintName,
              dateFormatted: PantasDates.heading(attempt.startedAt.toLocal()),
              resultsBuilder: (context, clock) => page(clock),
            );
          }
        }
        _interruptFinale();
        return page(null);
      },
    );
  }
}

/// The single section-result decoder, also used by the history contract.
/// Legacy counts come from the saved selections, never a guessed split.
MockResults? decodeMockResults(
  MockAttempt attempt, {
  Set<String>? activeQuestionIds,
}) {
  final raw = attempt.sectionResultsJson;
  if (raw == null) return null;
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final sample = jsonDecode(attempt.sampledQuestionsJson) as List<dynamic>;
  final answers = jsonDecode(attempt.answersJson) as Map<String, dynamic>;
  final sections = <SectionResult>[];
  for (final value in decoded['sections'] as List<dynamic>? ?? []) {
    final map = value as Map<String, dynamic>;
    final id = map['sectionId'] as String;
    final correct = map['correct'] as int;
    final total = map['total'] as int;
    var wrong = map['wrong'] as int?;
    var blank = map['blank'] as int?;
    if (wrong == null || blank == null) {
      var answered = 0;
      for (final value in sample) {
        final part = value as Map<String, dynamic>;
        if (part['sectionId'] != id) continue;
        for (final questionId in part['questionIds'] as List<dynamic>) {
          if (activeQuestionIds != null &&
              !activeQuestionIds.contains(questionId)) {
            continue;
          }
          final answer = answers[questionId] as Map<String, dynamic>?;
          if (answer != null && (answer['selectedIndex'] as int) >= 0) {
            answered++;
          }
        }
      }
      wrong ??= answered - correct;
      blank ??= total - answered;
      if (wrong < 0 || blank < 0) {
        throw const FormatException('Saved counts do not match the answers');
      }
    }
    sections.add(
      SectionResult(
        sectionId: id,
        name: map['name'] as String,
        correct: correct,
        total: total,
        wrong: wrong,
        blank: blank,
        retiredCount: map['retiredCount'] as int,
        timeSeconds: map['timeSeconds'] as int,
      ),
    );
  }
  return MockResults(
    scoreRaw: sections.fold(0, (sum, section) => sum + section.correct),
    scoreTotal: sections.fold(0, (sum, section) => sum + section.total),
    percent: mockScorePercent(examId: attempt.examId, sections: sections),
    sections: List.unmodifiable(sections),
    topWeak: [
      for (final value in decoded['topWeak'] as List<dynamic>? ?? [])
        WeakTopic(
          topicId: (value as Map<String, dynamic>)['topicId'] as String,
          correct: value['correct'] as int,
          total: value['total'] as int,
        ),
    ],
    totalTimeSeconds: attempt.totalTimeSeconds ?? attempt.elapsedSeconds,
    wasStrict: attempt.strictMode,
  );
}
