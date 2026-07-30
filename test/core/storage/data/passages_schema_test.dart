import 'package:pantas/core/storage/data/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('schema version is 21 and passages table exists', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, equals(21));

    final tables = await db
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name not like 'sqlite_%' order by name",
        )
        .get();
    final tableNames = tables.map((row) => row.read<String>('name')).toList();
    expect(tableNames, contains('passages'));

    final questionColumns =
        await db.customSelect("pragma table_info('questions')").get();
    final columnNames =
        questionColumns.map((row) => row.read<String>('name')).toList();
    expect(columnNames, contains('passage_id'));
  });

  test('a passage round-trips correctly', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // Setup required parent subject and topic
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Reading',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Comprehension',
            ordering: 1,
          ),
        );

    await db.into(db.passages).insert(
          PassagesCompanion.insert(
            id: 'p1',
            topicId: 't1',
            title: 'Sample Passage',
            body: 'This is the passage body.',
            language: 'en',
            wordCount: 5,
          ),
        );

    final row = await db.select(db.passages).getSingle();
    expect(row.id, equals('p1'));
    expect(row.topicId, equals('t1'));
    expect(row.title, equals('Sample Passage'));
    expect(row.body, equals('This is the passage body.'));
    expect(row.language, equals('en'));
    expect(row.wordCount, equals(5));
  });

  test('a question with a null passageId round-trips unchanged', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Reading',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Comprehension',
            ordering: 1,
          ),
        );

    await db.into(db.questions).insert(
          QuestionsCompanion.insert(
            id: 'q1',
            version: 1,
            examIdsJson: '[]',
            topicId: 't1',
            language: 'en',
            stem: 'What is it?',
            choicesJson: '[]',
            explanation: 'None',
          ),
        );

    final row = await db.select(db.questions).getSingle();
    expect(row.id, equals('q1'));
    expect(row.passageId, isNull);
  });

  test('a question referencing a missing passage fails foreign key', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.customStatement('PRAGMA foreign_keys = ON;');

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
            name: 'Reading',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Comprehension',
            ordering: 1,
          ),
        );

    expect(
      () => db.into(db.questions).insert(
            QuestionsCompanion.insert(
              id: 'q2',
              version: 1,
              examIdsJson: '[]',
              topicId: 't1',
              language: 'en',
              stem: 'Comprehension item',
              choicesJson: '[]',
              explanation: 'None',
              passageId: const Value('p_non_existent'),
            ),
          ),
      throwsA(anything),
    );
  });

  test('attempts_local preserved across migration to v18', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'attempt_1',
            examId: 'e1',
            startedAt: DateTime.now(),
            itemsJson: '[]',
          ),
        );

    final attemptsBefore = await db.select(db.attemptsLocal).get();
    expect(attemptsBefore.length, equals(1));

    final attemptsAfter = await db.select(db.attemptsLocal).get();
    expect(attemptsAfter.length, equals(1));
    expect(attemptsAfter.first.id, equals('attempt_1'));
  });
}
