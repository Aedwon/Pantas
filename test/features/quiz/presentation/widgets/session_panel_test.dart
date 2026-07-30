import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/quiz/presentation/widgets/session_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

const _exam = Exam(
  id: 'exam_cse_pro',
  code: 'CSE_PRO',
  name: 'Civil Service Exam Professional',
  shortName: 'CSE Pro',
  language: 'en',
  isActive: true,
  subjects: [],
);

Future<void> pumpPanel(WidgetTester tester, SessionPanelState state) =>
    tester.pumpAppWithProviders(
      const Scaffold(body: SessionPanel(exam: _exam)),
      overrides: [
        sessionPanelProvider('exam_cse_pro').overrideWith((_) async => state),
      ],
    );

void main() {
  testWidgets('the assessment state names its own length', (tester) async {
    await pumpPanel(tester, const SessionPanelNeedsAssessment(21));
    await tester.pumpAndSettle();

    expect(find.text('Start with the assessment'), findsOneWidget);
    expect(find.text('21 questions'), findsOneWidget);
    expect(find.text('Take the assessment'), findsOneWidget);
  });

  testWidgets('the available state shows only questions without history',
      (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 6,
          weaknessCount: 3,
          freshCount: 1,
          topicName: 'Chemistry',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('questions'), findsOneWidget);
    expect(find.text('your average'), findsNothing);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('the average appears once there is history', (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 6,
          weaknessCount: 3,
          freshCount: 1,
        ),
        averageMinutes: 9,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('your average'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('the composition line reads as the spec writes it',
      (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 6,
          weaknessCount: 3,
          freshCount: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('6 due · 3 weak spots · 1 new'), findsOneWidget);
    expect(find.text('Change how sessions are built'), findsOneWidget);
  });

  testWidgets('a count of one is singular', (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 9,
          weaknessCount: 1,
          freshCount: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('9 due · 1 weak spot'), findsOneWidget);
  });

  testWidgets('the caught up state offers no button', (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelCaughtUp(answeredToday: 12, correctToday: 9),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('answered today'), findsOneWidget);
    expect(find.text('got right'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('the in progress state names the topic and counts the answers',
      (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelInProgress(
        answered: 6,
        total: 10,
        topicName: 'Chemistry',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Still going'), findsOneWidget);
    expect(find.text('6 of 10'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Discard this session'), findsOneWidget);
    expect(find.textContaining('Chemistry'), findsOneWidget);
  });

  testWidgets('an unnamed session still explains itself', (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelInProgress(answered: 6, total: 10),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('You stopped partway through this session. '
          'Every answer was saved.'),
      findsOneWidget,
    );
  });
}
