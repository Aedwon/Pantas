import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('completion refreshes the practice pace when a measured average exists',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(practicePaceProvider('e').future), isNull);
    final attempts = container.read(attemptsRepositoryProvider);
    for (var i = 0; i < 7; i++) {
      await attempts.save(
        Attempt(
          id: 's$i',
          examId: 'e',
          startedAt: DateTime.utc(2026, 10, i + 1),
          completedAt: DateTime.utc(2026, 10, i + 1, 0, 1),
          items: const [
            AttemptItem(
              questionId: 'q',
              questionVersion: 1,
              chosenChoiceId: 'a',
              correctChoiceId: 'a',
              responseMs: 40000,
            ),
          ],
        ),
      );
    }
    container.read(quizSessionPanelRevisionProvider.notifier).state++;
    expect(await container.read(practicePaceProvider('e').future), 40000);
  });
}
