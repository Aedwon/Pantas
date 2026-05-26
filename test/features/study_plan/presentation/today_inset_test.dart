import 'package:cse_cet_reviewer/features/study_plan/domain/compute_plan_view.dart';
import 'package:cse_cet_reviewer/features/study_plan/presentation/today_inset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const plan = TodayPlan(
    mode: TodayPlanMode.study,
    headline: 'Focus on Probability today',
    why: 'On track. Keep the rhythm with Probability.',
    reviewCount: 14,
    lessonId: 'lesson-probability',
    drillTopicId: 'probability',
    drillTopicName: 'Probability',
    ctaPath: '/quiz/today/cse?topicId=probability',
  );

  testWidgets('today inset renders exactly one primary CTA', (tester) async {
    await tester.pumpApp(TodayInset(plan: plan, onStart: () {}));

    expect(find.text("Start today's session"), findsOneWidget);
    expect(find.byType(GestureDetector), findsOneWidget);
  });

  testWidgets(
      'today inset shows review lesson and drill counts as read-only breakdown',
      (tester) async {
    await tester.pumpApp(TodayInset(plan: plan, onStart: () {}));

    expect(find.text('14 reviews'), findsOneWidget);
    expect(find.text('1 lesson'), findsOneWidget);
    expect(find.text('Probability drill'), findsOneWidget);
  });
}
