import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late LessonProgressRepository repo;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    repo = LessonProgressRepository(db, contentDb);

    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    await seedContentLesson(contentDb, lessonId: 'l1', topicId: 't1');
    await seedContentLesson(contentDb, lessonId: 'l2', topicId: 't1');
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test('isRead returns false before markRead', () async {
    expect(await repo.isRead('l1'), isFalse);
  });

  test('isRead returns true after markRead', () async {
    await repo.markRead('l1');
    expect(await repo.isRead('l1'), isTrue);
  });

  test('markRead is idempotent', () async {
    await repo.markRead('l1');
    await repo.markRead('l1');
    final rows = await db.select(db.lessonProgressLocal).get();
    expect(rows, hasLength(1));
  });

  test('readLessonIds returns empty set before any reads', () async {
    expect(await repo.readLessonIds(), isEmpty);
  });

  test('readLessonIds returns all read lesson IDs', () async {
    await repo.markRead('l1');
    await repo.markRead('l2');
    expect(await repo.readLessonIds(), containsAll(['l1', 'l2']));
  });

  test('readCountForTopic returns 0 when none read', () async {
    expect(await repo.readCountForTopic('t1'), equals(0));
  });

  test('readCountForTopic returns correct count when some read', () async {
    await repo.markRead('l1');
    expect(await repo.readCountForTopic('t1'), equals(1));
    await repo.markRead('l2');
    expect(await repo.readCountForTopic('t1'), equals(2));
  });

  test('hasAnyRead returns false on empty DB', () async {
    expect(await repo.hasAnyRead(), isFalse);
  });

  test('hasAnyRead returns true after any markRead', () async {
    await repo.markRead('l1');
    expect(await repo.hasAnyRead(), isTrue);
  });
}
