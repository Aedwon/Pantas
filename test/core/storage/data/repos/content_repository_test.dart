import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentRepository repo;

  setUp(() async {
    db = inMemoryDatabase();
    repo = ContentRepository(db);

    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_cse_pro',
            code: 'CSE_PRO',
            name: 'CSE Pro',
            shortName: 'CSE Pro',
            language: 'en',
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
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Vocabulary Basics',
            summary: 'Core vocabulary concepts',
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
    await db.into(db.questions).insert(
          QuestionsCompanion.insert(
            id: 'q1',
            version: 1,
            examIdsJson: jsonEncode(['exam_cse_pro']),
            topicId: 't1',
            language: 'en',
            stem: 'stem',
            choicesJson: jsonEncode([
              {'id': 'c_a', 'label': 'A', 'text': 'x', 'isCorrect': false},
              {'id': 'c_b', 'label': 'B', 'text': 'y', 'isCorrect': true},
            ]),
            explanation: 'because y',
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
    return db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: id,
            topicId: 't1',
            title: title,
            summary: 'Summary of $title',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 5,
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
}
