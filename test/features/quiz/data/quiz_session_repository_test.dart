import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('create stores active session with currentIndex zero', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);

    await repo.create(
      sessionId: 's1',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q1', 'q2'],
      startedAt: DateTime.utc(2026, 5, 18),
    );

    final row = await db.select(db.quizSessions).getSingle();
    expect(row.currentIndex, equals(0));
    expect(row.questionIds, equals(['q1', 'q2']));
  });

  test('recordAnswer advances currentIndex correctCount and lastAnsweredAt',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);
    final answeredAt = DateTime.utc(2026, 5, 18, 10);
    await repo.create(
      sessionId: 's1',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q1'],
      startedAt: DateTime.utc(2026, 5, 18),
    );

    await repo.recordAnswer(
      sessionId: 's1',
      isCorrect: true,
      answeredAt: answeredAt,
    );

    final row = await db.select(db.quizSessions).getSingle();
    expect(row.currentIndex, equals(1));
    expect(row.correctCount, equals(1));
    expect(row.lastAnsweredAt, equals(answeredAt));
  });

  test('resume returns newest uncompleted unquit session for a user', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);
    await repo.create(
      sessionId: 'old',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q1'],
      startedAt: DateTime.utc(2026, 5, 17),
    );
    await repo.create(
      sessionId: 'new',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.drill,
      questionIds: const ['q2'],
      startedAt: DateTime.utc(2026, 5, 18),
    );

    final row = await repo.activeFor(userId: 'user', examId: 'exam');

    expect(row?.id, equals('new'));
  });

  test('complete sets completedAt and quit sets quitAt', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);
    final now = DateTime.utc(2026, 5, 18);
    await repo.create(
      sessionId: 'complete',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q1'],
      startedAt: now,
    );
    await repo.complete(sessionId: 'complete', completedAt: now);
    await repo.create(
      sessionId: 'quit',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q1'],
      startedAt: now,
    );
    await repo.quit(sessionId: 'quit', quitAt: now);

    final rows = await db.select(db.quizSessions).get();
    expect(rows.firstWhere((row) => row.id == 'complete').completedAt, now);
    expect(rows.firstWhere((row) => row.id == 'quit').quitAt, now);
  });

  test('restart discards prior active session only after explicit call',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);
    final now = DateTime.utc(2026, 5, 18);
    await repo.create(
      sessionId: 's1',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q1'],
      startedAt: now,
    );

    await repo.restartActive(userId: 'user', examId: 'exam', restartedAt: now);

    expect(await repo.activeFor(userId: 'user', examId: 'exam'), isNull);
    expect((await db.select(db.quizSessions).get()).single.quitAt, equals(now));
  });
}
