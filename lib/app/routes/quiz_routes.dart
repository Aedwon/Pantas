import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_panel_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_availability.dart';
import 'package:pantas/features/mock_exam/domain/mock_title.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/application/quiz_leave_guard.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_review_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_session_end_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/quiz/presentation/widgets/quiz_skeletons.dart';

List<RouteBase> quizRoutes(Ref ref, {bool isWeb = kIsWeb}) {
  // Browser Back leaves a quiz session without a pop, so the session routes
  // ask the open session first, and it shows its leave dialog (see
  // [quizLeaveGuardProvider]).
  final ExitCallback? askSession = isWeb
      ? (context, state) => ref.read(quizLeaveGuardProvider).allowLeave()
      : null;
  return [
    GoRoute(
      path: '/quiz',
      builder: (_, __) => Consumer(
        builder: (context, ref, _) {
          final focus = ref.watch(activeExamFocusProvider).valueOrNull;
          if (focus == null || focus.exam == null) {
            return const QuizTabScreen();
          }

          // The web's mocks need a named account. Without one the card asks
          // for it, and nothing is shown while the account is still unknown.
          switch (ref.watch(mockAccountGateProvider)) {
            case MockAccountGate.checking:
              return const QuizTabScreen(
                mockReady: false,
                mockPanel: QuizMockPanelSkeleton(),
              );
            case MockAccountGate.needsAccount:
              return QuizTabScreen(
                mockPanel: MockSignUpCard(
                  onCreateAccount: () => context.push('/settings/account'),
                ),
              );
            case MockAccountGate.ready:
              break;
          }

          final examId = focus.exam!.id;
          final request = MockAvailabilityRequest(
            userId: mockAttemptLocalUserId,
            examId: examId,
          );

          final availabilityState =
              ref.watch(mockAvailabilityProvider(request));
          final availability = availabilityState.valueOrNull;
          if (availabilityState.isLoading) {
            return const QuizTabScreen(
              mockReady: false,
              mockPanel: QuizMockPanelSkeleton(),
            );
          }
          if (availabilityState.hasError || availability == null) {
            return QuizTabScreen(
              mockPanel: _mockErrorFor(
                context,
                () {
                  if (ref.read(mockUsesServerProvider)) {
                    ref.invalidate(serverMockAvailabilityProvider(examId));
                  }
                  ref.invalidate(mockAvailabilityProvider(request));
                },
                error: availabilityState.error,
              ),
            );
          }
          final web = ref.watch(mockUsesServerProvider);
          final lastAttemptState =
              ref.watch(lastSubmittedMockProvider(request));
          if (web && lastAttemptState.isLoading) {
            return const QuizTabScreen(
              mockReady: false,
              mockPanel: QuizMockPanelSkeleton(),
            );
          }
          if (web && lastAttemptState.hasError) {
            return QuizTabScreen(
              mockPanel: _mockErrorFor(
                context,
                () {
                  final reply = ref
                      .read(serverMockAvailabilityProvider(examId))
                      .valueOrNull;
                  final id = reply?['lastMockId'];
                  if (id is String) {
                    ref.invalidate(serverMockResultProvider(id));
                  }
                  ref
                    ..invalidate(serverMockAvailabilityProvider(examId))
                    ..invalidate(lastSubmittedMockProvider(request));
                },
                error: lastAttemptState.error,
              ),
            );
          }
          final lastAttempt = lastAttemptState.valueOrNull;
          final serverAvailability = web
              ? ref.watch(serverMockAvailabilityProvider(examId)).valueOrNull
              : null;
          final proIsActive = web
              ? serverAvailability != null &&
                  serverAvailability['proCovered'] == true
              : ref
                      .watch(proForActiveExamProvider)
                      .unwrapPrevious()
                      .asData
                      ?.value ??
                  false;

          final customTrack = focus.exam!.isCustom
              ? ref.watch(customMockSummaryProvider(examId)).valueOrNull
              : null;
          // The server has no paper for a custom exam this browser holds one
          // for. Its settings go up again once, and until they land the saved
          // paper stays on screen.
          final repairing = web &&
              customTrack != null &&
              availability.state == MockAvailabilityState.noBlueprint;
          if (repairing) ref.watch(customMockRepairProvider(examId));

          return QuizTabScreen(
            mockPanel: MockCard(
              model: MockCardModel(
                state: ref.watch(sessionPanelProvider(examId)).valueOrNull
                        is SessionPanelInProgress
                    ? MockCardState.quizPaused
                    : switch (availability.state) {
                        MockAvailabilityState.inProgress =>
                          MockCardState.inProgress,
                        MockAvailabilityState.cooldown => MockCardState.waiting,
                        MockAvailabilityState.noBlueprint =>
                          focus.exam!.isCustom
                              ? repairing
                                  ? MockCardState.customReady
                                  : MockCardState.customUnset
                              : MockCardState.unavailable,
                        MockAvailabilityState.available => focus.exam!.isCustom
                            ? customTrack == null
                                ? MockCardState.customUnset
                                : MockCardState.customReady
                            : lastAttempt == null
                                ? MockCardState.neverTaken
                                : MockCardState.ready,
                      },
                name: mockSimulationTitle(examId, focus.exam!.shortName),
                durationMinutes: customTrack?.minutes ??
                    lastAttempt?.durationMinutes ??
                    ref
                        .watch(mockBlueprintsForExamProvider(examId))
                        .valueOrNull
                        ?.blueprints
                        .firstOrNull
                        ?.blueprint
                        .durationMinutes,
                pro: proIsActive,
                freeIntervalDays: web ? freeMockIntervalDaysWeb : 14,
                proPaused: ref.watch(entitlementProvider).valueOrNull?.state ==
                    EntitlementState.paused,
                lastPercent: lastAttempt == null
                    ? null
                    : ref
                        .watch(mockResultsProvider(lastAttempt.id))
                        .valueOrNull
                        ?.results
                        .percent,
                lastAttemptAt: lastAttempt?.submittedAt?.toLocal(),
                nextOpensAt: web
                    ? availability.nextOpensAt?.toLocal()
                    : lastAttempt?.submittedAt?.add(const Duration(days: 14)),
                customQuestions: customTrack?.questions,
              ),
              onSetUp: () => context.push('/quiz/mock/custom-setup'),
              onChangeSetup: () => context.push('/quiz/mock/custom-setup'),
              onTake: () {
                if (web) ref.invalidate(serverMockSetupCountProvider(examId));
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
                final serverId = availability.serverMockId;
                if (web && serverId != null) {
                  context.push('/quiz/mock/resume/$serverId');
                  return;
                }
                final activeAttempt = availability.activeAttempt;
                if (activeAttempt != null) {
                  context.push(
                    '/quiz/mock/resume/${activeAttempt.id}',
                  );
                }
              },
              onViewResults: lastAttempt == null
                  ? null
                  : () => context.push('/mock/results/${lastAttempt.id}'),
            ),
          );
        },
      ),
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
      onExit: askSession,
    ),
    GoRoute(
      path: '/quiz/resume/:examId',
      builder: (_, state) => QuizPage(
        examId: state.pathParameters['examId']!,
        mode: QuizPageMode.resume,
      ),
      onExit: askSession,
    ),
    GoRoute(
      path: '/quiz/quick/:examId',
      builder: (_, state) => QuizPage(
        examId: state.pathParameters['examId']!,
        topicId: state.uri.queryParameters['topicId'],
      ),
      onExit: askSession,
    ),
    GoRoute(
      path: '/quiz/practice/:examId',
      builder: (_, state) => PracticePickerScreen(
        examId: state.pathParameters['examId']!,
      ),
    ),
    GoRoute(
      path: '/quiz/practice/:examId/run',
      builder: (_, state) => QuizPage(
        examId: state.pathParameters['examId']!,
        mode: QuizPageMode.practice,
        customSessionId: state.extra is ({String customSessionId})
            ? (state.extra! as ({String customSessionId})).customSessionId
            : null,
      ),
      onExit: askSession,
    ),
    GoRoute(
      path: '/quiz/retake/:examId',
      builder: (_, state) => QuizPage(
        examId: state.pathParameters['examId']!,
        mode: QuizPageMode.retake,
      ),
      onExit: askSession,
    ),
    GoRoute(
      path: '/quiz/inline/:examId/:lessonId',
      builder: (_, state) => QuizPage(
        examId: state.pathParameters['examId']!,
        lessonId: state.pathParameters['lessonId'],
        mode: QuizPageMode.inline,
      ),
      onExit: askSession,
    ),
    GoRoute(
      path: '/quiz/viewer/:attemptId',
      builder: (_, state) => QuizReviewPage(
        key: ValueKey('quiz-viewer:${state.uri}'),
        attemptId: state.pathParameters['attemptId']!,
        initialIndex:
            int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0,
        openNotes: state.uri.queryParameters['notes'] == 'true',
        fromAll: state.uri.queryParameters['fromAll'] == 'true',
        mistakesOnly: state.uri.queryParameters['mistakes'] == 'true',
      ),
    ),
    GoRoute(
      path: '/quiz/flagged/:examId/view/:questionId',
      builder: (_, state) => FlaggedQuestionViewerPage(
        examId: state.pathParameters['examId']!,
        questionId: state.pathParameters['questionId']!,
      ),
    ),
    GoRoute(
      path: '/quiz/all/:attemptId',
      builder: (_, state) => QuizSessionEndPage(
        key: ValueKey('quiz-completed:${state.uri}'),
        attemptId: state.pathParameters['attemptId']!,
        all: true,
        mistakesOnly: state.uri.queryParameters['mistakes'] == 'true',
      ),
    ),
    GoRoute(
      path: '/quiz/debrief/:attemptId',
      builder: (_, state) => QuizSessionEndPage(
        key: ValueKey('quiz-completed:${state.uri}'),
        attemptId: state.pathParameters['attemptId']!,
      ),
    ),
    GoRoute(
      path: '/quiz/flagged/:examId',
      builder: (_, state) => Consumer(
        builder: (_, ref, __) => FlaggedListPage(
          examId: state.pathParameters['examId']!,
          proIsActive: ref
                  .watch(proForActiveExamProvider)
                  .unwrapPrevious()
                  .asData
                  ?.value ??
              false,
        ),
      ),
    ),
  ];
}

Widget _mockErrorFor(
  BuildContext context,
  VoidCallback onRetry, {
  Object? error,
}) {
  final panel = errorFor('mock', onRetry, error: error);
  if (!context.wideWeb) return panel;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const WebText('Mock exam', kind: WebTextKind.eyebrow),
      panel,
    ],
  );
}
