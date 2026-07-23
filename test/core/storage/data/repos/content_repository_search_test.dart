import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:drift/native.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late ContentDatabase db;
  late ContentRepository repo;

  setUp(() async {
    db = ContentDatabase(NativeDatabase.memory());
    repo = ContentRepository(db);

    await db.into(db.contentExams).insert(
          ContentExamsCompanion.insert(
            id: 'exam_cse_pro',
            code: 'CSE_PRO',
            name: 'CSE Pro',
            shortName: 'CSE Pro',
            language: 'en',
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 's1',
            examId: 'exam_cse_pro',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't_other',
            subjectId: 's1',
            name: 'Other',
            ordering: 2,
          ),
        );

    // Title match
    await db.into(db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: 'l_title',
            topicId: 't1',
            title: 'Venn diagrams',
            summary: 'Summary A',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 5,
          ),
        );

    // Summary match
    await db.into(db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: 'l_summary',
            topicId: 't1',
            title: 'Summary title',
            summary: 'This includes gemdas trick',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 5,
          ),
        );

    // Body match
    await db.into(db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: 'l_body',
            topicId: 't1',
            title: 'Algebraic Expressions',
            summary: 'Summary C',
            bodyJson: jsonEncode([
              {
                '_type': 'block',
                'style': 'normal',
                'children': [
                  {
                    '_type': 'span',
                    'text': 'Less than means swap the plan.',
                    'marks': <String>[],
                  },
                ],
              },
            ]),
            estimatedMinutes: 5,
          ),
        );

    // Nothing match
    await db.into(db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: 'l_none',
            topicId: 't1',
            title: 'Unrelated title',
            summary: 'Unrelated summary',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

  test('a title match comes back', () async {
    expect(
      (await repo.searchLessonRows(topicIds: ['t1'], query: 'venn'))
          .map((row) => row.id),
      contains('l_title'),
    );
  });

  test('a body match comes back', () async {
    expect(
      (await repo.searchLessonRows(topicIds: ['t1'], query: 'swap'))
          .map((row) => row.id),
      contains('l_body'),
    );
  });

  test('matching ignores case', () async {
    expect(
      await repo.searchLessonRows(topicIds: ['t1'], query: 'VENN'),
      isNotEmpty,
    );
  });

  test('a topic outside the list is never searched', () async {
    expect(
      await repo.searchLessonRows(topicIds: ['t_other'], query: 'venn'),
      isEmpty,
    );
  });

  test('an empty query returns nothing rather than everything', () async {
    expect(await repo.searchLessonRows(topicIds: ['t1'], query: ''), isEmpty);
  });
}
