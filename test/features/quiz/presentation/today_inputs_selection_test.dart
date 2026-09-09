import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('Today counts from lightweight rows and shares one daily new-card cap',
      () async {
    final db = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);

    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: [for (var i = 0; i < 8; i++) 'a_$i'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_b',
      topicName: 'B',
      questionIds: [for (var i = 0; i < 8; i++) 'b_$i'],
    );

    // A full-question selection path would try to decode these and fail.
    await contentDb.customStatement(
      "UPDATE content_questions SET stem_json = 'INVALID', "
      "explanation_json = 'INVALID'",
    );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    final inputs =
        await container.read(todayInputsProvider('exam_cse_pro').future);

    expect(
      inputs.backlogByTopic.values
          .fold<int>(0, (sum, backlog) => sum + backlog.fresh.length),
      10,
    );
    expect(
      inputs.questionsByTopic.values.expand((items) => items),
      hasLength(16),
    );
    expect(
      inputs.questionsByTopic.values.expand((items) => items).every(
            (question) => question.stem.isEmpty && question.choices.isEmpty,
          ),
      isTrue,
    );
  });
}
