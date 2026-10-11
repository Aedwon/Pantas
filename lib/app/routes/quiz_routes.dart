// ignore_for_file: directives_ordering

import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/presentation/pages/debrief_page.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:pantas/features/quiz/presentation/pages/practice_picker_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> quizRoutes(Ref ref) => [
      GoRoute(
        path: '/quiz',
        builder: (_, __) => Consumer(
          builder: (context, ref, _) {
            final focus = ref.watch(activeExamFocusProvider).valueOrNull;
            if (focus == null || focus.exam == null) {
              return const QuizTabHome();
            }

            final examId = focus.exam!.id;
            final request = MockAvailabilityRequest(
              userId: mockAttemptLocalUserId,
              examId: examId,
            );

            final availability =
                ref.watch(mockAvailabilityProvider(request)).valueOrNull;
            if (availability == null) {
              return const QuizTabHome();
            }

            final lastAttempt =
                ref.watch(lastSubmittedMockProvider(request)).valueOrNull;
            final proIsActive =
                ref.watch(entitlementProvider).valueOrNull?.proIsActive ??
                    false;

            final customTrack = focus.exam!.isCustom
                ? ref.watch(customMockSummaryProvider(examId)).valueOrNull
                : null;

            return QuizTabHome(
              mockPanel: MockPanel(
                availability: availability,
                lastAttempt: lastAttempt,
                proIsActive: proIsActive,
                customTrack: customTrack,
                onSetUpCustom: focus.exam!.isCustom
                    ? () => context.push('/quiz/mock/custom-setup')
                    : null,
                onChangeCustomSetup: focus.exam!.isCustom
                    ? () => context.push('/quiz/mock/custom-setup')
                    : null,
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
        builder: (_, state) => PracticePickerPage(
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
        builder: (_, state) {
          final examId = state.pathParameters['examId']!;
          final proIsActive =
              ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false;
          return FlaggedListPage(
            examId: examId,
            proIsActive: proIsActive,
          );
        },
      ),
      GoRoute(path: '/quiz/results/:attemptId', redirect: (_, __) => '/quiz'),
      GoRoute(path: '/review', redirect: (_, __) => '/quiz'),
    ];
