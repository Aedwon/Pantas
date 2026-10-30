import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/web/web_debrief_loading.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_skeletons.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

export 'package:pantas/features/mock_exam/application/decode_mock_results.dart'
    show decodeMockResults;

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
      return Scaffold(
        body: context.wideWeb
            ? const WebDebriefLoading()
            : const MockResultsSkeleton(),
      );
    }
    if (access.hasError) {
      _interruptFinale();
      return Scaffold(
        body: errorFor(
          'mock results',
          () {
            if (ref.read(mockUsesServerProvider)) {
              ref.invalidate(serverMockResultProvider(attemptId));
            }
            ref.invalidate(mockReviewAccessProvider(attemptId));
          },
          error: access.error,
        ),
      );
    }
    return entry.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      loading: () {
        _interruptFinale();
        return Scaffold(
          body: context.wideWeb
              ? const WebDebriefLoading()
              : const MockResultsSkeleton(),
        );
      },
      error: (error, stack) {
        _interruptFinale();
        return Scaffold(
          body: errorFor(
            'mock results',
            () {
              if (ref.read(mockUsesServerProvider)) {
                ref.invalidate(serverMockResultProvider(attemptId));
              }
              ref.invalidate(mockResultsProvider(attemptId));
            },
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
