import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('quick-quiz happy path: start → answer 2 → complete', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );
    addTearDown(container.dispose);

    await Seeder(db, bundle: rootBundle).maybeSeed();

    final notifier = container.read(quizControllerProvider.notifier);
    await notifier.start(examId: 'exam_cse_pro', count: 2, randomSeed: 1);

    final running1 = container.read(quizControllerProvider);
    expect(running1, isA<QuizRunning>());
    final firstQuestion = (running1 as QuizRunning).session.currentQuestion;

    // Answer question 1 with the correct choice, then read the reveal and
    // move on: answering no longer advances by itself.
    await notifier.answer(chosenChoiceId: firstQuestion.correctChoice.id);
    await notifier.next();

    // After question 1, we should still be running (count == 2).
    final running2 = container.read(quizControllerProvider);
    if (running2 is QuizRunning) {
      await notifier.answer(
        chosenChoiceId: running2.session.currentQuestion.correctChoice.id,
      );
      await notifier.next();
    }

    // Now the quiz should be complete.
    final finalState = container.read(quizControllerProvider);
    expect(finalState, isA<QuizComplete>());

    final attempt = (finalState as QuizComplete).attempt;
    expect(attempt.items, hasLength(2));
    expect(attempt.score.$1, equals(2)); // both correct
  });
}
