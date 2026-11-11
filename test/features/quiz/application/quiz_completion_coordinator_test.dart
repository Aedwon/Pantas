import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

void main() {
  late AppDatabase db;
  late AttemptsRepository attempts;
  late QuizSessionRepository sessions;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    attempts = AttemptsRepository(db);
    sessions = QuizSessionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('atomically persists attempt and completedAt for one persisted session',
      () async {
    final startedAt = DateTime.utc(2026, 9, 9, 8);
    final completedAt = DateTime.utc(2026, 9, 9, 8, 5);
    await sessions.create(
      sessionId: 'session-1',
      userId: 'local',
      examId: 'exam',
      questionIds: const ['q1'],
      startedAt: startedAt,
      origin: SessionOrigin.todayTopic,
    );
    final coordinator = QuizCompletionCoordinator(
      attempts: attempts,
      sessions: sessions,
    );

    final attempt = await coordinator.complete(
      session: _completedSession(startedAt),
      now: completedAt,
      persisted: true,
    );

    expect(attempt.id, 'session-1');
    expect((await attempts.byId('session-1'))?.completedAt, completedAt);
    expect(
      await sessions.activeFor(userId: 'local', examId: 'exam'),
      isNull,
    );
    final row = await (db.select(db.quizSessions)
          ..where((table) => table.id.equals('session-1')))
        .getSingle();
    expect(row.completedAt, completedAt);
    expect(await attempts.countForExam('exam'), 1);
  });

  test('failed terminal session update rolls back the attempt write', () async {
    final startedAt = DateTime.utc(2026, 9, 9, 8);
    final coordinator = QuizCompletionCoordinator(
      attempts: attempts,
      sessions: sessions,
    );

    await expectLater(
      coordinator.complete(
        session: _completedSession(startedAt),
        now: DateTime.utc(2026, 9, 9, 8, 5),
        persisted: true,
      ),
      throwsStateError,
    );

    expect(await attempts.byId('session-1'), isNull);
    expect(await _attemptMutation(db), isNull);
    expect(
      await LocalSyncMutationRecorder.forDatabase(db).readMutationEpoch(),
      0,
    );
  });

  test('retry after terminal commit is idempotent', () async {
    final startedAt = DateTime.utc(2026, 9, 9, 8);
    final completedAt = DateTime.utc(2026, 9, 9, 8, 5);
    await sessions.create(
      sessionId: 'session-1',
      userId: 'local',
      examId: 'exam',
      questionIds: const ['q1'],
      startedAt: startedAt,
      origin: SessionOrigin.todayTopic,
    );
    final coordinator = QuizCompletionCoordinator(
      attempts: attempts,
      sessions: sessions,
    );
    final session = _completedSession(startedAt);

    final first = await coordinator.complete(
      session: session,
      now: completedAt,
      persisted: true,
    );
    final firstMutation = await _attemptMutation(db);
    final firstEpoch =
        await LocalSyncMutationRecorder.forDatabase(db).readMutationEpoch();
    final second = await coordinator.complete(
      session: session,
      now: completedAt.add(const Duration(minutes: 1)),
      persisted: true,
    );
    final secondMutation = await _attemptMutation(db);
    final secondEpoch =
        await LocalSyncMutationRecorder.forDatabase(db).readMutationEpoch();

    expect(second, first);
    expect(await attempts.countForExam('exam'), 1);
    expect(firstMutation, isNotNull);
    expect(secondMutation?.revision, firstMutation?.revision);
    expect(secondMutation?.mutationEpoch, firstMutation?.mutationEpoch);
    expect(secondEpoch, firstEpoch);
    final row = await (db.select(db.quizSessions)
          ..where((table) => table.id.equals('session-1')))
        .getSingle();
    expect(row.completedAt, completedAt);
  });
}

Future<({int revision, int mutationEpoch})?> _attemptMutation(
  AppDatabase db,
) async {
  final rows = await db
      .customSelect(
        'select revision, mutation_epoch from sync_local_mutations '
        "where collection = 'quiz_attempts' and row_id = 'session-1'",
      )
      .get();
  if (rows.isEmpty) return null;
  final row = rows.single;
  return (
    revision: row.read<int>('revision'),
    mutationEpoch: row.read<int>('mutation_epoch'),
  );
}

QuizSession _completedSession(DateTime startedAt) {
  const question = Question(
    id: 'q1',
    version: 1,
    examIds: ['exam'],
    topicId: 'topic',
    language: 'en',
    stem: 'Stem',
    choices: [
      Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
      Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
    ],
    explanation: 'Because.',
  );
  return QuizSession.start(
    sessionId: 'session-1',
    examId: 'exam',
    questions: const [question],
    startedAt: startedAt,
  ).record(
    const AnswerOutcome(
      questionId: 'q1',
      questionVersion: 1,
      chosenChoiceId: 'a',
      correctChoiceId: 'a',
      responseMs: 1000,
    ),
  );
}
