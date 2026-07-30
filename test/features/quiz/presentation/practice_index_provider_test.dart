import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  test('an exam with no content indexes as empty', () async {
    final index =
        await container.read(practiceIndexProvider('exam_cse_pro').future);

    expect(index.isEmpty, isTrue);
  });

  test('topics arrive under their subject in ordering', () async {
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2'],
    );

    final index =
        await container.read(practiceIndexProvider('exam_cse_pro').future);

    expect(index.subjects.single.topics.single.name, 'Algebra');
    expect(index.subjects.single.topics.single.questionCount, 2);
  });

  test('a lesson read is marked read', () async {
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1'],
      lessonIds: ['l_1', 'l_2'],
    );
    await LessonProgressRepository(db, contentDb).markRead('l_1');

    final index =
        await container.read(practiceIndexProvider('exam_cse_pro').future);
    final lessons = index.subjects.single.topics.single.lessons;

    expect(lessons.firstWhere((l) => l.id == 'l_1').isRead, isTrue);
    expect(lessons.firstWhere((l) => l.id == 'l_2').isRead, isFalse);
  });
}
