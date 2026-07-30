import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AttemptsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = AttemptsRepository(db);
  });
  tearDown(() => db.close());

  Attempt make({String id = 'a_1', DateTime? completedAt}) => Attempt(
        id: id,
        examId: 'exam_cse_pro',
        startedAt: DateTime.utc(2026, 5, 9),
        completedAt: completedAt,
        items: const [
          AttemptItem(
            questionId: 'q_1',
            questionVersion: 1,
            chosenChoiceId: 'c_b',
            correctChoiceId: 'c_b',
            responseMs: 1500,
          ),
        ],
      );

  test('save persists an attempt with sync_state="pending"', () async {
    await repo.save(make(completedAt: DateTime.utc(2026, 5, 9, 0, 5)));
    final pending = await repo.pendingSyncs();
    expect(pending, hasLength(1));
    expect(pending.first.id, equals('a_1'));
  });

  test('byId round-trips a saved attempt', () async {
    final attempt = make(completedAt: DateTime.utc(2026, 5, 9, 0, 5));
    await repo.save(attempt);
    expect(await repo.byId('a_1'), equals(attempt));
  });

  test('markSynced moves an attempt out of the pending queue', () async {
    await repo.save(make(completedAt: DateTime.utc(2026, 5, 9, 0, 5)));
    await repo.markSynced('a_1');
    expect(await repo.pendingSyncs(), isEmpty);
  });

  test('markFailed records error and increments syncAttempts', () async {
    await repo.save(make(completedAt: DateTime.utc(2026, 5, 9, 0, 5)));
    await repo.markFailed('a_1', 'network');
    await repo.markFailed('a_1', 'timeout');
    final row = await repo.rawRowById('a_1');
    expect(row.syncAttempts, equals(2));
    expect(row.lastSyncError, equals('timeout'));
    expect(SyncState.fromString(row.syncState), equals(SyncState.failed));
  });

  test('recentIncorrects returns incorrect question ids from last 30 days',
      () async {
    final now = DateTime.utc(2026, 5, 18);
    await repo.save(
      Attempt(
        id: 'recent_wrong',
        examId: 'exam_cse_pro',
        startedAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
        items: const [
          AttemptItem(
            questionId: 'q_wrong',
            questionVersion: 1,
            chosenChoiceId: 'c_a',
            correctChoiceId: 'c_b',
            responseMs: 1000,
          ),
        ],
      ),
    );
    await repo.save(
      Attempt(
        id: 'old_wrong',
        examId: 'exam_cse_pro',
        startedAt: now.subtract(const Duration(days: 31)),
        completedAt: now.subtract(const Duration(days: 31)),
        items: const [
          AttemptItem(
            questionId: 'q_old',
            questionVersion: 1,
            chosenChoiceId: 'c_a',
            correctChoiceId: 'c_b',
            responseMs: 1000,
          ),
        ],
      ),
    );
    await repo.save(
      Attempt(
        id: 'recent_correct',
        examId: 'exam_cse_pro',
        startedAt: now,
        completedAt: now,
        items: const [
          AttemptItem(
            questionId: 'q_correct',
            questionVersion: 1,
            chosenChoiceId: 'c_b',
            correctChoiceId: 'c_b',
            responseMs: 1000,
          ),
        ],
      ),
    );

    expect(
      await repo.recentIncorrects(
        examId: 'exam_cse_pro',
        now: now,
        window: const Duration(days: 30),
      ),
      equals(['q_wrong']),
    );
  });
}
