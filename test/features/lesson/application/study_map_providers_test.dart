import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';

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
    for (final id in ['l1', 'l2']) {
      await seedContentLesson(
        contentDb,
        lessonId: id,
        topicId: 't1',
        title: 'Lesson $id',
        bodyJson: jsonEncode(<Map<String, Object?>>[]),
        estimatedMinutes: 10,
      );
    }
    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('e1');
  });

  test('audit opening refreshes Last opened and cached recents', () async {
    final last = container.listen(lastOpenedLessonProvider, (_, __) {});
    final recent = container.listen(recentlyOpenedLessonsProvider, (_, __) {});
    addTearDown(last.close);
    addTearDown(recent.close);
    expect(await container.read(lastOpenedLessonProvider.future), isNull);
    expect(await container.read(recentlyOpenedLessonsProvider.future), isEmpty);
    final positions = container.read(readerPositionRepositoryProvider);
    final boundary =
        (await positions.captureBoundary('e1', isCurrent: () => true))!;
    final reader = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: container.read(lessonProgressRepositoryProvider),
      preferencesRepository: container.read(appPreferencesRepositoryProvider),
      positions: positions,
      boundary: boundary,
      isCurrent: () => true,
      onOpened: () {
        container
          ..invalidate(lastOpenedLessonProvider)
          ..invalidate(recentlyOpenedLessonsProvider);
      },
    );
    addTearDown(reader.dispose);
    await reader.onOpen();
    await pumpEventQueue();
    expect(
      await container
          .read(appPreferencesRepositoryProvider)
          .lastOpenedLessonId('e1'),
      'l1',
    );
    expect((await container.read(lastOpenedLessonProvider.future))?.id, 'l1');
    expect(
      (await container.read(recentlyOpenedLessonsProvider.future))
          .map((l) => l.id),
      ['l1'],
    );
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
      overrides: [
        appDatabaseProvider.overrideWithValue(inMemoryDatabase()),
        // A blank state means no corpus either; sharing the seeded one let
        // the provider fall back to an exam this test never chose.
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
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
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
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
