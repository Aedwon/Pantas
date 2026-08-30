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

    final existing = await findGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: tableType,
      rowId: rowId,
    );

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

    return (await findGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: tableType,
      rowId: rowId,
    ))!;
  }

  Future<List<PendingSyncRow>> drain({required int limit}) {
    return (_db.select(_db.pendingSync)
          ..orderBy([(row) => OrderingTerm.asc(row.queuedAt)])
          ..limit(limit))
        .get();
  }

  Future<List<PendingSyncRow>> drainGeneration({
    required String uid,
    required String generationId,
    required int limit,
  }) {
    return (_db.select(_db.pendingSync)
          ..where((row) => row.uid.equals(uid))
          ..where((row) => row.generationId.equals(generationId))
          ..orderBy([(row) => OrderingTerm.asc(row.queuedAt)])
          ..limit(limit))
        .get();
  }

  Future<PendingSyncRow?> findGenerationBound({
    required String uid,
    required String generationId,
    required String tableType,
    required String rowId,
  }) {
    return (_db.select(_db.pendingSync)
          ..where((row) => row.uid.equals(uid))
          ..where((row) => row.generationId.equals(generationId))
          ..where((row) => row.tableType.equals(tableType))
          ..where((row) => row.rowId.equals(rowId)))
        .getSingleOrNull();
  }

  Future<bool> advanceNewerRevisionBase({
    required PendingSyncIdentity observed,
    required String uid,
    required String generationId,
    required String tableType,
    required String rowId,
    required String expectedBaseState,
    required DateTime? expectedBaseUpdatedAt,
    required DateTime acceptedUpdatedAt,
  }) {
    return _db.transaction(() async {
      final current = await findGenerationBound(
        uid: uid,
        generationId: generationId,
        tableType: tableType,
        rowId: rowId,
      );
      if (current == null ||
          current.id != observed.id ||
          current.revision <= observed.revision ||
          current.baseState != expectedBaseState ||
          !_sameInstant(current.baseUpdatedAt, expectedBaseUpdatedAt)) {
        return false;
      }

      final identity = PendingSyncIdentity.fromRow(current);
      final changed = await (_db.update(_db.pendingSync)
            ..where((row) => _matchesIdentity(row, identity)))
          .write(
        PendingSyncCompanion(
          baseState: const Value('knownVersion'),
          baseUpdatedAt: Value(acceptedUpdatedAt.toUtc()),
        ),
      );
      return changed == 1;
    });
  }

  Future<bool> advanceCurrentBaseIfMatches({
    required String uid,
    required String generationId,
    required String tableType,
    required String rowId,
    required String expectedBaseState,
    required DateTime? expectedBaseUpdatedAt,
    required DateTime acceptedUpdatedAt,
  }) {
    return _db.transaction(() async {
      final current = await findGenerationBound(
        uid: uid,
        generationId: generationId,
        tableType: tableType,
        rowId: rowId,
      );
      if (current == null ||
          current.baseState != expectedBaseState ||
          !_sameInstant(current.baseUpdatedAt, expectedBaseUpdatedAt)) {
        return false;
      }

      final changed = await (_db.update(_db.pendingSync)
            ..where(
              (row) => _matchesIdentity(
                row,
                PendingSyncIdentity.fromRow(current),
              ),
            ))
          .write(
        PendingSyncCompanion(
          baseState: const Value('knownVersion'),
          baseUpdatedAt: Value(acceptedUpdatedAt.toUtc()),
        ),
      );
      return changed == 1;
    });
  }

  Future<bool> discardCurrentLineage({
    required PendingSyncIdentity observed,
    required String uid,
    required String generationId,
    required String tableType,
    required String rowId,
    required String expectedBaseState,
    required DateTime? expectedBaseUpdatedAt,
  }) {
    return _db.transaction(() async {
      final current = await findGenerationBound(
        uid: uid,
        generationId: generationId,
        tableType: tableType,
        rowId: rowId,
      );
      if (current == null ||
          current.id != observed.id ||
          current.revision < observed.revision ||
          current.baseState != expectedBaseState ||
          !_sameInstant(current.baseUpdatedAt, expectedBaseUpdatedAt)) {
        return false;
      }

      final changed = await (_db.delete(_db.pendingSync)
            ..where(
              (row) => _matchesIdentity(
                row,
                PendingSyncIdentity.fromRow(current),
              ),
            ))
          .go();
      return changed == 1;
    });
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

  static bool _sameInstant(DateTime? left, DateTime? right) {
    if (left == null || right == null) return left == right;
    return left.isAtSameMomentAs(right);
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
