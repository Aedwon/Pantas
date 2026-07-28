import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

/// A withdrawn question must vanish from every picker and stay readable by id.
/// A student's history names questions they answered months ago; withdrawing
/// one must not blank out the row that records their answer.
///
/// This used to arrive through the asset seeder. The corpus now comes from the
/// content database instead, so the guarantee is asserted against the
/// repository that enforces it rather than against the loader that fed it.
void main() {
  test(
      'withdrawn question is excluded from pickers '
      'but accessible by id for history', () async {
    final db = inMemoryContentDatabase();
    addTearDown(db.close);

    await seedContentExam(db, examId: 'e1', code: 'CSE');
    await seedContentSubject(db, subjectId: 's1', examId: 'e1');
    await seedContentTopic(db, topicId: 't1', subjectId: 's1');
    await seedContentQuestion(
      db,
      questionId: 'q1',
      topicId: 't1',
      examId: 'e1',
      stem: 'Active question',
    );
    await seedContentQuestion(
      db,
      questionId: 'q2',
      topicId: 't1',
      examId: 'e1',
      stem: 'Withdrawn question',
      isActive: false,
    );

    final repo = ContentRepository(db);

    final activeQuestions = await repo.questionsByTopic('t1');
    expect(activeQuestions.map((q) => q.id), contains('q1'));
    expect(activeQuestions.map((q) => q.id), isNot(contains('q2')));

    final withdrawnQuestion = await repo.questionById('q2');
    expect(withdrawnQuestion, isNotNull);
    expect(withdrawnQuestion!.stem, equals('Withdrawn question'));
  });
}
