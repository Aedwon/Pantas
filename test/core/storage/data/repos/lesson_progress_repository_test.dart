import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late LessonProgressRepository repo;

  setUp(() async {
    db = inMemoryDatabase();
    repo = LessonProgressRepository(db);

    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Lesson 1',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l2',
            topicId: 't1',
            title: 'Lesson 2',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

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
