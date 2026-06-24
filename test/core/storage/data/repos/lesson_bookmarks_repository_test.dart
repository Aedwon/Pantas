import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late LessonBookmarksRepository repo;

  Future<void> insertLesson(String id) {
    return db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: id,
            topicId: 't1',
            title: 'Lesson $id',
            summary: 'Summary',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 5,
          ),
        );
  }

  setUp(() async {
    db = inMemoryDatabase();
    repo = LessonBookmarksRepository(db);

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
            name: 'Science',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Chemistry',
            ordering: 1,
          ),
        );
    await insertLesson('l1');
    await insertLesson('l2');
    await insertLesson('l3');
  });

  tearDown(() => db.close());

  test('marking a lesson bookmarks it', () async {
    await repo.mark('l1');

    expect(await repo.isMarked('l1'), isTrue);
    expect(await repo.isMarked('l2'), isFalse);
    expect(await repo.count(), 1);
    expect(await repo.markedIds(), {'l1'});
  });

  test('marking twice keeps one row and refreshes the timestamp', () async {
    await repo.mark('l1');
    final first =
        (await db.select(db.lessonBookmarksLocal).get()).single.markedAt;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l1');

    final rows = await db.select(db.lessonBookmarksLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.markedAt.isAfter(first), isTrue);
  });

  test('unmarking a lesson removes its row', () async {
    await repo.mark('l1');
    await repo.unmark('l1');

    expect(await repo.isMarked('l1'), isFalse);
    expect(await repo.count(), 0);
  });

  test('unmarkAll removes multiple bookmarks', () async {
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.mark('l3');

    await repo.unmarkAll(['l1', 'l3']);

    expect(await repo.markedIds(), {'l2'});
  });

  test('unmarkAll on an empty list does nothing', () async {
    await repo.mark('l1');
    await repo.unmarkAll([]);

    expect(await repo.count(), 1);
  });

  test('recentFirst returns bookmarks newest first', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l2');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l3');

    expect(
      (await repo.recentFirst()).map((row) => row.lessonId).toList(),
      ['l3', 'l2', 'l1'],
    );
    expect(
      (await repo.oldestFirst()).map((row) => row.lessonId).toList(),
      ['l1', 'l2', 'l3'],
    );
  });

  test('reorder writes a custom order that survives a re-read', () async {
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.mark('l3');

    await repo.reorder(['l3', 'l1', 'l2']);

    expect(
      (await repo.customOrder()).map((row) => row.lessonId).toList(),
      ['l3', 'l1', 'l2'],
    );
  });

  test('a new bookmark lands at the top of a custom order', () async {
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.reorder(['l1', 'l2']);

    await repo.mark('l3');

    expect(
      (await repo.customOrder()).map((row) => row.lessonId).toList(),
      ['l3', 'l1', 'l2'],
    );
  });

  test('custom order falls back to recency for unplaced rows', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l2');
    await repo.reorder(['l2']);

    // l1 was never placed by hand, so it sorts after the one that was.
    expect(
      (await repo.customOrder()).map((row) => row.lessonId).toList(),
      ['l2', 'l1'],
    );
  });

  test('clearing the custom order drops every sort index', () async {
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.reorder(['l2', 'l1']);

    await repo.clearCustomOrder();

    final rows = await db.select(db.lessonBookmarksLocal).get();
    expect(rows.every((row) => row.sortIndex == null), isTrue);
  });

  test('a new bookmark is pending sync', () async {
    await repo.mark('l1');

    expect(
      (await db.select(db.lessonBookmarksLocal).get()).single.syncState,
      'pending',
    );
  });
}
