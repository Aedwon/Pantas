import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';

enum PendingSyncOp { upsert, delete }

class PendingSyncIdentity {
  const PendingSyncIdentity({
    required this.id,
    required this.revision,
    required this.mutationId,
  });

  factory PendingSyncIdentity.fromRow(PendingSyncRow row) =>
      PendingSyncIdentity(
        id: row.id,
        revision: row.revision,
        mutationId: row.mutationId,
      );

  final int id;
  final int revision;
  final String mutationId;
}

class PendingQueue {
  PendingQueue(AppDatabase db) : _db = db;

  final AppDatabase _db;

  Future<void> enqueue({
    required String tableType,
    required String rowId,
    required PendingSyncOp op,
    required DateTime queuedAt,
  }) async {
    final existing = await (_db.select(_db.pendingSync)
          ..where((row) => row.uid.equals(''))
          ..where((row) => row.generationId.equals(''))
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

  Future<PendingSyncRow> enqueueGenerationBound({
    required String uid,
    required String generationId,
    required String tableType,
    required String rowId,
    required PendingSyncOp op,
    required String baseState,
    required DateTime? baseUpdatedAt,
    required String mutationId,
    required DateTime queuedAt,
  }) async {
    _validateGenerationBoundInput(
      uid: uid,
      generationId: generationId,
      baseState: baseState,
      baseUpdatedAt: baseUpdatedAt,
      mutationId: mutationId,
    );

    final existing = await (_db.select(_db.pendingSync)
          ..where((row) => row.uid.equals(uid))
          ..where((row) => row.generationId.equals(generationId))
          ..where((row) => row.tableType.equals(tableType))
          ..where((row) => row.rowId.equals(rowId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.pendingSync).insert(
            PendingSyncCompanion.insert(
              uid: Value(uid),
              generationId: Value(generationId),
              tableType: tableType,
              rowId: rowId,
              op: op.name,
              baseState: Value(baseState),
              baseUpdatedAt: Value(baseUpdatedAt),
              mutationId: Value(mutationId),
              queuedAt: queuedAt,
            ),
          );
    } else {
      await (_db.update(_db.pendingSync)
            ..where((row) => row.id.equals(existing.id)))
          .write(
        PendingSyncCompanion(
          op: Value(op.name),
          baseState: Value(baseState),
          baseUpdatedAt: Value(baseUpdatedAt),
          mutationId: Value(mutationId),
          revision: Value(existing.revision + 1),
          attempts: const Value(0),
          lastError: const Value(null),
          lastAttemptAt: const Value(null),
        ),
      );
    }

    return (_db.select(_db.pendingSync)
          ..where((row) => row.uid.equals(uid))
          ..where((row) => row.generationId.equals(generationId))
          ..where((row) => row.tableType.equals(tableType))
          ..where((row) => row.rowId.equals(rowId)))
        .getSingle();
  }

  Future<List<PendingSyncRow>> drain({required int limit}) {
    return (_db.select(_db.pendingSync)
          ..orderBy([(row) => OrderingTerm.asc(row.queuedAt)])
          ..limit(limit))
        .get();
  }

  Future<void> markFailure(
    List<PendingSyncIdentity> identities, {
    required String error,
    required DateTime attemptedAt,
  }) async {
    if (identities.isEmpty) return;

    await _db.transaction(() async {
      for (final identity in identities) {
        final row = await (_db.select(_db.pendingSync)
              ..where((pending) => _matchesIdentity(pending, identity)))
            .getSingleOrNull();
        if (row == null) continue;

        await (_db.update(_db.pendingSync)
              ..where((pending) => _matchesIdentity(pending, identity)))
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

  Future<void> markSuccess(List<PendingSyncIdentity> identities) async {
    if (identities.isEmpty) return;

    await _db.transaction(() async {
      for (final identity in identities) {
        await (_db.delete(_db.pendingSync)
              ..where((row) => _matchesIdentity(row, identity)))
            .go();
      }
    });
  }

  Expression<bool> _matchesIdentity(
    $PendingSyncTable pending,
    PendingSyncIdentity identity,
  ) {
    return pending.id.equals(identity.id) &
        pending.revision.equals(identity.revision) &
        pending.mutationId.equals(identity.mutationId);
  }

  static void _validateGenerationBoundInput({
    required String uid,
    required String generationId,
    required String baseState,
    required DateTime? baseUpdatedAt,
    required String mutationId,
  }) {
    if (uid.isEmpty) {
      throw ArgumentError.value(uid, 'uid', 'must not be empty');
    }
    if (generationId.isEmpty) {
      throw ArgumentError.value(
        generationId,
        'generationId',
        'must not be empty',
      );
    }
    if (mutationId.isEmpty) {
      throw ArgumentError.value(
        mutationId,
        'mutationId',
        'must not be empty',
      );
    }

    switch (baseState) {
      case 'knownAbsent':
        if (baseUpdatedAt != null) {
          throw ArgumentError.value(
            baseUpdatedAt,
            'baseUpdatedAt',
            'must be null for knownAbsent',
          );
        }
      case 'knownVersion':
        if (baseUpdatedAt == null) {
          throw ArgumentError.value(
            baseUpdatedAt,
            'baseUpdatedAt',
            'is required for knownVersion',
          );
        }
      default:
        throw ArgumentError.value(
          baseState,
          'baseState',
          'must be knownAbsent or knownVersion',
        );
    }
  }
}
