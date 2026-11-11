import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';

void main() {
  late ContentDatabase db;
  late ContentRepository repo;
  final now = DateTime.utc(2026, 8, 11);

  setUp(() async {
    db = ContentDatabase(NativeDatabase.memory());
    repo = ContentRepository(db);

    await db.into(db.contentExams).insert(
          ContentExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
            ordering: 1,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 's2',
            examId: 'e1',
            name: 'Numerical',
            ordering: 2,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't2',
            subjectId: 's2',
            name: 'Arithmetic',
            ordering: 1,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
  });

  tearDown(() => db.close());

  test('topicsByExam returns all topics across all subjects', () async {
    final topics = await repo.topicsByExam('e1');
    expect(topics.map((t) => t.id).toSet(), equals({'t1', 't2'}));
  });

  test('topicsByExam returns empty list for unknown exam', () async {
    final topics = await repo.topicsByExam('unknown');
    expect(topics, isEmpty);
  });

  test(
      'topicsByExam includes a topic owned by another exam when this exam '
      'tags its questions', () async {
    await db.into(db.contentExams).insert(
          ContentExamsCompanion.insert(
            id: 'e2',
            code: 'UP',
            name: 'Other exam',
            shortName: 'UP',
            language: 'en',
            ordering: 2,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 's3',
            examId: 'e2',
            name: 'Mathematics',
            ordering: 1,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't3',
            subjectId: 's3',
            name: 'Number sense',
            ordering: 1,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
    await db.into(db.contentTopics).insert(
          ContentTopicsCompanion.insert(
            id: 't4',
            subjectId: 's3',
            name: 'Geometry',
            ordering: 2,
            schemaVersion: 1,
            updatedAt: now,
          ),
        );
    Future<void> question(String id, String topicId, String examId) async {
      await db.into(db.contentQuestions).insert(
            ContentQuestionsCompanion.insert(
              id: id,
              schemaVersion: 1,
              updatedAt: now,
              topicId: topicId,
              language: 'en',
              stemJson: '[]',
              explanationJson: '[]',
              version: 1,
            ),
          );
      await db.into(db.contentQuestionExams).insert(
            ContentQuestionExamsCompanion.insert(
              questionId: id,
              examId: examId,
            ),
          );
    }

    // e1 tags number sense (twice) and an own topic; only e2 tags geometry.
    await question('q1', 't3', 'e1');
    await question('q2', 't3', 'e1');
    await question('q3', 't1', 'e1');
    await question('q4', 't4', 'e2');

    final topics = await repo.topicsByExam('e1');

    expect(topics.map((t) => t.id), ['t1', 't2', 't3']);
  });
}
