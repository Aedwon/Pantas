// Route /quiz, a question picking.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../helpers/in_memory_database.dart';
import 'fixtures/quiz_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen('quiz_question_picking', (tester, width) {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final session = midSession(revealed: false);
    return pumpScreen(
      tester,
      width,
      scaffolded(const QuizPage(examId: 'e', proIsActive: false)),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        flaggedIdsProvider.overrideWith((_) async => <String>{'q1'}),
        quizControllerProvider.overrideWith(
          (ref) => RunningQuizController(ref, session, selected: 'a'),
        ),
      ],
    );
  });
}
