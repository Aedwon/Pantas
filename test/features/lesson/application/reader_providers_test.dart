import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
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
    var order = 1;
    for (final id in ['l1', 'l2', 'l3']) {
      await seedContentLesson(
        contentDb,
        lessonId: id,
        topicId: 't1',
        title: 'Lesson $id',
        bodyJson: jsonEncode(<Map<String, Object?>>[]),
        estimatedMinutes: 10,
        ordering: order++,
      );
    }
    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('e1');
  });

  test('the reader knows where it sits in the topic', () async {
    final context = await container.read(readerContextProvider('l2').future);

    expect(context!.topicName, 'Chemistry');
    expect(context.positionInTopic, 2);
    expect(context.lessonsInTopic, 3);
    expect(context.next!.id, 'l3');
  });

  test('the last lesson in a topic has no next', () async {
    final context = await container.read(readerContextProvider('l3').future);

    expect(context!.next, isNull);
  });

  test('a lesson that is not in the corpus is null', () async {
    expect(await container.read(readerContextProvider('l9').future), isNull);
  });

  test('the reader carries the read and bookmarked state', () async {
    await container.read(lessonProgressRepositoryProvider).markRead('l1');
    await container.read(lessonBookmarksRepositoryProvider).mark('l1');

    final context = await container.read(readerContextProvider('l1').future);

    expect(context!.isRead, isTrue);
    expect(context.isBookmarked, isTrue);
  });

  test('the reader resolves the selected exam for the coda', () async {
    final context = await container.read(readerContextProvider('l1').future);

    expect(context!.examId, 'e1');
  });
}
