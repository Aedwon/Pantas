import 'dart:convert';

import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_question.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_session.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/use_cases/complete_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AssessmentRepository assessmentRepo;
  late ReviewStateRepository reviewRepo;
  late ContentRepository contentRepo;
  late CompleteAssessment useCase;

  // Returns (correctChoiceId, wrongChoiceId).
  Future<(String, String)> seedQuestion(String id, String topicId) async {
    final correctId = '${id}_correct';
    final wrongId = '${id}_wrong';
    final choices = [
      {'id': correctId, 'label': 'A', 'text': 'Correct', 'isCorrect': true},
      {'id': wrongId, 'label': 'B', 'text': 'Wrong', 'isCorrect': false},
    ];
    await db.into(db.questions).insert(QuestionsCompanion.insert(
      id: id,
      version: 1,
      examIdsJson: jsonEncode(['e1']),
      topicId: topicId,
      language: 'en',
      stem: 'Q $id?',
      choicesJson: jsonEncode(choices),
      explanation: '',
    ));
    return (correctId, wrongId);
  }

  setUp(() async {
    db = inMemoryDatabase();
    assessmentRepo = AssessmentRepository(db);
    reviewRepo = ReviewStateRepository(db);
    contentRepo = ContentRepository(db);
    useCase = CompleteAssessment(
      assessmentRepo: assessmentRepo,
      reviewRepo: reviewRepo,
      scheduler: const FsrsScheduler(),
      contentRepo: contentRepo,
    );

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
      ordering: 2,
    ));
  });

  tearDown(() => db.close());

  test('saveResult is called once and result is retrievable', () async {
    final (correctId, _) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': correctId},
    );

    await useCase.call(session: session, now: DateTime(2026, 1, 1));
    expect(await assessmentRepo.hasCompletedForExam('e1'), isTrue);
  });

  test('per-topic scores are correct', () async {
    final (correctId, wrongId) = await seedQuestion('q1', 't1');
    await seedQuestion('q2', 't1');
    final (correctId2, _) = await seedQuestion('q3', 't2');

    final q1 = (await contentRepo.questionsByTopic('t1')).firstWhere((q) => q.id == 'q1');
    final q2 = (await contentRepo.questionsByTopic('t1')).firstWhere((q) => q.id == 'q2');
    final q3 = (await contentRepo.questionsByTopic('t2')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [
        AssessmentQuestion(question: q1, topicId: 't1'),
        AssessmentQuestion(question: q2, topicId: 't1'),
        AssessmentQuestion(question: q3, topicId: 't2'),
      ],
      answers: {
        'q1': correctId,
        'q2': wrongId,
        'q3': correctId2,
      },
    );

    final result = await useCase.call(session: session, now: DateTime(2026, 1, 1));

    final t1 = result.topicMasteries.firstWhere((m) => m.topic.id == 't1');
    final t2 = result.topicMasteries.firstWhere((m) => m.topic.id == 't2');
    expect(t1.correct, equals(1));
    expect(t1.total, equals(2));
    expect(t2.correct, equals(1));
    expect(t2.total, equals(1));
  });

  test('topicMasteries sorted weakest-first', () async {
    final (_, wrongId) = await seedQuestion('q1', 't1');
    final (correctId2, _) = await seedQuestion('q2', 't2');

    final q1 = (await contentRepo.questionsByTopic('t1')).first;
    final q2 = (await contentRepo.questionsByTopic('t2')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [
        AssessmentQuestion(question: q1, topicId: 't1'),
        AssessmentQuestion(question: q2, topicId: 't2'),
      ],
      answers: {
        'q1': wrongId,    // t1: 0/1 = weak
        'q2': correctId2, // t2: 1/1 = strong
      },
    );

    final result = await useCase.call(session: session, now: DateTime(2026, 1, 1));

    expect(result.topicMasteries.first.topic.id, equals('t1'));
    expect(result.topicMasteries.last.topic.id, equals('t2'));
  });

  test('correct answer seeds FSRS with good rating → review stage', () async {
    final (correctId, _) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': correctId},
    );

    await useCase.call(session: session, now: DateTime(2026, 1, 1));

    final rs = await reviewRepo.byQuestionId('q1');
    expect(rs, isNotNull);
    expect(rs!.reps, equals(1));
    expect(rs.stage, equals(ReviewStage.review));
  });

  test('incorrect answer seeds FSRS with again rating → learning stage', () async {
    final (_, wrongId) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': wrongId},
    );

    await useCase.call(session: session, now: DateTime(2026, 1, 1));

    final rs = await reviewRepo.byQuestionId('q1');
    expect(rs, isNotNull);
    expect(rs!.reps, equals(1));
    expect(rs.stage, equals(ReviewStage.learning));
  });

  test('unanswered questions are skipped for FSRS', () async {
    await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': null}, // unanswered
    );

    await useCase.call(session: session, now: DateTime(2026, 1, 1));
    expect(await reviewRepo.byQuestionId('q1'), isNull);
  });
}
