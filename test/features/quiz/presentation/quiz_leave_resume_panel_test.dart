import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

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

    when(() => launch.resumeToday(any())).thenAnswer(
      (_) async => QuizSession.start(
        sessionId: 's1',
        examId: 'e',
        questions: const [_q1, _q2],
        startedAt: DateTime.utc(2026, 9, 10, 9),
      ),
    );

    final router = GoRouter(
      initialLocation: '/quiz',
      routes: [
        GoRoute(
          path: '/quiz',
          builder: (_, __) => const QuizTabScreen(),
        ),
        GoRoute(
          path: '/quiz/resume/:examId',
          builder: (_, __) => const QuizPage(
            examId: 'e',
            mode: QuizPageMode.resume,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeExamFocusProvider
            .overrideWith((_) async => const ActiveExamFocus.selected(_exam)),
        quizTodayCountsProvider('e').overrideWith(
          (_) async => const QuizTodayCounts(
            reviewsDone: 0,
            reviewsTotal: 0,
            newDone: 0,
            newTotal: 0,
          ),
        ),
        quizPracticeCountsProvider('e')
            .overrideWith((_) async => (mistakes: 0, flags: 0)),
        quizLaunchCoordinatorProvider.overrideWithValue(launch),
        nowProvider.overrideWithValue(() => DateTime.utc(2026, 9, 10, 9)),
        sessionPanelProvider('e').overrideWith((_) async {
          panelReads++;
          return SessionPanelInProgress(position: active ? 2 : 1, total: 2);
        }),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Resume'), findsOneWidget);
    expect(panelReads, 1);

    await tester.tap(find.text('Resume'));
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
    expect(panelReads, greaterThan(1));
  });
}
