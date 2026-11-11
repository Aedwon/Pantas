// Route /quiz, the end of a session (7 of 10).
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';

import '../../features/quiz/presentation/session_end_screen_test.dart'
    show completedAttempt, completedSession;
import '../../helpers/in_memory_database.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen('session_end', (tester, width) {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final session = completedSession(batch: true);
    return pumpScreen(
      tester,
      width,
      scaffolded(
        SessionEndBody(
          session: session,
          attempt: completedAttempt(session),
          subjectNames: const {'t': 'Earth Science'},
          proIsActive: true,
          onDone: () {},
          onQuestion: (_) {},
          onAll: () {},
          onMistakes: () {},
          onNotes: () {},
          onNext: () async {},
        ),
      ),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
}
