import 'package:cse_cet_reviewer/features/study_plan/domain/compute_plan_view.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/pace_curve.dart';
import 'package:cse_cet_reviewer/features/study_plan/presentation/home_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

  testWidgets('home plan card shows weeks to exam and pace status',
      (tester) async {
    await tester.pumpApp(
      const HomePlanCard(
        view: PlanView(
          examId: 'cse',
          examName: 'Civil Service Exam',
          weeksToExam: 13,
          paceStatus: PaceStatus.onPace,
          today: today,
          upcoming: [],
          usedFallbackMastery: false,
        ),
      ),
    );

    expect(find.text('13 weeks to exam · On pace'), findsOneWidget);
    expect(find.text('Focus on Probability today'), findsOneWidget);
  });

  testWidgets('home plan card opens /plan', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const HomePlanCard(
            view: PlanView(
              examId: 'cse',
              examName: 'Civil Service Exam',
              weeksToExam: 13,
              paceStatus: PaceStatus.onPace,
              today: today,
              upcoming: [],
              usedFallbackMastery: false,
            ),
          ),
        ),
        GoRoute(path: '/plan', builder: (_, __) => const Text('plan route')),
      ],
    );

    await tester.pumpAppWithRouter(router);
    await tester.tap(find.text('See plan'));
    await tester.pumpAndSettle();

    expect(find.text('plan route'), findsOneWidget);
  });
}
