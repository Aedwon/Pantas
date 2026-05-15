import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/use_cases/start_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

StartAssessment _makeUseCase(AppDatabase db) {
  final content = ContentRepository(db);
  final review = ReviewStateRepository(db);
  return StartAssessment(AssessmentQuestionSelector(content, review));
}

void main() {
  late AppDatabase db;
  late StartAssessment useCase;

  Future<void> seedQuestion(String id, String topicId) async {
    final choices = [
      {'id': '${id}_a', 'label': 'A', 'text': 'Option A', 'isCorrect': true},
      {'id': '${id}_b', 'label': 'B', 'text': 'Option B', 'isCorrect': false},
    ];
    await db.into(db.questions).insert(QuestionsCompanion.insert(
      id: id,
      version: 1,
      examIdsJson: jsonEncode(['e1']),
      topicId: topicId,
      language: 'en',
      stem: 'Question $id?',
      choicesJson: jsonEncode(choices),
      explanation: 'Explanation',
    ));
  }

  setUp(() async {
    db = inMemoryDatabase();
    useCase = _makeUseCase(db);

    await db.into(db.exams).insert(ExamsCompanion.insert(
      id: 'e1',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
      language: 'en',
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's1',
      examId: 'e1',
      name: 'Verbal',
      ordering: 1,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    ));
    await seedQuestion('q1', 't1');
    await seedQuestion('q2', 't1');
  });

  tearDown(() => db.close());

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
    final emptyDb = inMemoryDatabase();
    addTearDown(() => emptyDb.close());
    await emptyDb.into(emptyDb.exams).insert(ExamsCompanion.insert(
      id: 'empty',
      code: 'XX',
      name: 'Empty',
      shortName: 'XX',
      language: 'en',
    ));
    await emptyDb.into(emptyDb.subjects).insert(SubjectsCompanion.insert(
      id: 's_empty',
      examId: 'empty',
      name: 'S',
      ordering: 1,
    ));
    await emptyDb.into(emptyDb.topics).insert(TopicsCompanion.insert(
      id: 't_empty',
      subjectId: 's_empty',
      name: 'T',
      ordering: 1,
    ));

    expect(
      () => _makeUseCase(emptyDb).call('empty'),
      throwsStateError,
    );
  });
}
