import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/application/bookmark_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/bookmark_order.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late LessonBookmarksRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    repo = LessonBookmarksRepository(db);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Chemistry',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'Lesson l1',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 13,
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't1',
      title: 'Lesson l2',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 10,
    );

    await seedContentSubject(
      contentDb,
      subjectId: 's2',
      examId: 'e1',
      name: 'Math',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't2',
      subjectId: 's2',
      name: 'Algebra',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l3',
      topicId: 't2',
      title: 'Lesson l3',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 15,
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l4',
      topicId: 't2',
      title: 'Lesson l4',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 12,
    );

    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('e1');
  });

  test('recent order is newest first', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l3');

    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.recent);

    expect(
      (await container.read(bookmarkRowsProvider.future))
          .map((row) => row.lessonId)
          .toList(),
      ['l3', 'l1'],
    );
  });

  test('oldest order is its reverse', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l3');

    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.oldest);

    expect(
      (await container.read(bookmarkRowsProvider.future))
          .map((row) => row.lessonId)
          .toList(),
      ['l1', 'l3'],
    );
  });

  test('by subject follows the corpus, not the marking', () async {
    // l3 is in the second subject and was marked first.
    await repo.mark('l3');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l1');

    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.bySubject);

    expect(
      (await container.read(bookmarkRowsProvider.future))
          .map((row) => row.lessonId)
          .toList(),
      ['l1', 'l3'],
    );
  });

  test('custom order puts hand-placed rows ahead of unplaced ones', () async {
    await repo.mark('l1');
    await repo.mark('l3');
    await repo.reorder(['l3']);

    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.custom);

    expect(
      (await container.read(bookmarkRowsProvider.future))
          .map((row) => row.lessonId)
          .toList(),
      ['l3', 'l1'],
    );
  });

  test('a row carries the title, topic and minutes its row prints', () async {
    await repo.mark('l1');

    final row = (await container.read(bookmarkRowsProvider.future)).single;

    expect(row.title, 'Lesson l1');
    expect(row.topicName, 'Chemistry');
    expect(row.estimatedMinutes, 13);
  });

  test('a bookmark whose lesson is gone is dropped, not drawn blank', () async {
    await repo.mark('l1');
    await db.delete(db.lessonBookmarksLocal).go();
    await db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: 'l_missing',
            markedAt: DateTime.now(),
          ),
        );

    expect(await container.read(bookmarkRowsProvider.future), isEmpty);
  });

  test('the count is the number of rows', () async {
    await repo.mark('l1');
    await repo.mark('l3');

    expect(await container.read(bookmarkCountProvider.future), 2);
  });
}
