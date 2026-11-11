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
    await seedContentQuestion(
      contentDb,
      questionId: 'question_l1',
      topicId: 't1',
      examId: 'exam_cse_pro',
      lessonId: 'l1',
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
    await seedContentQuestion(
      contentDb,
      questionId: 'question_l2',
      topicId: 't1',
      examId: 'exam_cse_pro',
      lessonId: 'l2',
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

  test('a title match keeps the whole title, however long', () async {
    const title = 'Sets and Set Notation (Unions, Intersections, Subsets, '
        'Venn Diagrams)';
    await seedContentLesson(
      contentDb,
      lessonId: 'l3',
      topicId: 't1',
      title: title,
      summary: 'Summary for Sets',
      bodyJson: jsonEncode([]),
      ordering: 3,
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_l3',
      topicId: 't1',
      examId: 'exam_cse_pro',
      lessonId: 'l3',
    );
    container.read(searchQueryProvider.notifier).state = 'venn';
    final hits = await container.read(searchResultsProvider.future);

    final match = hits.singleWhere((hit) => hit.lessonId == 'l3').titleMatch!;
    // Not cut to a window around the match, so the lesson's name still opens
    // the row.
    expect(match.text, title);
    expect(
      match.text.substring(
        match.matchStart,
        match.matchStart + match.matchLength,
      ),
      'Venn',
    );
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

  test('a title match comes before an earlier body match', () async {
    // l2 holds "plan" in its body and is first in the corpus. l4 has it in
    // its title and is last.
    await seedContentLesson(
      contentDb,
      lessonId: 'l4',
      topicId: 't1',
      title: 'Plan your answer',
      summary: 'Summary for Plan',
      bodyJson: jsonEncode([]),
      ordering: 4,
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_l4',
      topicId: 't1',
      examId: 'exam_cse_pro',
      lessonId: 'l4',
    );
    container.read(searchQueryProvider.notifier).state = 'plan';
    final hits = await container.read(searchResultsProvider.future);

    expect(hits.map((hit) => hit.lessonId), ['l4', 'l2']);
  });

  test('a whole-word title match comes before a match inside a word (3K-18)',
      () async {
    // "Order of Operations" holds "ratio" inside "Operations" and comes
    // first in the corpus. "Ratio and Proportion" has the word itself.
    await seedContentLesson(
      contentDb,
      lessonId: 'l5',
      topicId: 't1',
      title: 'Order of Operations',
      bodyJson: jsonEncode([]),
      ordering: 3,
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_l5',
      topicId: 't1',
      examId: 'exam_cse_pro',
      lessonId: 'l5',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l6',
      topicId: 't1',
      title: 'Ratio and Proportion',
      bodyJson: jsonEncode([]),
      ordering: 4,
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_l6',
      topicId: 't1',
      examId: 'exam_cse_pro',
      lessonId: 'l6',
    );
    container.read(searchQueryProvider.notifier).state = 'ratio';
    final hits = await container.read(searchResultsProvider.future);

    expect(hits.map((hit) => hit.lessonId), ['l6', 'l5']);
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
