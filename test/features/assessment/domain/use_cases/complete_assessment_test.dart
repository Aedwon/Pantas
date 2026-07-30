import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/features/assessment/domain/models/assessment_question.dart';
import 'package:pantas/features/assessment/domain/models/assessment_session.dart';
import 'package:pantas/features/assessment/domain/use_cases/complete_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late AssessmentRepository assessmentRepo;
  late ReviewStateRepository reviewRepo;
  late ContentRepository contentRepo;
  late AttemptsRepository attemptsRepo;
  late CompleteAssessment useCase;

  // Returns (correctChoiceId, wrongChoiceId).
  Future<(String, String)> seedQuestion(String id, String topicId) async {
    await seedContentQuestion(
      contentDb,
      questionId: id,
      topicId: topicId,
      examId: 'e1',
    );
    return ('${id}_a', '${id}_b');
  }

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    assessmentRepo = AssessmentRepository(db);
    reviewRepo = ReviewStateRepository(db);
    contentRepo = ContentRepository(contentDb);
    attemptsRepo = AttemptsRepository(db);
    useCase = CompleteAssessment(
      assessmentRepo: assessmentRepo,
      reviewRepo: reviewRepo,
      scheduler: const FsrsScheduler(),
      contentRepo: contentRepo,
      attemptsRepo: attemptsRepo,
    );

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
      ordering: 2,
    );
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test('saveResult is called once and result is retrievable', () async {
    final (correctId, _) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': correctId},
    );

    await useCase.call(session: session, now: DateTime(2026));
    expect(await assessmentRepo.hasCompletedForExam('e1'), isTrue);
  });

  test('per-topic scores are correct', () async {
    final (correctId, wrongId) = await seedQuestion('q1', 't1');
    await seedQuestion('q2', 't1');
    final (correctId2, _) = await seedQuestion('q3', 't2');

    final q1 = (await contentRepo.questionsByTopic('t1'))
        .firstWhere((q) => q.id == 'q1');
    final q2 = (await contentRepo.questionsByTopic('t1'))
        .firstWhere((q) => q.id == 'q2');
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

    final result = await useCase.call(session: session, now: DateTime(2026));

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
        'q1': wrongId, // t1: 0/1 = weak
        'q2': correctId2, // t2: 1/1 = strong
      },
    );

    final result = await useCase.call(session: session, now: DateTime(2026));

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

    await useCase.call(session: session, now: DateTime(2026));

    final rs = await reviewRepo.byQuestionId('q1');
    expect(rs, isNotNull);
    expect(rs!.reps, equals(1));
    expect(rs.stage, equals(ReviewStage.review));
  });

  test('incorrect answer seeds FSRS with again rating → learning stage',
      () async {
    final (_, wrongId) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': wrongId},
    );

    await useCase.call(session: session, now: DateTime(2026));

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

    await useCase.call(session: session, now: DateTime(2026));
    expect(await reviewRepo.byQuestionId('q1'), isNull);
  });

  test('writes one attempt row, with origin assessment and no timing',
      () async {
    final (correctId, _) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': correctId},
    );
    final now = DateTime(2026);
    await useCase(session: session, now: now);

    final savedRows = await db.select(db.attemptsLocal).get();
    expect(savedRows, hasLength(1));
    final attemptRow = savedRows.single;
    expect(attemptRow.origin, 'assessment');
    expect(attemptRow.examId, session.examId);
    expect(attemptRow.completedAt, now);

    final attempt = await attemptsRepo.byId(attemptRow.id);
    expect(attempt, isNotNull);
    expect(attempt!.items.every((i) => i.responseMs == 0), isTrue);
  });

  test('an unanswered question is not written as a wrong answer', () async {
    final (correctId, _) = await seedQuestion('q1', 't1');
    await seedQuestion('q2', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1'))
        .firstWhere((q) => q.id == 'q1');
    final q2 = (await contentRepo.questionsByTopic('t1'))
        .firstWhere((q) => q.id == 'q2');

    final session = AssessmentSession(
      examId: 'e1',
      questions: [
        AssessmentQuestion(question: q1, topicId: 't1'),
        AssessmentQuestion(question: q2, topicId: 't1'),
      ],
      answers: {
        'q1': correctId,
        'q2': null, // unanswered
      },
    );
    await useCase(session: session, now: DateTime(2026));

    final savedRows = await db.select(db.attemptsLocal).get();
    final attempt = await attemptsRepo.byId(savedRows.single.id);
    expect(attempt!.items, hasLength(1));
    expect(attempt.items.single.questionId, 'q1');
  });

  test('the item carries the chosen and the correct choice', () async {
    final (correctId, wrongId) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': wrongId},
    );
    await useCase(session: session, now: DateTime(2026));

    final savedRows = await db.select(db.attemptsLocal).get();
    final attempt = await attemptsRepo.byId(savedRows.single.id);
    final item = attempt!.items.firstWhere((i) => i.questionId == 'q1');
    expect(item.isCorrect, isFalse);
    expect(item.chosenChoiceId, wrongId);
    expect(item.correctChoiceId, correctId);
  });
}
