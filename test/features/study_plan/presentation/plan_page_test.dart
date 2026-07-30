import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/features/study_plan/application/study_plan_providers.dart';
import 'package:pantas/features/study_plan/domain/compute_plan_view.dart';
import 'package:pantas/features/study_plan/domain/pace_curve.dart';
import 'package:pantas/features/study_plan/presentation/plan_page.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const today = TodayPlan(
    mode: TodayPlanMode.study,
    headline: 'Focus on Probability today',
    why: 'On track. Keep the rhythm with Probability.',
    reviewCount: 14,
    lessonId: 'lesson-probability',
    drillTopicId: 'probability',
    drillTopicName: 'Probability',
    ctaPath: '/quiz/today/cse?topicId=probability',
  );
  final view = PlanView(
    examId: 'cse',
    examName: 'Civil Service Exam',
    weeksToExam: 13,
    paceStatus: PaceStatus.onPace,
    today: today,
    upcoming: [
      UpcomingPlanDay(
        date: DateTime(2026, 5, 22),
        focusLabel: 'Probability',
        estimatedQuestionCount: 12,
        isRestDay: false,
      ),
      UpcomingPlanDay(
        date: DateTime(2026, 5, 23),
        focusLabel: 'Logic',
        estimatedQuestionCount: 10,
        isRestDay: false,
      ),
      UpcomingPlanDay(
        date: DateTime(2026, 5, 24),
        focusLabel: 'Rest day · recharge',
        estimatedQuestionCount: 0,
        isRestDay: true,
      ),
    ],
    usedFallbackMastery: false,
  );

  testWidgets('loading state renders faint bars', (tester) async {
    final completer = Completer<StudyPlanState>();
    await tester.pumpAppWithProviders(
      const PlanPage(),
      overrides: [
        studyPlanViewProvider.overrideWith((_) => completer.future),
      ],
    );

    expect(find.byType(FaintBars), findsOneWidget);
    completer.complete(StudyPlanReady(view));
  });

  testWidgets('missing plan prefs renders exam-date prompt', (tester) async {
    await tester.pumpAppWithProviders(
      const PlanPage(),
      overrides: [
        studyPlanViewProvider
            .overrideWith((_) async => const StudyPlanNeedsExamSelection()),
      ],
    );

    expect(find.text('Choose an exam to build your plan.'), findsOneWidget);
  });

  testWidgets('plan page CTA navigates to today quiz route', (tester) async {
    final router = GoRouter(
      initialLocation: '/plan',
      routes: [
        GoRoute(path: '/plan', builder: (_, __) => const PlanPage()),
        GoRoute(
          path: '/quiz/today/:examId',
          builder: (_, state) {
            final examId = state.pathParameters['examId'];
            final topicId = state.uri.queryParameters['topicId'];
            return Text('quiz $examId $topicId');
          },
        ),
      ],
    );

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        studyPlanViewProvider.overrideWith((_) async => StudyPlanReady(view)),
      ],
    );

    await tester.tap(find.text("Start today's session"));
    await tester.pumpAndSettle();

    expect(find.text('quiz cse probability'), findsOneWidget);
  });
}
