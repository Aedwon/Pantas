// ignore_for_file: directives_ordering

import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/presentation/pages/debrief_page.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

            final availability =
                ref.watch(mockAvailabilityProvider(request)).valueOrNull;
            if (availability == null) {
              return const QuizTabScreen();
            }

            final lastAttempt =
                ref.watch(lastSubmittedMockProvider(request)).valueOrNull;
            final proIsActive =
                ref.watch(proForActiveExamProvider).valueOrNull ?? false;

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
                  nextOpensAt:
                      lastAttempt?.submittedAt?.add(const Duration(days: 14)),
                  customQuestions: customTrack?.questions,
                ),
                onSetUp: () => context.push('/quiz/mock/custom-setup'),
                onChangeSetup: () => context.push('/quiz/mock/custom-setup'),
                onTake: () {
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
                  final activeAttempt = availability.activeAttempt;
                  if (activeAttempt != null) {
                    context.push(
                      '/quiz/mock/resume/${activeAttempt.id}',
                    );
                  }
                },
                onViewResults: () {
                  if (lastAttempt != null) {
                    context.push('/mock/results/${lastAttempt.id}');
                  }
                },
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
        path: '/quiz/debrief/:attemptId',
        builder: (_, state) =>
            DebriefPage(attemptId: state.pathParameters['attemptId']!),
      ),
      GoRoute(
        path: '/quiz/flagged/:examId',
        builder: (_, state) => Consumer(
          builder: (_, ref, __) => FlaggedListPage(
            examId: state.pathParameters['examId']!,
            proIsActive:
                ref.watch(proForActiveExamProvider).valueOrNull ?? false,
          ),
        ),
      ),
      GoRoute(path: '/quiz/results/:attemptId', redirect: (_, __) => '/quiz'),
      GoRoute(path: '/review', redirect: (_, __) => '/quiz'),
    ];
