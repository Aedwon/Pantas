import 'dart:ui' show SemanticsAction;

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/study_plan/domain/compute_plan_view.dart';
import 'package:pantas/features/study_plan/presentation/mock_week_card.dart';
import 'package:pantas/features/study_plan/presentation/plan_updated_chip.dart';
import 'package:pantas/features/study_plan/presentation/upcoming_day_chip.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('upcoming day chips do not expose buttons', (tester) async {
    await tester.pumpApp(
      UpcomingDayChip(
        day: UpcomingPlanDay(
          date: DateTime(2026, 5, 22),
          focusLabel: 'Probability',
          estimatedQuestionCount: 12,
          isRestDay: false,
        ),
      ),
    );

    expect(find.text('Probability'), findsOneWidget);
    expect(find.text('12 questions'), findsOneWidget);
    expect(find.textContaining('Start'), findsNothing);
  });

  testWidgets('mock week card is preview only before mock week',
      (tester) async {
    await tester.pumpApp(
      const MockWeekCard(
        preview: MockWeekPreview(
          title: 'Mock week is close',
          description: 'Keep this week steady.',
        ),
      ),
    );

    expect(find.text('Mock week is close'), findsOneWidget);
    expect(find.textContaining('Start'), findsNothing);
  });

  testWidgets('plan updated chip can be dismissed', (tester) async {
    var dismissed = false;
    await tester.pumpApp(
      PlanUpdatedChip(onDismissed: () => dismissed = true),
    );

    final dismiss = find.bySemanticsLabel('Dismiss plan update');
    expect(dismiss, findsOneWidget);
    expect(tester.getSize(dismiss).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(dismiss).width, greaterThanOrEqualTo(48));
    expect(
      tester.getSemantics(dismiss).getSemanticsData().hasAction(
            SemanticsAction.tap,
          ),
      isTrue,
    );

    await tester.tap(dismiss);
    expect(dismissed, isTrue);
  });

  testWidgets('plan updated chip exposes a live status', (tester) async {
    await tester.pumpApp(PlanUpdatedChip(onDismissed: () {}));

    final status = find.bySemanticsLabel('Plan updated for the week');
    expect(status, findsOneWidget);
    expect(
      tester.getSemantics(status).flagsCollection.isLiveRegion,
      isTrue,
    );
  });

  testWidgets('rest day renders endorsed rest copy', (tester) async {
    await tester.pumpApp(
      UpcomingDayChip(
        day: UpcomingPlanDay(
          date: DateTime(2026, 5, 23),
          focusLabel: 'Rest day · recharge',
          estimatedQuestionCount: 0,
          isRestDay: true,
        ),
      ),
    );

    expect(find.text('Rest day · recharge'), findsOneWidget);
  });
}
