import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/today_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  test('an exam with no content yields no rows', () async {
    final rows = await container.read(
      todayTopicQueueProvider('exam_cse_pro').future,
    );

    expect(rows, isEmpty);
  });

  test('topics with unseen questions come back as fresh backlog', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2'],
    );

    final rows = await container.read(
      todayTopicQueueProvider('exam_cse_pro').future,
    );

    expect(rows.single.topicName, 'Algebra');
    expect(rows.single.newCount, 2);
    expect(rows.single.isRecommended, isTrue);
  });

  test('the largest backlog is the recommended topic', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1'],
    );
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_geometry',
      topicName: 'Geometry',
      questionIds: ['q_2', 'q_3'],
    );

    final rows = await container.read(
      todayTopicQueueProvider('exam_cse_pro').future,
    );

    expect(rows.first.topicId, 'topic_geometry');
    expect(rows.first.isRecommended, isTrue);
    expect(rows.last.isRecommended, isFalse);
  });
}
