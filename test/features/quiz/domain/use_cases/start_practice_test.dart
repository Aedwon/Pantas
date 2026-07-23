import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_selection.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_practice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:drift/native.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('each unit contributes its own questions', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: [for (var i = 1; i <= 20; i++) 'q1_$i'],
    );
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_2',
      topicName: 'Topic 2',
      questionIds: [for (var i = 1; i <= 20; i++) 'q2_$i'],
    );

    final startPractice = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
    );

    final result = await startPractice(
      userId: 'user_1',
      examId: 'exam_cse_pro',
      units: const [
        PracticeUnit(topicId: 'topic_1'),
        PracticeUnit(topicId: 'topic_2'),
      ],
      perUnit: 5,
      now: DateTime.utc(2026, 8),
    );

    expect(result, isA<StartPracticeStarted>());
    final session = (result as StartPracticeStarted).session;
    expect(session.questions, hasLength(10));
    expect(
      session.questions.where((q) => q.topicId == 'topic_1'),
      hasLength(5),
    );
    expect(
      session.questions.where((q) => q.topicId == 'topic_2'),
      hasLength(5),
    );
  });

  test('a short pool contributes what it has', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_short',
      topicName: 'Short Topic',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );

    final startPractice = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
    );

    final result = await startPractice(
      userId: 'user_1',
      examId: 'exam_cse_pro',
      units: const [PracticeUnit(topicId: 'topic_short')],
      perUnit: 5,
      now: DateTime.utc(2026, 8),
    );

    expect(result, isA<StartPracticeStarted>());
    final session = (result as StartPracticeStarted).session;
    expect(session.questions, hasLength(3));
  });

  test('no units means no session', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);

    final startPractice = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
    );

    final result = await startPractice(
      userId: 'user_1',
      examId: 'exam_cse_pro',
      units: const [],
      perUnit: 5,
      now: DateTime.utc(2026, 8),
    );

    expect(result, isA<StartPracticeNoQuestions>());
  });

  test('the session is recorded as a drill', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: ['q_1'],
    );

    final startPractice = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
    );

    final result = await startPractice(
      userId: 'user_1',
      examId: 'exam_cse_pro',
      units: const [PracticeUnit(topicId: 'topic_1')],
      perUnit: 5,
      now: DateTime.utc(2026, 8),
    );

    final session = (result as StartPracticeStarted).session;
    expect(session.origin, SessionOrigin.drill);

    final row = await QuizSessionRepository(db)
        .activeFor(userId: 'user_1', examId: 'exam_cse_pro');
    expect(row?.origin, SessionOrigin.drill.storageValue);
  });

  test('a lesson unit draws only that lesson', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: ['q_l1_1', 'q_l2_1'],
      lessonIds: ['lesson_1', 'lesson_2'],
      questionLessonMap: {
        'q_l1_1': 'lesson_1',
        'q_l2_1': 'lesson_2',
      },
    );

    final startPractice = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
    );

    final result = await startPractice(
      userId: 'user_1',
      examId: 'exam_cse_pro',
      units: const [PracticeUnit(topicId: 'topic_1', lessonId: 'lesson_1')],
      perUnit: 5,
      now: DateTime.utc(2026, 8),
    );

    final session = (result as StartPracticeStarted).session;
    expect(session.questions, hasLength(1));
    expect(session.questions.single.id, 'q_l1_1');
  });

  test('fromQuestionIds creates session with exact question list', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );

    final startPractice = StartPractice(
      content: ContentRepository(contentDb),
      sessions: QuizSessionRepository(db),
      attempts: AttemptsRepository(db),
    );

    final result = await startPractice.fromQuestionIds(
      userId: 'user_1',
      examId: 'exam_cse_pro',
      questionIds: const ['q_1', 'q_3'],
      now: DateTime.utc(2026, 8),
    );

    expect(result, isA<StartPracticeStarted>());
    final session = (result as StartPracticeStarted).session;
    expect(session.questions.map((q) => q.id), equals(['q_1', 'q_3']));
  });
}
