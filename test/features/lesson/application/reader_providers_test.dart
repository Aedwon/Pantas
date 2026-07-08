import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/application/reader_providers.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

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
    var order = 1;
    for (final id in ['l1', 'l2', 'l3']) {
      await db.into(db.lessons).insert(
            LessonsCompanion.insert(
              id: id,
              topicId: 't1',
              title: 'Lesson $id',
              summary: 'Summary',
              bodyJson: jsonEncode(<Map<String, Object?>>[]),
              estimatedMinutes: 10,
              ordering: Value(order++),
            ),
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
