import 'package:flutter/material.dart' show ValueKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_review_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_session_end_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

List<RouteBase> quizRoutes(Ref ref) => [
      GoRoute(
        path: '/quiz',
        builder: (_, __) => Consumer(
          builder: (context, ref, _) {
            final focus = ref.watch(activeExamFocusProvider).valueOrNull;
            if (focus == null || focus.exam == null) {
              return const QuizTabScreen();
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
              return QuizTabScreen(mockPanel: loadingFor(availabilityState));
            }
            if (availabilityState.hasError || availability == null) {
              return QuizTabScreen(
                mockPanel: errorFor(
                  'mock',
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
              return QuizTabScreen(mockPanel: loadingFor(lastAttemptState));
            }
            if (web && lastAttemptState.hasError) {
              return QuizTabScreen(
                mockPanel: errorFor(
                  'mock',
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

            return QuizTabScreen(
              mockPanel: MockCard(
                model: MockCardModel(
                  state: ref.watch(sessionPanelProvider(examId)).valueOrNull
                          is SessionPanelInProgress
                      ? MockCardState.quizPaused
                      : switch (availability.state) {
                          MockAvailabilityState.inProgress =>
                            MockCardState.inProgress,
                          MockAvailabilityState.cooldown =>
                            MockCardState.waiting,
                          MockAvailabilityState.noBlueprint =>
                            focus.exam!.isCustom
                                ? MockCardState.customUnset
                                : MockCardState.unavailable,
                          MockAvailabilityState.available =>
                            focus.exam!.isCustom
                                ? customTrack == null
                                    ? MockCardState.customUnset
                                    : MockCardState.customReady
                                : lastAttempt == null
                                    ? MockCardState.neverTaken
                                    : MockCardState.ready,
                        },
                  name: '${focus.exam!.shortName} simulation',
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
                  freeIntervalDays: web ? 30 : 14,
                  proPaused:
                      ref.watch(entitlementProvider).valueOrNull?.state ==
                          EntitlementState.paused,
                  lastPercent: lastAttempt == null
                      ? null
                      : ref
                          .watch(mockResultsProvider(lastAttempt.id))
                          .valueOrNull
                          ?.results
                          .percent,
                  lastAttemptAt: lastAttempt?.submittedAt,
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
        path: '/quiz/viewer/:attemptId',
        builder: (_, state) => QuizReviewPage(
          key: ValueKey('quiz-viewer:${state.uri}'),
          attemptId: state.pathParameters['attemptId']!,
          initialIndex:
              int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0,
          openNotes: state.uri.queryParameters['notes'] == 'true',
          fromAll: state.uri.queryParameters['fromAll'] == 'true',
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
