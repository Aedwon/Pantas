import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';

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
            ordering: 1,
            isCustom: const Value(false),
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 's1',
            examId: 'exam_cse_pro',
            name: 'Verbal',
            ordering: 1,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Vocabulary Basics',
            summary: 'Core vocabulary concepts',
            updatedAt: DateTime.now(),
            schemaVersion: 1,
            bodyJson: jsonEncode(<Map<String, Object?>>[
              {
                '_type': 'block',
                'style': 'normal',
                'children': <Map<String, Object?>>[
                  {'_type': 'span', 'text': 'Hello world', 'marks': <String>[]},
                ],
              },
            ]),
            estimatedMinutes: 5,
          ),
        );
    await db.into(db.contentQuestions).insert(
          ContentQuestionsCompanion.insert(
            id: 'q1',
            version: 1,
            topicId: 't1',
            language: 'en',
            updatedAt: DateTime.now(),
            schemaVersion: 1,
            stemJson: jsonEncode([
              {
                '_type': 'block',
                'children': [
                  {'_type': 'span', 'text': 'stem'},
                ],
              }
            ]),
            explanationJson: jsonEncode([
              {
                '_type': 'block',
                'children': [
                  {'_type': 'span', 'text': 'because y'},
                ],
              }
            ]),
          ),
        );
    await db.into(db.contentChoices).insert(
          ContentChoicesCompanion.insert(
            id: 'c_a',
            questionId: 'q1',
            label: 'A',
            textValue: 'x',
            isCorrect: false,
            ordering: 1,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentChoices).insert(
          ContentChoicesCompanion.insert(
            id: 'c_b',
            questionId: 'q1',
            label: 'B',
            textValue: 'y',
            isCorrect: true,
            ordering: 2,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentQuestionExams).insert(
          ContentQuestionExamsCompanion.insert(
            questionId: 'q1',
            examId: 'exam_cse_pro',
          ),
        );
  });

  tearDown(() => db.close());

  test('listExams returns exams with their nested subjects', () async {
    final exams = await repo.listExams();
    expect(exams, hasLength(1));
    expect(exams.first.id, equals('exam_cse_pro'));
    expect(exams.first.subjects, hasLength(1));
    expect(exams.first.subjects.first.id, equals('s1'));
  });

  test('questionsByTopic returns hydrated Question models', () async {
    final qs = await repo.questionsByTopic('t1');
    expect(qs, hasLength(1));
    expect(qs.first.choices, hasLength(2));
    expect(qs.first.correctChoice.id, equals('c_b'));
  });

  test('questionById returns null when not found', () async {
    expect(await repo.questionById('missing'), isNull);
  });

  test('lessonById returns Lesson when found', () async {
    final lesson = await repo.lessonById('l1');
    expect(lesson, isNotNull);
    expect(lesson!.id, equals('l1'));
    expect(lesson.title, equals('Vocabulary Basics'));
    expect(lesson.bodyJson, hasLength(1));
    expect(lesson.bodyJson.first['_type'], equals('block'));
  });

  test('lessonById returns null when not found', () async {
    expect(await repo.lessonById('missing'), isNull);
  });

  test('topicById returns Topic when found', () async {
    final topic = await repo.topicById('t1');
    expect(topic, isNotNull);
    expect(topic!.id, equals('t1'));
    expect(topic.name, equals('Vocabulary'));
  });

  test('topicById returns null when not found', () async {
    expect(await repo.topicById('nope'), isNull);
  });

  Future<void> insertLesson(String id, String title, {int? ordering}) {
    return db.into(db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: id,
            topicId: 't1',
            title: title,
            summary: 'Summary of $title',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 5,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
            ordering: ordering == null ? const Value.absent() : Value(ordering),
          ),
        );
  }

  test('lessons come back in their authored order', () async {
    await insertLesson('l_c', 'Third', ordering: 3);
    await insertLesson('l_a', 'First', ordering: 1);
    await insertLesson('l_b', 'Second', ordering: 2);

    final lessons = await repo.lessonsByTopic('t1');

    // l1 from setUp has no ordering, so it defaults to 0 and sorts first.
    expect(
      lessons.map((lesson) => lesson.id).toList(),
      ['l1', 'l_a', 'l_b', 'l_c'],
    );
  });

  test('lessons with no authored order fall back to id order', () async {
    await insertLesson('l_z', 'Zulu');
    await insertLesson('l_m', 'Mike');

    final lessons = await repo.lessonsByTopic('t1');

    expect(
      lessons.map((lesson) => lesson.id).toList(),
      ['l1', 'l_m', 'l_z'],
    );
  });

  test('an unplaced lesson reports ordering zero', () async {
    final lesson = await repo.lessonById('l1');

    expect(lesson!.ordering, 0);
  });

  test('lessonsByTopics groups by topic and keeps authored order', () async {
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't2',
            subjectId: 's1',
            name: 'Physics',
            ordering: 2,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await insertLesson('l_b', 'Second', ordering: 2);
    await insertLesson('l_a', 'First', ordering: 1);
    await db.into(db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: 'l_p',
            topicId: 't2',
            title: 'Physics one',
            summary: 'S.',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 7,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
            ordering: const Value(1),
          ),
        );

    final grouped = await repo.lessonsByTopics(['t1', 't2']);

    expect(grouped.keys.toSet(), {'t1', 't2'});
    expect(
      grouped['t1']!.map((lesson) => lesson.id).toList(),
      ['l1', 'l_a', 'l_b'],
    );
    expect(grouped['t2']!.single.id, 'l_p');
  });

  test('lessonsByTopics returns an empty list for a topic with no lessons',
      () async {
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't3',
            subjectId: 's1',
            name: 'Empty',
            ordering: 3,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );

    final grouped = await repo.lessonsByTopics(['t3']);

    expect(grouped['t3'], isEmpty);
  });

  test('lessonsByTopics with no topics does not query', () async {
    expect(await repo.lessonsByTopics([]), isEmpty);
  });
}
