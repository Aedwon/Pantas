import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/features/assessment/domain/services/assessment_question_selector.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ContentRepository content;
  late ReviewStateRepository reviewRepo;
  late AssessmentQuestionSelector selector;

  Future<void> seedExam() async {
    await seedContentExam(contentDb, examId: 'e1', code: 'CSE', name: 'CSE');
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's2',
      examId: 'e1',
      name: 'Numerical',
      ordering: 2,
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't2',
      subjectId: 's2',
      name: 'Arithmetic',
    );
  }

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
    content = ContentRepository(contentDb);
    reviewRepo = ReviewStateRepository(db);
    selector = AssessmentQuestionSelector(content, reviewRepo);
    await seedExam();
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test('selects from metadata before hydrating only chosen questions',
      () async {
    for (var i = 1; i <= 5; i++) {
      await seedQuestion('q_t1_$i', 't1');
      await seedQuestion('q_t2_$i', 't2');
    }

    final metadataFirstSelector = AssessmentQuestionSelector(
      _RejectFullTopicHydrationRepository(contentDb),
      reviewRepo,
    );

    final questions = await metadataFirstSelector.select('e1');

    expect(questions, hasLength(6));
  });

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
      await reviewRepo.upsert(
        ReviewState(
          questionId: 'seen_$tid',
          questionVersion: 1,
          stage: ReviewStage.review,
          stability: 10,
          difficulty: 5,
          due: DateTime(2026, 12),
          lastReview: DateTime(2026),
          reps: 1,
          lapses: 0,
          elapsedDays: 1,
          scheduledDays: 10,
        ),
      );
    }

    final questions = await selector.select('e1');
    final ids = questions.map((q) => q.question.id).toSet();

    expect(ids, contains('new_t1'));
    expect(ids, contains('new_t2'));
  });

  test('interleaves questions so first two come from different topics',
      () async {
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

  test('topics with no questions do not shrink the per-topic budget', () async {
    // Mirrors the dev seed: an exam with many topics where only a few have
    // authored questions. Budgeting off the full topic count collapsed the
    // assessment to one question per contributing topic.
    await seedContentSubject(
      contentDb,
      subjectId: 's_empty',
      examId: 'e1',
      name: 'Unauthored',
      ordering: 3,
    );
    for (var i = 1; i <= 16; i++) {
      await seedContentTopic(
        contentDb,
        topicId: 't_empty_$i',
        subjectId: 's_empty',
        name: 'Empty $i',
        ordering: i,
      );
    }
    for (var i = 1; i <= 5; i++) {
      await seedQuestion('q_t1_$i', 't1');
      await seedQuestion('q_t2_$i', 't2');
    }

    final questions = await selector.select('e1');

    expect(questions, hasLength(6));
    expect(questions.where((q) => q.topicId == 't1'), hasLength(3));
    expect(questions.where((q) => q.topicId == 't2'), hasLength(3));
  });

  test('respects the 30-question cap when topic count exceeds 30', () async {
    await seedContentSubject(
      contentDb,
      subjectId: 's_many',
      examId: 'e1',
      name: 'Mixed',
      ordering: 3,
    );

    for (var i = 1; i <= 36; i++) {
      final topicId = 't_many_$i';
      await seedContentTopic(
        contentDb,
        topicId: topicId,
        subjectId: 's_many',
        name: 'Topic $i',
        ordering: i,
      );
      await seedQuestion('q_many_$i', topicId);
    }

    final questions = await selector.select('e1');

    expect(questions, isNotEmpty);
    expect(questions, hasLength(30));
    expect(questions.map((q) => q.topicId).toSet(), hasLength(30));
  });
}

class _RejectFullTopicHydrationRepository extends ContentRepository {
  _RejectFullTopicHydrationRepository(super.db);

  @override
  Future<List<Question>> questionsByTopic(String topicId) => throw StateError(
        'assessment selector fully hydrated candidate topic $topicId',
      );
}
