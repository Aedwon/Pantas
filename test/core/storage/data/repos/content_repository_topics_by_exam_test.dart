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
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 's2',
            examId: 'e1',
            name: 'Numerical',
            ordering: 2,
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
            id: 't2',
            subjectId: 's2',
            name: 'Arithmetic',
            ordering: 1,
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
}
