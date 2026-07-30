import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

class MockAttemptRepo {
  MockAttemptRepo(this._db);

  final AppDatabase _db;

  Future<void> insertStart(MockAttemptStart start) {
    return _db.into(_db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: start.id,
            userId: start.userId,
            examId: start.examId,
            blueprintId: start.blueprintId,
            blueprintName: start.blueprintName,
            durationMinutes: start.durationMinutes,
            status: MockAttemptStatus.inProgress.value,
            strictMode: start.strictMode,
            sampledQuestionsJson: start.sampledQuestionsJson,
            startedAt: start.startedAt,
            lastFlushedAt: start.startedAt,
            updatedAt: start.startedAt,
          ),
        );
  }

  Future<MockAttempt?> findById(String attemptId) async {
    final row = await (_db.select(_db.mockAttempts)
          ..where((attempt) => attempt.id.equals(attemptId)))
        .getSingleOrNull();
    return row == null ? null : MockAttempt.fromRow(row);
  }

  Future<MockAttempt?> findInProgress(String userId) async {
    final row = await (_db.select(_db.mockAttempts)
          ..where(
            (attempt) =>
                attempt.userId.equals(userId) &
                attempt.status.equals(MockAttemptStatus.inProgress.value),
          )
          ..orderBy([
            (attempt) => OrderingTerm.desc(attempt.startedAt),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : MockAttempt.fromRow(row);
  }

  Future<void> flushProgress({
    required String attemptId,
    required int elapsedSeconds,
    required int accumulatedPausedSeconds,
    required bool pausedAtLastFlush,
    required String answersJson,
    required String flagsJson,
    required int currentIndex,
    required DateTime flushedAt,
    bool updateSyncTimestamp = true,
  }) async {
    await (_db.update(_db.mockAttempts)
          ..where((attempt) => attempt.id.equals(attemptId)))
        .write(
      MockAttemptsCompanion(
        elapsedSeconds: Value(elapsedSeconds),
        accumulatedPausedSeconds: Value(accumulatedPausedSeconds),
        pausedAtLastFlush: Value(pausedAtLastFlush),
        answersJson: Value(answersJson),
        flagsJson: Value(flagsJson),
        currentIndex: Value(currentIndex),
        lastFlushedAt: Value(flushedAt),
        updatedAt:
            updateSyncTimestamp ? Value(flushedAt) : const Value.absent(),
      ),
    );
  }

  Future<void> discard(String attemptId, DateTime discardedAt) async {
    await (_db.update(_db.mockAttempts)
          ..where((attempt) => attempt.id.equals(attemptId)))
        .write(
      MockAttemptsCompanion(
        status: Value(MockAttemptStatus.discarded.value),
        updatedAt: Value(discardedAt),
      ),
    );
  }

  Future<void> submit({
    required String attemptId,
    required MockAttemptStatus status,
    required MockResults results,
    required String sectionResultsJson,
    required DateTime submittedAt,
  }) async {
    await (_db.update(_db.mockAttempts)
          ..where((attempt) => attempt.id.equals(attemptId)))
        .write(
      MockAttemptsCompanion(
        status: Value(status.value),
        scoreRaw: Value(results.scoreRaw),
        scoreTotal: Value(results.scoreTotal),
        sectionResultsJson: Value(sectionResultsJson),
        totalTimeSeconds: Value(results.totalTimeSeconds),
        submittedAt: Value(submittedAt),
        updatedAt: Value(submittedAt),
      ),
    );
  }

  Future<MockAttempt?> lastCooldownAttempt(String userId, String examId) async {
    final row = await (_db.select(_db.mockAttempts)
          ..where(
            (attempt) =>
                attempt.userId.equals(userId) &
                attempt.examId.equals(examId) &
                attempt.status.isIn([
                  MockAttemptStatus.completed.value,
                  MockAttemptStatus.forfeited.value,
                ]),
          )
          ..orderBy([
            (attempt) => OrderingTerm.desc(attempt.submittedAt),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : MockAttempt.fromRow(row);
  }

  Future<List<MockAttempt>> history(String userId, {int limit = 10}) async {
    final rows = await (_db.select(_db.mockAttempts)
          ..where(
            (attempt) =>
                attempt.userId.equals(userId) &
                attempt.status.isIn([
                  MockAttemptStatus.completed.value,
                  MockAttemptStatus.forfeited.value,
                ]),
          )
          ..orderBy([
            (attempt) => OrderingTerm.desc(attempt.submittedAt),
          ])
          ..limit(limit))
        .get();
    return rows.map(MockAttempt.fromRow).toList(growable: false);
  }
}
