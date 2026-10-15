import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/quiz/presentation/widgets/session_panel.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _MockLaunchCoordinator extends Mock implements QuizLaunchCoordinator {}

const _exam = Exam(
  id: 'e',
  code: 'E',
  name: 'Exam',
  shortName: 'Exam',
  language: 'en',
  isActive: true,
  subjects: [],
);

const _q1 = Question(
  id: 'q1',
  version: 1,
  examIds: ['e'],
  topicId: 't',
  language: 'en',
  stem: 'Question one',
  choices: [
    Choice(id: 'a', label: 'A', text: 'Alpha', isCorrect: true),
    Choice(id: 'b', label: 'B', text: 'Beta', isCorrect: false),
  ],
  explanation: 'Because.',
);

const _q2 = Question(
  id: 'q2',
  version: 1,
  examIds: ['e'],
  topicId: 't',
  language: 'en',
  stem: 'Question two',
  choices: [
    Choice(id: 'c', label: 'A', text: 'Gamma', isCorrect: true),
    Choice(id: 'd', label: 'B', text: 'Delta', isCorrect: false),
  ],
  explanation: 'Because.',
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const QuizPreparationRequest(userId: quizLocalUserId, examId: 'e'),
    );
  });

  testWidgets(
      'Leave refreshes the Quiz panel so an active session shows Resume',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final launch = _MockLaunchCoordinator();
    var active = false;
    var panelReads = 0;

    when(
      () => launch.launchToday(
        any(),
        prepared: any(named: 'prepared'),
      ),
    ).thenAnswer(
      (_) async => QuizLaunchStarted(
        QuizSession.start(
          sessionId: 's1',
          examId: 'e',
          questions: const [_q1, _q2],
          startedAt: DateTime.utc(2026, 9, 10, 9),
        ),
      ),
    );

    final router = GoRouter(
      initialLocation: '/quiz',
      routes: [
        GoRoute(
          path: '/quiz',
          builder: (_, __) => const Scaffold(body: SessionPanel(exam: _exam)),
        ),
        GoRoute(
          path: '/quiz/today/:examId',
          builder: (_, __) => const QuizPage(
            examId: 'e',
            mode: QuizPageMode.today,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        quizLaunchCoordinatorProvider.overrideWithValue(launch),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 9, 10, 9)),
        sessionPanelProvider('e').overrideWith((_) async {
          panelReads += 1;
          if (active) {
            return const SessionPanelInProgress(position: 2, total: 2);
          }
          return const SessionPanelAvailable(
            plan: TodaySessionPlan(
              questions: [_q1, _q2],
              dueCount: 0,
              weaknessCount: 0,
              freshCount: 2,
            ),
          );
        }),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsOneWidget);
    expect(panelReads, 1);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Question one'), findsOneWidget);

    await tester.tap(find.byTooltip('Leave session'));
    await tester.pumpAndSettle();
    expect(find.text('Leave this session?'), findsOneWidget);

    active = true;
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
    expect(panelReads, 2);
  });
}
