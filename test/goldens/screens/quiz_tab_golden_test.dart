// Route /quiz (the Quiz tab), with a session ready for today.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/pump_app.dart' show buildExam;
import 'fixtures/quiz_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen('quiz_tab', (tester, width) {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    return pumpScreen(
      tester,
      width,
      scaffolded(
        const QuizTabScreen(
          mockPanel: MockCard(
            model: MockCardModel(
              state: MockCardState.waiting,
              name: 'CSE simulation',
              durationMinutes: 190,
              lastPercent: 69,
            ),
          ),
        ),
      ),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        sessionPanelProvider('e').overrideWith(
          (_) async => const SessionPanelAvailable(
            plan: TodaySessionPlan(
              questions: [],
              dueCount: 14,
              weaknessCount: 0,
              freshCount: 0,
            ),
          ),
        ),
        todayQuestionWorkProvider('e').overrideWith((_) async => ReviewWork()),
        quizTodayCountsProvider('e').overrideWith(
          (_) async => const QuizTodayCounts(
            reviewsDone: 18,
            reviewsTotal: 32,
            newDone: 7,
            newTotal: 7,
          ),
        ),
        quizPracticeCountsProvider('e')
            .overrideWith((_) async => (mistakes: 28, flags: 12)),
      ],
    );
  });
}
