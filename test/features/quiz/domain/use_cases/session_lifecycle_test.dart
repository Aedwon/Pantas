import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/quit_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/restart_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/resume_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resume hydrates question N plus saved progress', () async {
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
    final content = ContentRepository(contentDb);
    final questions = await content.questionsByTopic('topic_cse_vocab');
    final sessions = QuizSessionRepository(db);
    await sessions.create(
      sessionId: 's1',
      userId: 'user',
      examId: 'exam_cse_pro',
      origin: SessionOrigin.todayTopic,
      topicId: 'topic_cse_vocab',
      questionIds: questions.map((question) => question.id).toList(),
      startedAt: DateTime.utc(2026, 5, 18),
    );
    await sessions.recordAnswer(
      sessionId: 's1',
      outcome: AnswerOutcome(
        questionId: questions.first.id,
        questionVersion: questions.first.version,
        chosenChoiceId: questions.first.correctChoice.id,
        correctChoiceId: questions.first.correctChoice.id,
        responseMs: 1000,
      ),
      answeredAt: DateTime.utc(2026, 5, 18, 1),
    );

    final session = await ResumeSession(
      content: content,
      sessions: sessions,
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
    );

    expect(session?.sessionId, 's1');
    expect(session?.currentIndex, 1);
    expect(session?.currentQuestion.id, questions[1].id);
    expect(session?.origin, SessionOrigin.todayTopic);
  });

  test('quit marks the active session quit and keeps answers', () async {
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
    final content = ContentRepository(contentDb);
    final questions = await content.questionsByTopic('topic_cse_vocab');
    final sessions = QuizSessionRepository(db);
    await sessions.create(
      sessionId: 's1',
      userId: 'user',
      examId: 'exam_cse_pro',
      origin: SessionOrigin.drill,
      questionIds: questions.map((question) => question.id).toList(),
      startedAt: DateTime.utc(2026, 5, 18),
    );
    await sessions.recordAnswer(
      sessionId: 's1',
      outcome: AnswerOutcome(
        questionId: questions.first.id,
        questionVersion: questions.first.version,
        chosenChoiceId: questions.first.correctChoice.id,
        correctChoiceId: questions.first.correctChoice.id,
        responseMs: 1000,
      ),
      answeredAt: DateTime.utc(2026, 5, 18, 1),
    );

    await QuitSession(sessions)(
      userId: 'user',
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 5, 18, 2),
    );

    expect(
      await sessions.activeFor(userId: 'user', examId: 'exam_cse_pro'),
      isNull,
    );
    final row = (await db.select(db.quizSessions).get()).single;
    expect(row.quitAt, DateTime.utc(2026, 5, 18, 2));
    expect(row.currentIndex, 1);
  });

  test('restart requires explicit call and creates a new session', () async {
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
    final content = ContentRepository(contentDb);
    final questions = await content.questionsByTopic('topic_cse_vocab');
    final sessions = QuizSessionRepository(db);
    await sessions.create(
      sessionId: 'old',
      userId: 'user',
      examId: 'exam_cse_pro',
      origin: SessionOrigin.inline,
      topicId: 'topic_cse_vocab',
      lessonId: 'lesson_cse_vocab_intro',
      questionIds: questions.map((question) => question.id).toList(),
      startedAt: DateTime.utc(2026, 5, 18),
    );

    final restarted = await RestartSession(
      content: content,
      sessions: sessions,
      newSessionId: () => 'new',
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 5, 18, 2),
    );

    expect(restarted?.sessionId, 'new');
    expect(restarted?.origin, SessionOrigin.inline);
    expect(restarted?.currentIndex, 0);
    final rows = await db.select(db.quizSessions).get();
    expect(
      rows.firstWhere((row) => row.id == 'old').quitAt,
      DateTime.utc(2026, 5, 18, 2),
    );
    expect(
      rows.firstWhere((row) => row.id == 'new').lessonId,
      'lesson_cse_vocab_intro',
    );
  });

  test('completed sessions are not resumable', () async {
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
    final content = ContentRepository(contentDb);
    final questions = await content.questionsByTopic('topic_cse_vocab');
    final sessions = QuizSessionRepository(db);
    await sessions.create(
      sessionId: 's1',
      userId: 'user',
      examId: 'exam_cse_pro',
      origin: SessionOrigin.todayTopic,
      questionIds: questions.map((question) => question.id).toList(),
      startedAt: DateTime.utc(2026, 5, 18),
    );
    await sessions.complete(
      sessionId: 's1',
      completedAt: DateTime.utc(2026, 5, 18, 1),
    );

    final session = await ResumeSession(
      content: content,
      sessions: sessions,
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
    );

    expect(session, isNull);
  });

  test('resume restores persisted answer outcomes in order', () async {
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
      questionIds: ['q0', 'q1', 'q2'],
    );
    final content = ContentRepository(contentDb);
    final questions = await content.questionsByTopic('topic_cse_vocab');
    final sessions = QuizSessionRepository(db);
    await sessions.create(
      sessionId: 's_outcomes',
      userId: 'user',
      examId: 'exam_cse_pro',
      origin: SessionOrigin.todayTopic,
      topicId: 'topic_cse_vocab',
      questionIds: questions.map((q) => q.id).toList(),
      startedAt: DateTime.utc(2026, 5, 18),
    );

    final first = questions.first;
    final chosenWrong = first.choices.firstWhere((c) => !c.isCorrect);
    final outcome = await SubmitAnswer(
      reviewRepo: ReviewStateRepository(db),
      scheduler: const FsrsScheduler(),
      sessions: sessions,
    )(
      question: first,
      chosenChoiceId: chosenWrong.id,
      responseMs: 1234,
      now: DateTime.utc(2026, 5, 18, 1),
      sessionId: 's_outcomes',
    );

    final resumed = await ResumeSession(
      content: content,
      sessions: sessions,
    )(
      userId: 'user',
      examId: 'exam_cse_pro',
    );

    expect(resumed, isNotNull);
    expect(resumed!.currentIndex, 1);
    expect(resumed.outcomes, hasLength(1));
    expect(resumed.outcomes.single.questionId, first.id);
    expect(
      resumed.outcomes.single.chosenChoiceId,
      chosenWrong.id,
    );
    expect(resumed.outcomes.single.correctChoiceId, first.correctChoice.id);
    expect(resumed.outcomes.single.responseMs, 1234);
    expect(resumed.outcomes.single.derivedRating, outcome.derivedRating);
  });
}
