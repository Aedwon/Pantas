import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/repos/review_log_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('submitAnswerProvider persists review state and review log', () async {
    final db = inMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    const question = Question(
      id: 'provider-review-log-question',
      version: 1,
      examIds: ['exam'],
      topicId: 'topic',
      language: 'en',
      stem: 'Which choice is correct?',
      choices: [
        Choice(id: 'wrong', label: 'A', text: 'Wrong', isCorrect: false),
        Choice(id: 'correct', label: 'B', text: 'Correct', isCorrect: true),
      ],
      explanation: 'Choice B is correct.',
    );
    final now = DateTime.utc(2026, 9, 6, 8);

    await container.read(submitAnswerProvider)(
      question: question,
      chosenChoiceId: 'correct',
      responseMs: 2400,
      now: now,
    );

    final reviewState =
        await ReviewStateRepository(db).byQuestionId(question.id);
    expect(reviewState, isNotNull);

    final reviewLogs = await ReviewLogRepository(db).byQuestionId(question.id);
    expect(reviewLogs, hasLength(1));
    expect(reviewLogs.single.review, now);
  });
}
