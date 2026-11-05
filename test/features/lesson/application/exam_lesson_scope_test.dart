import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    final db = inMemoryDatabase();
    final content = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
    addTearDown(content.close);
    for (final exam in ['pro', 'sub']) {
      await seedContentExam(
        content,
        examId: exam,
        code: exam,
        name: exam,
      );
    }
    for (final subject in ['math', 'mechanical', 'clerical']) {
      await seedContentSubject(
        content,
        subjectId: subject,
        examId: 'pro',
        name: subject,
      );
      await seedContentTopic(
        content,
        topicId: subject,
        subjectId: subject,
        name: subject,
      );
    }
    for (final id in ['kept', 'other', 'inactive', 'empty', 'unlinked']) {
      await seedContentLesson(
        content,
        lessonId: id,
        topicId: 'math',
        title: 'Algebra $id',
      );
    }
    for (final id in ['mechanical', 'clerical']) {
      await seedContentLesson(
        content,
        lessonId: id,
        topicId: id,
        title: id,
      );
    }
    for (final entry in [
      ('kept', 'math', 'pro', true, 'kept'),
      ('other', 'math', 'sub', true, 'other'),
      ('inactive', 'math', 'pro', false, 'inactive'),
      ('unlinked', 'math', 'pro', true, null),
      ('clerical', 'clerical', 'sub', true, 'clerical'),
    ]) {
      await seedContentQuestion(
        content,
        questionId: entry.$1,
        topicId: entry.$2,
        examId: entry.$3,
        isActive: entry.$4,
        lessonId: entry.$5,
      );
    }
    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('pro');
  });

  test('map drops lessons without active exam questions and empty parents',
      () async {
    final map = (await container.read(studyMapProvider.future))!;
    expect(map.subjects.map((s) => s.id), ['math']);
    expect(map.subjects.single.topics.map((t) => t.id), ['math']);
    expect(
      map.subjects.single.topics.single.lessons.map((l) => l.id),
      ['kept'],
    );
    expect(map.totalCount, 1);
  });

  test('the same rule keeps Subprofessional lessons for that exam', () async {
    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('sub');
    final map = (await container.read(studyMapProvider.future))!;
    expect(map.subjects.map((s) => s.id), ['math', 'clerical']);
    expect(
      map.subjects
          .expand((s) => s.topics)
          .expand((t) => t.lessons)
          .map((l) => l.id),
      ['other', 'clerical'],
    );
  });

  for (final query in ['Algebra', 'math']) {
    test('search filters lesson and topic matches for $query', () async {
      container.read(searchQueryProvider.notifier).state = query;
      final hits = await container.read(searchResultsProvider.future);
      expect(hits.map((h) => h.lessonId), ['kept']);
    });
  }

  test('full lesson lists and planning metadata use the same exam rule',
      () async {
    final content = container.read(contentRepositoryProvider);
    final full = await content.lessonsByTopics(['math'], examId: 'pro');
    final metadata = await content.lessonMetaByTopics(['math'], examId: 'pro');
    expect(full['math']!.map((lesson) => lesson.id), ['kept']);
    expect(metadata['math']!.map((lesson) => lesson.id), ['kept']);
  });

  test('topic lists use exam eligibility without blocking direct lookup',
      () async {
    final lessons = await container.read(topicLessonsProvider('math').future);
    expect(lessons.map((l) => l.id), ['kept']);
    expect(
      (await container.read(lessonByIdProvider('other').future))?.id,
      'other',
    );
  });

  test('bookmarks hide ineligible lessons and preserve saved progress',
      () async {
    final marks = container.read(lessonBookmarksRepositoryProvider);
    await marks.mark('kept');
    await marks.mark('other');
    await container.read(lessonProgressRepositoryProvider).markRead('other');
    final rows = await container.read(bookmarkRowsProvider.future);
    expect(rows.map((r) => r.lessonId), ['kept']);
    expect(await marks.markedIds(), containsAll(['kept', 'other']));
    expect(
      await container.read(lessonProgressRepositoryProvider).isRead('other'),
      isTrue,
    );
  });
}
