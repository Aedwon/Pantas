import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';

enum PendingSyncOp { upsert, delete }

class PendingQueue {
  PendingQueue(this._db);

  final AppDatabase _db;

  Future<void> enqueue({
    required String tableType,
    required String rowId,
    required PendingSyncOp op,
    required DateTime queuedAt,
  }) async {
    final existing = await (_db.select(_db.pendingSync)
          ..where((row) => row.tableType.equals(tableType))
          ..where((row) => row.rowId.equals(rowId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.pendingSync).insert(
            PendingSyncCompanion.insert(
              tableType: tableType,
              rowId: rowId,
              op: op.name,
              queuedAt: queuedAt,
            ),
          );
      return;
    }

    await (_db.update(_db.pendingSync)
          ..where((row) => row.id.equals(existing.id)))
        .write(PendingSyncCompanion(op: Value(op.name)));
  }

  Future<List<PendingSyncRow>> drain({required int limit}) {
    return (_db.select(_db.pendingSync)
          ..orderBy([(row) => OrderingTerm.asc(row.queuedAt)])
          ..limit(limit))
        .get();
  }

  Future<void> markFailure(
    List<int> ids, {
    required String error,
    required DateTime attemptedAt,
  }) async {
    if (ids.isEmpty) return;

    await _db.transaction(() async {
      for (final id in ids) {
        final row = await (_db.select(_db.pendingSync)
              ..where((pending) => pending.id.equals(id)))
            .getSingleOrNull();
        if (row == null) continue;
        await (_db.update(_db.pendingSync)
              ..where((pending) => pending.id.equals(id)))
            .write(
          PendingSyncCompanion(
            attempts: Value(row.attempts + 1),
            lastError: Value(error),
            lastAttemptAt: Value(attemptedAt),
          ),
        );
      }
    });
  }

  Future<void> markSuccess(List<int> ids) async {
    if (ids.isEmpty) return;

    await (_db.delete(_db.pendingSync)..where((row) => row.id.isIn(ids))).go();
  }
}
