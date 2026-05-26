import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MockAttemptRepo repo;
  final startedAt = DateTime.utc(2026, 5, 19, 1);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MockAttemptRepo(db);
  });

  tearDown(() => db.close());

  Future<void> insertAttempt({
    required String id,
    String userId = 'user_1',
    DateTime? startedAt,
    MockAttemptStatus status = MockAttemptStatus.inProgress,
    DateTime? submittedAt,
    int? scoreRaw,
    int? scoreTotal,
  }) =>
      insertMockAttempt(
        db,
        id: id,
        userId: userId,
        startedAt: startedAt,
        status: status,
        submittedAt: submittedAt,
        scoreRaw: scoreRaw,
        scoreTotal: scoreTotal,
      );

  test('insertStart creates an in-progress attempt', () async {
    await repo.insertStart(
      MockAttemptStart(
        id: 'mock_1',
        userId: 'user_1',
        examId: 'exam_cse',
        blueprintId: 'bp_cse',
        blueprintName: 'CSE Practice',
        durationMinutes: 90,
        strictMode: false,
        sampledQuestionsJson: '[]',
        startedAt: startedAt,
      ),
    );

    final attempt = await repo.findInProgress('user_1');

    expect(attempt, isNotNull);
    expect(attempt!.id, 'mock_1');
    expect(attempt.status, MockAttemptStatus.inProgress);
    expect(attempt.lastFlushedAt, startedAt);
    expect(attempt.updatedAt, startedAt);
  });

  test('findInProgress returns newest active attempt for user', () async {
    await insertAttempt(id: 'older', startedAt: startedAt);
    await insertAttempt(
      id: 'newer',
      startedAt: startedAt.add(const Duration(minutes: 1)),
    );
    await insertAttempt(id: 'other_user', userId: 'user_2');

    final attempt = await repo.findInProgress('user_1');

    expect(attempt!.id, 'newer');
  });

  test(
    'flushProgress updates elapsed flags answers current index and flush time',
    () async {
      await insertAttempt(id: 'mock_1');
      final flushedAt = startedAt.add(const Duration(seconds: 30));

      await repo.flushProgress(
        attemptId: 'mock_1',
        elapsedSeconds: 30,
        accumulatedPausedSeconds: 5,
        pausedAtLastFlush: true,
        answersJson: '{"q1":{"idx":1,"atSec":30}}',
        flagsJson: '["q2"]',
        currentIndex: 2,
        flushedAt: flushedAt,
        updateSyncTimestamp: false,
      );

      final attempt = await repo.findById('mock_1');

      expect(attempt!.elapsedSeconds, 30);
      expect(attempt.accumulatedPausedSeconds, 5);
      expect(attempt.pausedAtLastFlush, isTrue);
      expect(attempt.answersJson, contains('"q1"'));
      expect(attempt.flagsJson, '["q2"]');
      expect(attempt.currentIndex, 2);
      expect(attempt.lastFlushedAt, flushedAt);
      expect(attempt.updatedAt, startedAt);
    },
  );

  test('discard marks terminal without consuming cooldown', () async {
    await insertAttempt(id: 'mock_1');
    final discardedAt = startedAt.add(const Duration(minutes: 10));

    await repo.discard('mock_1', discardedAt);

    final attempt = await repo.findById('mock_1');
    expect(attempt!.status, MockAttemptStatus.discarded);
    expect(attempt.updatedAt, discardedAt);
    expect(await repo.lastCooldownAttempt('user_1', 'exam_cse'), isNull);
  });

  test('lastCooldownAttempt ignores discarded and reads completed or forfeited',
      () async {
    await insertAttempt(
      id: 'discarded',
      status: MockAttemptStatus.discarded,
      submittedAt: startedAt.add(const Duration(minutes: 10)),
    );
    await insertAttempt(
      id: 'completed',
      status: MockAttemptStatus.completed,
      submittedAt: startedAt.add(const Duration(minutes: 20)),
    );
    await insertAttempt(
      id: 'forfeited',
      status: MockAttemptStatus.forfeited,
      submittedAt: startedAt.add(const Duration(minutes: 30)),
    );

    final attempt = await repo.lastCooldownAttempt('user_1', 'exam_cse');

    expect(attempt!.id, 'forfeited');
  });

  test('history returns terminal scored attempts newest first with limit',
      () async {
    await insertAttempt(id: 'in_progress');
    await insertAttempt(
      id: 'old',
      status: MockAttemptStatus.completed,
      submittedAt: startedAt.add(const Duration(minutes: 20)),
      scoreRaw: 7,
      scoreTotal: 10,
    );
    await insertAttempt(
      id: 'new',
      status: MockAttemptStatus.completed,
      submittedAt: startedAt.add(const Duration(minutes: 30)),
      scoreRaw: 8,
      scoreTotal: 10,
    );

    final history = await repo.history('user_1', limit: 1);

    expect(history.map((attempt) => attempt.id), ['new']);
  });
}

Future<void> insertMockAttempt(
  AppDatabase db, {
  required String id,
  String userId = 'user_1',
  DateTime? startedAt,
  MockAttemptStatus status = MockAttemptStatus.inProgress,
  DateTime? submittedAt,
  int? scoreRaw,
  int? scoreTotal,
}) {
  final start = startedAt ?? DateTime.utc(2026, 5, 19, 1);
  return db.into(db.mockAttempts).insert(
        MockAttemptsCompanion.insert(
          id: id,
          userId: userId,
          examId: 'exam_cse',
          blueprintId: 'bp_cse',
          blueprintName: 'CSE Practice',
          durationMinutes: 90,
          status: status.value,
          strictMode: false,
          sampledQuestionsJson: '[]',
          startedAt: start,
          lastFlushedAt: start,
          updatedAt: submittedAt ?? start,
          submittedAt:
              submittedAt == null ? const Value.absent() : Value(submittedAt),
          scoreRaw: scoreRaw == null ? const Value.absent() : Value(scoreRaw),
          scoreTotal:
              scoreTotal == null ? const Value.absent() : Value(scoreTotal),
        ),
      );
}
