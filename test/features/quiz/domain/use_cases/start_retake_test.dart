
import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_retake.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('start retake stores retake origin and dedupes missed question ids',
      () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_vocab',
      topicName: 'Vocab',
      questionIds: List.generate(30, (i) => 'q$i'),
    );
    final attempts = AttemptsRepository(db);
    await attempts.save(
      _attempt(
        id: 'a1',
        questionIds: const ['q_001', 'q_001', 'q_002'],
        completedAt: DateTime.utc(2026, 5, 18),
      ),
    );

    final result = await StartRetake(
      content: ContentRepository(contentDb),
      attempts: attempts,
      sessions: QuizSessionRepository(db),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 5, 18, 1),
    );

    final session = (result as StartRetakeStarted).session;
    expect(session.origin, SessionOrigin.retake);
    expect(
      session.questions.map((question) => question.id),
      ['q_001', 'q_002'],
    );

    final row = await QuizSessionRepository(db)
        .activeFor(userId: 'user', examId: 'exam_cse_pro');
    expect(row?.origin, SessionOrigin.retake.storageValue);
  });

  test('start retake caps the pool at 50 questions', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_vocab',
      topicName: 'Vocab',
      questionIds: List.generate(30, (i) => 'q$i'),
    );
    await _insertExtraQuestions(contentDb, count: 55);
    final attempts = AttemptsRepository(db);
    await attempts.save(
      _attempt(
        id: 'a1',
        questionIds: [for (var i = 0; i < 55; i++) 'extra_$i'],
        completedAt: DateTime.utc(2026, 5, 18),
      ),
    );

    final result = await StartRetake(
      content: ContentRepository(contentDb),
      attempts: attempts,
      sessions: QuizSessionRepository(db),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 5, 18, 1),
    );

    expect((result as StartRetakeStarted).session.questions, hasLength(50));
  });

  test('empty mistake pool returns an empty-state result', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_vocab',
      topicName: 'Vocab',
      questionIds: List.generate(30, (i) => 'q$i'),
    );

    final result = await StartRetake(
      content: ContentRepository(contentDb),
      attempts: AttemptsRepository(db),
      sessions: QuizSessionRepository(db),
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 5, 18, 1),
    );

    expect(result, isA<StartRetakeNoQuestions>());
  });
}

Attempt _attempt({
  required String id,
  required List<String> questionIds,
  required DateTime completedAt,
}) {
  return Attempt(
    id: id,
    examId: 'exam_cse_pro',
    origin: SessionOrigin.todayTopic.storageValue,
    startedAt: completedAt.subtract(const Duration(minutes: 5)),
    completedAt: completedAt,
    items: [
      for (final questionId in questionIds)
        AttemptItem(
          questionId: questionId,
          questionVersion: 1,
          chosenChoiceId: 'wrong',
          correctChoiceId: 'correct',
          responseMs: 1000,
        ),
    ],
  );
}

Future<void> _insertExtraQuestions(
  ContentDatabase contentDb, {
  required int count,
}) async {
  final topic = (await contentDb.select(contentDb.contentTopics).get()).first;
  const choices = [
    {'id': 'wrong', 'label': 'A', 'text': 'Wrong', 'isCorrect': false},
    {'id': 'correct', 'label': 'B', 'text': 'Correct', 'isCorrect': true},
  ];
  for (var i = 0; i < count; i++) {
    await seedContentQuestionWithChoices(
      contentDb,
      questionId: 'extra_$i',
      topicId: topic.id,
      examId: 'exam_cse_pro',
      choices: choices,
      stem: 'Extra $i',
      explanation: 'Explanation',
    );
  }
}
