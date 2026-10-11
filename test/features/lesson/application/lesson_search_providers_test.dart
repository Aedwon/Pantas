import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();

    await seedContentExam(
      contentDb,
      examId: 'exam_cse_pro',
      code: 'CSE_PRO',
      name: 'CSE Pro',
      shortName: 'CSE Pro',
    );
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: 'selected_exam_id',
            value: 'exam_cse_pro',
          ),
        );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'exam_cse_pro',
      name: 'Verbal',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );

    // l1: Title match ("Venn diagrams")
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'Venn diagrams',
      summary: 'Summary for Venn',
      bodyJson: jsonEncode([
        {
          '_type': 'block',
          'style': 'normal',
          'children': [
            {
              '_type': 'span',
              'text': 'Diagram content',
              'marks': <String>[],
            },
          ],
        },
      ]),
      ordering: 1,
    );

    // l2: Body-only match ("swap the plan")
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't1',
      title: 'Algebraic Expressions',
      summary: 'Summary for Expressions',
      bodyJson: jsonEncode([
        {
          '_type': 'block',
          'style': 'normal',
          'children': [
            {
              '_type': 'span',
              'text': 'Less than means swap the plan completely.',
              'marks': <String>[],
            },
          ],
        },
      ]),
      ordering: 2,
    );

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

  test('a title match sets titleMatch and leaves bodySnippet null', () async {
    container.read(searchQueryProvider.notifier).state = 'venn';
    final hits = await container.read(searchResultsProvider.future);

    expect(hits, hasLength(1));
    expect(hits.first.lessonId, 'l1');
    expect(hits.first.titleMatch, isNotNull);
    expect(hits.first.bodySnippet, isNull);
  });

  test('a body-only match sets bodySnippet and leaves titleMatch null',
      () async {
    container.read(searchQueryProvider.notifier).state = 'swap';
    final hits = await container.read(searchResultsProvider.future);

    expect(hits, hasLength(1));
    expect(hits.first.lessonId, 'l2');
    expect(hits.first.titleMatch, isNull);
    expect(hits.first.bodySnippet, isNotNull);
  });

  test('a JSON key is not a match', () async {
    // Every lesson body serialises the word "block" as a _type.
    container.read(searchQueryProvider.notifier).state = 'block';
    expect(await container.read(searchResultsProvider.future), isEmpty);
  });

  test('results are in corpus order, not marking order', () async {
    container.read(searchQueryProvider.notifier).state = 'for';
    final hits = await container.read(searchResultsProvider.future);

    expect(hits.map((h) => h.lessonId).toList(), ['l1', 'l2']);
  });

  test('an empty query gives an empty list', () async {
    container.read(searchQueryProvider.notifier).state = '';
    final hits = await container.read(searchResultsProvider.future);

    expect(hits, isEmpty);
  });

  test('a topic name returns every lesson in that topic in corpus order',
      () async {
    container.read(searchQueryProvider.notifier).state = 'VOCAB';
    final hits = await container.read(searchResultsProvider.future);
    expect(hits.map((hit) => hit.lessonId), ['l1', 'l2']);
    expect(hits.every((hit) => hit.topicName == 'Vocabulary'), isTrue);
  });

  test('searchCorpusSizeProvider counts the exam lessons', () async {
    final count = await container.read(searchCorpusSizeProvider.future);
    expect(count, 2);
  });

  test('recentlyOpenedLessonsProvider returns at most three, newest first',
      () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.pushOpenedLesson(examId: 'exam_cse_pro', lessonId: 'l2');
    await repo.pushOpenedLesson(examId: 'exam_cse_pro', lessonId: 'l1');

    final recent = await container.read(recentlyOpenedLessonsProvider.future);

    expect(recent.map((l) => l.id).toList(), ['l1', 'l2']);
  });
}
