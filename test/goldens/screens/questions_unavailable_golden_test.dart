// The error state of the quiz: the questions are not available.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/questions_unavailable.dart';

import '../../helpers/in_memory_database.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen('questions_unavailable', (tester, width) {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    return pumpScreen(
      tester,
      width,
      scaffolded(QuestionsUnavailable(notFound: true, onRetry: () {})),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
}
