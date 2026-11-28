// Nov 22 2026 audit: a session shows passage questions grouped together
// (QuizSession.start), but Retake, Today, Drill, the in-lesson quiz and
// Restart stored the order from before grouping. When a passage's questions
// were split by another question, the second one failed its save with "Could
// not save your progress", because the stored order did not match what was on
// screen. The stored order must be the order the student sees.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/restart_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_retake.dart';

import '../../../../helpers/in_memory_database.dart';

const _exam = 'exam_cse_pro';

Future<void> _seed(ContentDatabase db, String id, {String? passageId}) =>
    seedContentQuestionWithChoices(
      db,
      questionId: id,
      topicId: 'topic_cse_rc',
      examId: _exam,
      passageId: passageId,
      choices: [
        {'id': '${id}_a', 'label': 'A', 'text': 'Right', 'isCorrect': true},
        {'id': '${id}_b', 'label': 'B', 'text': 'Wrong', 'isCorrect': false},
      ],
    );

AnswerOutcome _right(String id) => AnswerOutcome(
      questionId: id,
      questionVersion: 1,
      chosenChoiceId: '${id}_a',
      correctChoiceId: '${id}_a',
      responseMs: 3000,
    );

Future<void> _answerAll(QuizSessionRepository repo, QuizSession session) async {
  for (final question in session.questions) {
    await repo.recordAnswer(
      sessionId: session.sessionId,
      outcome: _right(question.id),
      answeredAt: DateTime.utc(2026, 11, 22, 9),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentDatabase contentDb;

  setUp(() async {
    contentDb = ContentDatabase(NativeDatabase.memory());
    await seedContentTopicWithQuestions(
      contentDb,
      examId: _exam,
      subjectId: 'subj_cse_verbal',
      topicId: 'topic_cse_rc',
      topicName: 'Reading',
      questionIds: const [],
    );
    // Passage P's two questions, split by a free-standing one.
    await _seed(contentDb, 'q-p-1', passageId: 'passage-p');
    await _seed(contentDb, 'q-free');
    await _seed(contentDb, 'q-p-2', passageId: 'passage-p');
  });

  tearDown(() => contentDb.close());

  test('a retake that splits a passage saves every answer in screen order',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final attempts = AttemptsRepository(db);
    await attempts.save(
      Attempt(
        id: 'a1',
        examId: _exam,
        origin: SessionOrigin.todayTopic.storageValue,
        startedAt: DateTime.utc(2026, 11, 21, 8),
        completedAt: DateTime.utc(2026, 11, 21, 9),
        items: [
          for (final id in ['q-p-1', 'q-free', 'q-p-2'])
            AttemptItem(
              questionId: id,
              questionVersion: 1,
              chosenChoiceId: '${id}_b',
              correctChoiceId: '${id}_a',
              responseMs: 1000,
            ),
        ],
      ),
    );
    final sessions = QuizSessionRepository(db);

    final result = await StartRetake(
      content: ContentRepository(contentDb),
      attempts: attempts,
      sessions: sessions,
    )(userId: 'user', examId: _exam, now: DateTime.utc(2026, 11, 22, 8));
    final session = (result as StartRetakeStarted).session;

    expect(session.questions.map((q) => q.id), ['q-p-1', 'q-p-2', 'q-free']);
    final row = await sessions.activeFor(userId: 'user', examId: _exam);
    expect(row!.questionIds, session.questions.map((q) => q.id));
    await _answerAll(sessions, session);
  });

  test('a restart stores the order it shows', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sessions = QuizSessionRepository(db);
    await sessions.create(
      sessionId: 'old',
      userId: 'user',
      examId: _exam,
      origin: SessionOrigin.retake,
      questionIds: const ['q-p-1', 'q-free', 'q-p-2'],
      startedAt: DateTime.utc(2026, 11, 22, 7),
    );

    final session = await RestartSession(
      content: ContentRepository(contentDb),
      sessions: sessions,
    )(userId: 'user', examId: _exam, now: DateTime.utc(2026, 11, 22, 8));

    final row = await sessions.activeFor(userId: 'user', examId: _exam);
    expect(row!.questionIds, session!.questions.map((q) => q.id));
    await _answerAll(sessions, session);
  });
}
