import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/question_flags_repository.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late QuestionFlagsRepository repo;

  Future<void> insertQuestion(String id) {
    return db.into(db.questions).insert(
          QuestionsCompanion.insert(
            id: id,
            version: 1,
            examIdsJson: jsonEncode(['e1']),
            topicId: 't1',
            language: 'en',
            stem: 'Stem $id',
            choicesJson: jsonEncode(<Map<String, Object?>>[]),
            explanation: 'Because.',
          ),
        );
  }

  setUp(() async {
    db = inMemoryDatabase();
    repo = QuestionFlagsRepository(db);

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
            name: 'Science',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Chemistry',
            ordering: 1,
          ),
        );
    await insertQuestion('q1');
    await insertQuestion('q2');
  });

  tearDown(() => db.close());

  test('flagging a question makes it flagged', () async {
    await repo.flag('q1');

    expect(await repo.isFlagged('q1'), isTrue);
    expect(await repo.isFlagged('q2'), isFalse);
    expect(await repo.flagCount(), 1);
    expect(await repo.flaggedIds(), {'q1'});
  });

  test('flagging twice keeps one row and refreshes the timestamp', () async {
    await repo.flag('q1');
    final first =
        (await db.select(db.questionFlagsLocal).get()).single.flaggedAt;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.flag('q1');

    final rows = await db.select(db.questionFlagsLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.flaggedAt.isAfter(first), isTrue);
  });

  test('unflagging removes the row', () async {
    await repo.flag('q1');
    await repo.unflag('q1');

    expect(await repo.isFlagged('q1'), isFalse);
    expect(await repo.flagCount(), 0);
  });

  test('unflagging something never flagged is a no-op', () async {
    await repo.unflag('q2');

    expect(await repo.flagCount(), 0);
  });

  test('flags come back newest first, and sortIndex wins when set', () async {
    await repo.flag('q1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.flag('q2');

    expect(
      (await repo.flagsNewestFirst()).map((row) => row.questionId).toList(),
      ['q2', 'q1'],
    );

    await (db.update(db.questionFlagsLocal)
          ..where((row) => row.questionId.equals('q1')))
        .write(const QuestionFlagsLocalCompanion(sortIndex: Value(0)));

    expect(
      (await repo.flagsNewestFirst()).map((row) => row.questionId).toList(),
      ['q1', 'q2'],
    );
  });

  test('a new flag is pending sync', () async {
    await repo.flag('q1');

    final row = (await db.select(db.questionFlagsLocal).get()).single;
    expect(row.syncState, 'pending');
  });
}
