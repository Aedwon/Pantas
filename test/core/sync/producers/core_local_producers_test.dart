import 'dart:convert';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:pantas/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:pantas/core/storage/data/repos/question_flags_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/review_state.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  Future<Map<String, Object?>> journal(String collection, String rowId) async {
    final row = await db.customSelect(
      'select collection,row_id,op,revision,mutation_epoch,causal_base_state '
      'from sync_local_mutations where collection = ? and row_id = ?',
      variables: [Variable<String>(collection), Variable<String>(rowId)],
    ).getSingle();
    return row.data;
  }

  Future<int> epoch() async {
    final row = await db
        .customSelect(
          "select value from sync_meta where key = 'localMutationEpoch'",
        )
        .getSingleOrNull();
    return row == null ? 0 : int.parse(row.read<String>('value'));
  }

  Future<void> seedUserDataDependencies() async {
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
    for (final id in ['l1', 'l2', 'l3']) {
      await db.into(db.lessons).insert(
            LessonsCompanion.insert(
              id: id,
              topicId: 't1',
              title: 'Lesson $id',
              summary: 'Summary',
              bodyJson: jsonEncode(<Map<String, Object?>>[]),
              estimatedMinutes: 5,
            ),
          );
    }
    for (final id in ['q1', 'q2']) {
      await db.into(db.questions).insert(
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
  }

  Attempt attempt({String id = 'a1'}) => Attempt(
        id: id,
        examId: 'e1',
        startedAt: DateTime.utc(2026, 8, 30),
        completedAt: DateTime.utc(2026, 8, 30, 0, 5),
        items: const [
          AttemptItem(
            questionId: 'q1',
            questionVersion: 1,
            chosenChoiceId: 'a',
            correctChoiceId: 'b',
            responseMs: 1000,
          ),
        ],
      );

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    await seedUserDataDependencies();
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test('attempt save journals once; maintenance writes do not journal',
      () async {
    final repo = AttemptsRepository(db);
    await repo.save(attempt());
    var row = await journal('quiz_attempts', 'a1');
    expect(row['op'], 'upsert');
    expect(row['revision'], 1);
    expect(await epoch(), 1);

    await repo.markSynced('a1');
    await repo.markFailed('a1', 'network');
    row = await journal('quiz_attempts', 'a1');
    expect(row['revision'], 1);
    expect(await epoch(), 1);
  });

  test('attempt tagItem causes exactly one resulting mutation through save',
      () async {
    final repo = AttemptsRepository(db);
    await repo.save(attempt());
    await repo.tagItem(
        attemptId: 'a1', questionId: 'q1', tag: MistakeTag.misread);
    final row = await journal('quiz_attempts', 'a1');
    expect(row['revision'], 2);
    expect(await epoch(), 2);
  });

  test('assessment result journals assessments atomically', () async {
    final repo = AssessmentRepository(db);
    await repo.saveResult(
      'e1',
      DateTime.utc(2026, 8, 30),
      [const TopicScore(topicId: 't1', correct: 2, total: 3)],
    );
    final row = await journal('assessments', 'e1');
    expect(row['op'], 'upsert');
    expect(await epoch(), 1);
  });

  test('review upsert journals fsrs card; markClean does not', () async {
    final repo = ReviewStateRepository(db);
    await repo.upsert(
      ReviewState.seed(
        questionId: 'q1',
        questionVersion: 1,
        now: DateTime.utc(2026, 8, 30),
      ),
    );
    await repo.markClean('q1');
    final row = await journal('fsrs_cards', 'q1');
    expect(row['revision'], 1);
    expect(await epoch(), 1);
  });

  test('lesson markRead journals lesson progress', () async {
    final repo = LessonProgressRepository(db, contentDb);
    await repo.markRead('l1');
    final row = await journal('lesson_progress', 'l1');
    expect(row['op'], 'upsert');
    expect(await epoch(), 1);
  });

  test('bookmark mark and unmark journal upsert then delete', () async {
    final repo = LessonBookmarksRepository(db);
    await repo.mark('l1');
    await repo.unmark('l1');
    final row = await journal('lesson_bookmarks', 'l1');
    expect(row['op'], 'delete');
    expect(row['revision'], 2);
    expect(await repo.isMarked('l1'), isFalse);
    expect(await epoch(), 2);
  });

  test('bookmark multi-row operations journal every affected logical row',
      () async {
    final repo = LessonBookmarksRepository(db);
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.mark('l3');
    await repo.reorder(['l3', 'l1', 'l2']);
    expect((await journal('lesson_bookmarks', 'l1'))['revision'], 2);
    expect((await journal('lesson_bookmarks', 'l2'))['revision'], 2);
    expect((await journal('lesson_bookmarks', 'l3'))['revision'], 2);

    await repo.clearCustomOrder();
    expect((await journal('lesson_bookmarks', 'l1'))['revision'], 3);
    expect((await journal('lesson_bookmarks', 'l2'))['revision'], 3);
    expect((await journal('lesson_bookmarks', 'l3'))['revision'], 3);

    await repo.unmarkAll(['l1', 'l3']);
    expect((await journal('lesson_bookmarks', 'l1'))['op'], 'delete');
    expect((await journal('lesson_bookmarks', 'l3'))['op'], 'delete');
    expect((await journal('lesson_bookmarks', 'l2'))['op'], 'upsert');
    expect(await repo.markedIds(), {'l2'});
    expect(await epoch(), 11);
  });

  test('question flag and unflag journal upsert then delete', () async {
    final repo = QuestionFlagsRepository(db);
    await repo.flag('q1');
    await repo.unflag('q1');
    final row = await journal('question_flags', 'q1');
    expect(row['op'], 'delete');
    expect(row['revision'], 2);
    expect(await repo.isFlagged('q1'), isFalse);
    expect(await epoch(), 2);
  });
}
