import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentDatabase db;

  setUp(() {
    db = ContentDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('can insert and read from content_passages', () async {
    final updatedAt = DateTime.utc(2026);

    // Requires subject and topic first
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
            isCustom: const Value(false),
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

    // Insert passage
    await db.into(db.contentPassages).insert(
          ContentPassagesCompanion.insert(
            id: 'passage_001',
            schemaVersion: 1,
            isActive: const Value(true),
            updatedAt: updatedAt,
            topicId: 'topic_vocab',
            title: 'Test Passage',
            body: 'This is a test passage.',
            language: 'en',
            wordCount: 5,
          ),
        );

    final row = await db.select(db.contentPassages).getSingle();
    expect(row.id, equals('passage_001'));
    expect(row.title, equals('Test Passage'));
    expect(row.wordCount, equals(5));
  });
}
