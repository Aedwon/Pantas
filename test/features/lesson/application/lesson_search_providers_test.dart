import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/application/lesson_search_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();

    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_cse_pro',
            code: 'CSE_PRO',
            name: 'CSE Pro',
            shortName: 'CSE Pro',
            language: 'en',
          ),
        );
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: 'selected_exam_id',
            value: 'exam_cse_pro',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'exam_cse_pro',
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

    // l1: Title match ("Venn diagrams")
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
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
            estimatedMinutes: 5,
            ordering: const Value(1),
          ),
        );

    // l2: Body-only match ("swap the plan")
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l2',
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
            estimatedMinutes: 5,
            ordering: const Value(2),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
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
