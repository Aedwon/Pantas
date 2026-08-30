import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';

class SyncOutboxPromoter {
  SyncOutboxPromoter(
    this._db, {
    required SyncActiveContextStore activeContextStore,
    required PendingQueue pendingQueue,
    String Function()? mutationIdFactory,
  })  : _activeContextStore = activeContextStore,
        _pendingQueue = pendingQueue,
        _mutationIdFactory = mutationIdFactory ?? _nextMutationId;

  final AppDatabase _db;
  final SyncActiveContextStore _activeContextStore;
  final PendingQueue _pendingQueue;
  final String Function() _mutationIdFactory;

  static int _mutationSequence = 0;

  Future<int> promoteAvailable({int limit = 500}) async {
    final activeSnapshot = await _activeContextStore.readSnapshot();
    final activeContext = activeSnapshot?.context;
    if (activeSnapshot == null || activeContext == null) return 0;

    final rows = await _db.customSelect(
      'select collection,row_id,op,revision,mutation_epoch,causal_uid, '
      'causal_generation_id,causal_base_state, '
      'cast(base_updated_at as integer) as base_updated_at, '
      'cast(recorded_at as integer) as recorded_at '
      'from sync_local_mutations order by mutation_epoch limit ?',
      variables: [Variable<int>(limit)],
    ).get();
    final observed =
        rows.map(_ObservedMutation.fromRow).toList(growable: false);

    var promoted = 0;
    for (final mutation in observed) {
      if (!_eligibleForContext(mutation, activeContext)) continue;

      final stillActive = await _activeContextStore.readSnapshot();
      if (stillActive == null ||
          stillActive.token != activeSnapshot.token ||
          stillActive.context != activeContext) {
        break;
      }

      await _db.transaction(() async {
        final transactionContext = await _activeContextStore.readSnapshot();
        if (transactionContext == null ||
            transactionContext.token != activeSnapshot.token ||
            transactionContext.context != activeContext) {
          return;
        }

        await _pendingQueue.enqueueGenerationBound(
          uid: activeContext.uid,
          generationId: activeContext.generationId,
          tableType: mutation.collection,
          rowId: mutation.rowId,
          op: _pendingOp(mutation.op),
          baseState: mutation.causalBaseState,
          baseUpdatedAt: mutation.baseUpdatedAt,
          mutationId: _mutationIdFactory(),
          queuedAt: mutation.recordedAt,
        );

        await (_db.delete(_db.syncLocalMutations)
              ..where((row) => row.collection.equals(mutation.collection))
              ..where((row) => row.rowId.equals(mutation.rowId))
              ..where((row) => row.revision.equals(mutation.revision)))
            .go();
        promoted += 1;
      });
    }

    return promoted;
  }

  Future<int> promoteAvailableForContext({
    required String uid,
    required String generationId,
    int limit = 500,
  }) async {
    final context = SyncActiveContext(uid: uid, generationId: generationId);
    final rows = await _db.customSelect(
      'select collection,row_id,op,revision,mutation_epoch,causal_uid, '
      'causal_generation_id,causal_base_state, '
      'cast(base_updated_at as integer) as base_updated_at, '
      'cast(recorded_at as integer) as recorded_at '
      'from sync_local_mutations order by mutation_epoch limit ?',
      variables: [Variable<int>(limit)],
    ).get();
    final observed =
        rows.map(_ObservedMutation.fromRow).toList(growable: false);

    var promoted = 0;
    for (final mutation in observed) {
      if (!_eligibleForContext(mutation, context)) continue;
      await _db.transaction(() async {
        await _pendingQueue.enqueueGenerationBound(
          uid: context.uid,
          generationId: context.generationId,
          tableType: mutation.collection,
          rowId: mutation.rowId,
          op: _pendingOp(mutation.op),
          baseState: mutation.causalBaseState,
          baseUpdatedAt: mutation.baseUpdatedAt,
          mutationId: _mutationIdFactory(),
          queuedAt: mutation.recordedAt,
        );
        final removed = await (_db.delete(_db.syncLocalMutations)
              ..where((row) => row.collection.equals(mutation.collection))
              ..where((row) => row.rowId.equals(mutation.rowId))
              ..where((row) => row.revision.equals(mutation.revision)))
            .go();
        if (removed > 0) {
          promoted += 1;
        }
      });
    }
    return promoted;
  }

  bool _eligibleForContext(
    _ObservedMutation mutation,
    SyncActiveContext activeContext,
  ) {
    if (mutation.causalBaseState == 'unbound') return false;
    if (mutation.causalUid != activeContext.uid ||
        mutation.causalGenerationId != activeContext.generationId) {
      return false;
    }

    return switch (mutation.causalBaseState) {
      'knownAbsent' => mutation.baseUpdatedAt == null,
      'knownVersion' => mutation.baseUpdatedAt != null,
      _ => false,
    };
  }

  static PendingSyncOp _pendingOp(String value) => switch (value) {
        'upsert' => PendingSyncOp.upsert,
        'delete' => PendingSyncOp.delete,
        _ => throw StateError('Unknown local mutation op: $value'),
      };

  static String _nextMutationId() {
    _mutationSequence += 1;
    final micros = DateTime.now().toUtc().microsecondsSinceEpoch;
    return '$micros-$_mutationSequence';
  }
}

class _ObservedMutation {
  const _ObservedMutation({
    required this.collection,
    required this.rowId,
    required this.op,
    required this.revision,
    required this.causalUid,
    required this.causalGenerationId,
    required this.causalBaseState,
    required this.baseUpdatedAt,
    required this.recordedAt,
  });

  factory _ObservedMutation.fromRow(QueryRow row) {
    final baseMillis = row.readNullable<int>('base_updated_at');
    return _ObservedMutation(
      collection: row.read<String>('collection'),
      rowId: row.read<String>('row_id'),
      op: row.read<String>('op'),
      revision: row.read<int>('revision'),
      causalUid: row.readNullable<String>('causal_uid'),
      causalGenerationId: row.readNullable<String>('causal_generation_id'),
      causalBaseState: row.read<String>('causal_base_state'),
      baseUpdatedAt: baseMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(baseMillis, isUtc: true),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('recorded_at'),
        isUtc: true,
      ),
    );
  }

  final String collection;
  final String rowId;
  final String op;
  final int revision;
  final String? causalUid;
  final String? causalGenerationId;
  final String causalBaseState;
  final DateTime? baseUpdatedAt;
  final DateTime recordedAt;
}
