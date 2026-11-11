import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

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
      outcome: const AnswerOutcome(
        questionId: 'q1',
        questionVersion: 1,
        chosenChoiceId: 'q1-a',
        correctChoiceId: 'q1-a',
        responseMs: 1000,
      ),
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

  test('starting a session closes whatever was left open for that exam',
      () async {
    // Six use cases create a session and only restart closed the previous
    // one, so abandoned sessions stayed open forever and stacked up.
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);

    await repo.create(
      sessionId: 'abandoned',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q1'],
      startedAt: DateTime.utc(2026, 5, 18),
    );
    await repo.create(
      sessionId: 'current',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q2'],
      startedAt: DateTime.utc(2026, 5, 19),
    );

    final rows = await db.select(db.quizSessions).get();
    final open = rows.where((r) => r.quitAt == null && r.completedAt == null);
    expect(open.map((r) => r.id), ['current']);
  });

  test('a session for another exam is left alone', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);

    await repo.create(
      sessionId: 'other-exam',
      userId: 'user',
      examId: 'exam-b',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q1'],
      startedAt: DateTime.utc(2026, 5, 18),
    );
    await repo.create(
      sessionId: 'current',
      userId: 'user',
      examId: 'exam-a',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q2'],
      startedAt: DateTime.utc(2026, 5, 19),
    );

    final rows = await db.select(db.quizSessions).get();
    final open = rows.where((r) => r.quitAt == null && r.completedAt == null);
    expect(open.map((r) => r.id).toSet(), {'other-exam', 'current'});
  });

  test('quitAllOpen closes every open session, not just the newest', () async {
    // Discard closed one at a time, so with a pile of them the panel showed
    // the next one straight away and the button looked broken.
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);

    for (var i = 0; i < 4; i++) {
      await db.into(db.quizSessions).insert(
            QuizSessionsCompanion.insert(
              id: 's$i',
              userId: 'user',
              examId: 'exam',
              origin: SessionOrigin.todayTopic.storageValue,
              questionIdsJson: '["q1"]',
              startedAt: DateTime.utc(2026, 5, 18 + i),
            ),
          );
    }

    final closed = await repo.quitAllOpen(
      userId: 'user',
      examId: 'exam',
      quitAt: DateTime.utc(2026, 5, 25),
    );

    expect(closed, 4);
    expect(await repo.activeFor(userId: 'user', examId: 'exam'), isNull);
  });
  test(
      'guarded create rolls back prior active session when cancelled before '
      'insert', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);
    final previousStartedAt = DateTime.utc(2026, 9, 9, 8);
    final launchStartedAt = DateTime.utc(2026, 9, 9, 9);

    await repo.create(
      sessionId: 'previous',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q-old'],
      startedAt: previousStartedAt,
    );

    var checks = 0;
    final created = await repo.createGuarded(
      sessionId: 'cancelled',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q-new'],
      startedAt: launchStartedAt,
      canPersist: () {
        checks += 1;
        return checks == 1;
      },
    );

    expect(created, isFalse);
    expect(checks, 2);
    final rows = await db.select(db.quizSessions).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'previous');
    expect(rows.single.quitAt, isNull);
    expect(
      (await repo.activeFor(userId: 'user', examId: 'exam'))?.id,
      'previous',
    );
  });

  test(
      'guarded create rolls back when cancelled after awaited insert before '
      'commit', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);
    final previousStartedAt = DateTime.utc(2026, 9, 9, 8);
    final launchStartedAt = DateTime.utc(2026, 9, 9, 9);

    await repo.create(
      sessionId: 'previous-after-insert',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q-old'],
      startedAt: previousStartedAt,
    );

    final guardResults = <bool>[true, true, false];
    var checks = 0;
    final created = await repo.createGuarded(
      sessionId: 'cancelled-after-insert',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q-new'],
      startedAt: launchStartedAt,
      canPersist: () => guardResults[checks++],
    );

    expect(created, isFalse);
    expect(checks, 3);
    final rows = await db.select(db.quizSessions).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'previous-after-insert');
    expect(rows.single.quitAt, isNull);
    expect(
      (await repo.activeFor(userId: 'user', examId: 'exam'))?.id,
      'previous-after-insert',
    );
  });

  test(
      'guarded create commits exactly one replacement when all checkpoints '
      'stay valid', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = QuizSessionRepository(db);
    final previousStartedAt = DateTime.utc(2026, 9, 9, 8);
    final launchStartedAt = DateTime.utc(2026, 9, 9, 9);

    await repo.create(
      sessionId: 'previous-valid',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q-old'],
      startedAt: previousStartedAt,
    );

    final guardResults = <bool>[true, true, true];
    var checks = 0;
    final created = await repo.createGuarded(
      sessionId: 'replacement-valid',
      userId: 'user',
      examId: 'exam',
      origin: SessionOrigin.todayTopic,
      questionIds: const ['q-new'],
      startedAt: launchStartedAt,
      canPersist: () => guardResults[checks++],
    );

    expect(created, isTrue);
    expect(checks, 3);
    final rows = await db.select(db.quizSessions).get();
    expect(rows, hasLength(2));
    final previous = rows.singleWhere((row) => row.id == 'previous-valid');
    final replacement =
        rows.singleWhere((row) => row.id == 'replacement-valid');
    expect(previous.quitAt, launchStartedAt);
    expect(replacement.quitAt, isNull);
    expect(replacement.completedAt, isNull);
    final open =
        rows.where((row) => row.quitAt == null && row.completedAt == null);
    expect(open.map((row) => row.id), ['replacement-valid']);
    expect(
      (await repo.activeFor(userId: 'user', examId: 'exam'))?.id,
      'replacement-valid',
    );
  });
}
