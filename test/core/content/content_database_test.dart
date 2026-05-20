import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentDatabase db;

  setUp(() {
    db = ContentDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<List<String>> tableNames(GeneratedDatabase database) async {
    final rows = await database
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name not like 'sqlite_%' order by name",
        )
        .get();
    return rows.map((row) => row.read<String>('name')).toList();
  }

  test('content database creates all content tables at schema version 1',
      () async {
    expect(db.schemaVersion, equals(1));
    expect(
      await tableNames(db),
      containsAll(<String>[
        'content_exams',
        'content_subjects',
        'content_topics',
        'content_questions',
        'content_choices',
        'content_question_exams',
        'content_lessons',
        'content_mock_blueprints',
        'content_mock_exams',
        'content_diagnostic_sets',
        'content_meta',
      ]),
    );
  });

  test('content_question_exams enforces composite uniqueness', () async {
    final updatedAt = DateTime.utc(2026);
    await db.into(db.contentExams).insert(
          ContentExamsCompanion.insert(
            id: 'exam_cse',
            schemaVersion: 1,
            updatedAt: updatedAt,
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
            ordering: 1,
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 'subject_verbal',
            schemaVersion: 1,
            updatedAt: updatedAt,
            examId: 'exam_cse',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 'topic_vocab',
            schemaVersion: 1,
            updatedAt: updatedAt,
            subjectId: 'subject_verbal',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.contentQuestions).insert(
          ContentQuestionsCompanion.insert(
            id: 'q_001',
            schemaVersion: 1,
            updatedAt: updatedAt,
            topicId: 'topic_vocab',
            language: 'en',
            stemJson: '[]',
            explanationJson: '[]',
            version: 1,
          ),
        );

    await db.into(db.contentQuestionExams).insert(
          ContentQuestionExamsCompanion.insert(
            questionId: 'q_001',
            examId: 'exam_cse',
          ),
        );

    expect(
      () => db.into(db.contentQuestionExams).insert(
            ContentQuestionExamsCompanion.insert(
              questionId: 'q_001',
              examId: 'exam_cse',
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('app database schema does not include content tables', () async {
    final appDb = AppDatabase(NativeDatabase.memory());
    addTearDown(appDb.close);

    expect(
      await tableNames(appDb),
      isNot(contains('content_exams')),
    );
  });

  test('content_meta upserts key value rows', () async {
    await db.into(db.contentMeta).insert(
          ContentMetaCompanion.insert(
            key: 'lastSyncedAt',
            value: '2026-05-17T00:00:00.000Z',
          ),
        );
    await db.into(db.contentMeta).insertOnConflictUpdate(
          ContentMetaCompanion.insert(
            key: 'lastSyncedAt',
            value: '2026-05-17T06:00:00.000Z',
          ),
        );

    final row = await db.select(db.contentMeta).getSingle();
    expect(row.value, equals('2026-05-17T06:00:00.000Z'));
  });
}
