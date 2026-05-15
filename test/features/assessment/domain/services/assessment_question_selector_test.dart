import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentRepository content;
  late ReviewStateRepository reviewRepo;
  late AssessmentQuestionSelector selector;

  Future<void> seedExam() async {
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
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's2',
      examId: 'e1',
      name: 'Numerical',
      ordering: 2,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't2',
      subjectId: 's2',
      name: 'Arithmetic',
      ordering: 1,
    ));
  }

  Future<void> seedQuestion(String id, String topicId) async {
    final choices = [
      {'id': '${id}_a', 'label': 'A', 'text': 'Choice A', 'isCorrect': true},
      {'id': '${id}_b', 'label': 'B', 'text': 'Choice B', 'isCorrect': false},
    ];
    await db.into(db.questions).insert(QuestionsCompanion.insert(
      id: id,
      version: 1,
      examIdsJson: jsonEncode(['e1']),
      topicId: topicId,
      language: 'en',
      stem: 'Question $id?',
      choicesJson: jsonEncode(choices),
      explanation: 'Explanation for $id',
    ));
  }

  setUp(() async {
    db = inMemoryDatabase();
    content = ContentRepository(db);
    reviewRepo = ReviewStateRepository(db);
    selector = AssessmentQuestionSelector(content, reviewRepo);
    await seedExam();
  });

  tearDown(() => db.close());

  test('selects up to 3 questions per topic when more are available', () async {
    for (var i = 1; i <= 5; i++) {
      await seedQuestion('q_t1_$i', 't1');
      await seedQuestion('q_t2_$i', 't2');
    }

    final questions = await selector.select('e1');

    final t1Count = questions.where((q) => q.topicId == 't1').length;
    final t2Count = questions.where((q) => q.topicId == 't2').length;
    expect(t1Count, lessThanOrEqualTo(3));
    expect(t2Count, lessThanOrEqualTo(3));
  });

  test('prefers unseen (newCard) questions over seen ones', () async {
    for (final tid in ['t1', 't2']) {
      await seedQuestion('seen_$tid', tid);
      await seedQuestion('new_$tid', tid);
      await reviewRepo.upsert(ReviewState(
        questionId: 'seen_$tid',
        questionVersion: 1,
        stage: ReviewStage.review,
        stability: 10,
        difficulty: 5,
        due: DateTime(2026, 12, 1),
        lastReview: DateTime(2026, 1, 1),
        reps: 1,
        lapses: 0,
        elapsedDays: 1,
        scheduledDays: 10,
      ));
    }

    final questions = await selector.select('e1');
    final ids = questions.map((q) => q.question.id).toSet();

    expect(ids, contains('new_t1'));
    expect(ids, contains('new_t2'));
  });

  test('interleaves questions so first two come from different topics', () async {
    for (var i = 1; i <= 3; i++) {
      await seedQuestion('q_t1_$i', 't1');
      await seedQuestion('q_t2_$i', 't2');
    }

    final questions = await selector.select('e1');

    expect(questions.map((q) => q.topicId), containsAll(['t1', 't2']));
    if (questions.length >= 2) {
      expect(questions[0].topicId, isNot(equals(questions[1].topicId)));
    }
  });

  test('returns empty list when exam has no questions', () async {
    final questions = await selector.select('e1');
    expect(questions, isEmpty);
  });
}
