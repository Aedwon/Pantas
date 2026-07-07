import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
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
    for (final id in ['l1', 'l2']) {
      await db.into(db.lessons).insert(
            LessonsCompanion.insert(
              id: id,
              topicId: 't1',
              title: 'Lesson $id',
              summary: 'Summary',
              bodyJson: jsonEncode(<Map<String, Object?>>[]),
              estimatedMinutes: 10,
            ),
          );
    }
    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('e1');
  });

  test('the map reflects what has been read', () async {
    await container.read(lessonProgressRepositoryProvider).markRead('l1');

    final map = await container.read(studyMapProvider.future);

    expect(map!.totalCount, 2);
    expect(map.readCount, 1);
    expect(map.coveredPercent, 50);
    expect(map.minutesLeftToRead, 10);
  });

  test('the map is null when no exam is chosen', () async {
    final blank = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(inMemoryDatabase())],
    );
    addTearDown(blank.dispose);

    expect(await blank.read(studyMapProvider.future), isNull);
  });

  test('opening a topic stores it and opening another replaces it', () async {
    final controller = container.read(openTopicProvider.notifier);

    await controller.toggle('t1');
    expect(container.read(openTopicProvider).valueOrNull, 't1');

    await controller.toggle('t2');
    expect(container.read(openTopicProvider).valueOrNull, 't2');
  });

  test('toggling the open topic closes it', () async {
    final controller = container.read(openTopicProvider.notifier);

    await controller.toggle('t1');
    await controller.toggle('t1');

    expect(container.read(openTopicProvider).valueOrNull, isNull);
    expect(
      await container.read(appPreferencesRepositoryProvider).openTopicId('e1'),
      isNull,
    );
  });

  test('the open topic survives a fresh container', () async {
    await container.read(openTopicProvider.notifier).toggle('t1');

    final second = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(second.dispose);

    expect(await second.read(openTopicProvider.future), 't1');
  });

  test('the last opened lesson comes back hydrated', () async {
    await container
        .read(appPreferencesRepositoryProvider)
        .pushOpenedLesson(examId: 'e1', lessonId: 'l2');

    final lesson = await container.read(lastOpenedLessonProvider.future);

    expect(lesson!.id, 'l2');
  });

  test('no last opened lesson is null, not an error', () async {
    expect(await container.read(lastOpenedLessonProvider.future), isNull);
  });
}
