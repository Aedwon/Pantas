import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/use_cases/start_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

StartAssessment _makeUseCase(AppDatabase db, ContentDatabase contentDb) {
  final content = ContentRepository(contentDb);
  final review = ReviewStateRepository(db);
  return StartAssessment(AssessmentQuestionSelector(content, review));
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late StartAssessment useCase;

  Future<void> seedQuestion(String id, String topicId) async {
    await seedContentQuestion(
      contentDb,
      questionId: id,
      topicId: topicId,
      examId: 'e1',
    );
  }

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    useCase = _makeUseCase(db, contentDb);

    await seedContentExam(contentDb, examId: 'e1', code: 'CSE', name: 'CSE');
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    await seedQuestion('q1', 't1');
    await seedQuestion('q2', 't1');
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test('returns session with correct examId', () async {
    final session = await useCase.call('e1');
    expect(session.examId, equals('e1'));
  });

  test('all answers are null initially', () async {
    final session = await useCase.call('e1');
    expect(session.questions, isNotEmpty);
    for (final q in session.questions) {
      expect(session.answers[q.question.id], isNull);
    }
  });

  test('throws StateError when exam has no questions', () async {
    await seedContentExam(
      contentDb,
      examId: 'empty',
      code: 'XX',
      name: 'Empty',
      ordering: 2,
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's_empty',
      examId: 'empty',
      name: 'S',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't_empty',
      subjectId: 's_empty',
      name: 'T',
    );

    expect(
      useCase.call('empty'),
      throwsStateError,
    );
  });
}
