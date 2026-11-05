import 'dart:async';

import 'package:drift/drift.dart' show TableUpdate, Variable;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_held_generation.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';

enum SyncLocalMutationOp {
  upsert,
  delete;

  String get storageValue => name;
}

class SyncMutationTarget {
  const SyncMutationTarget({
    required this.collection,
    required this.rowId,
    required this.op,
  });

  final String collection;
  final String rowId;
  final SyncLocalMutationOp op;
}

class LocalSyncMutationRecorder {
  LocalSyncMutationRecorder(
    this._db, {
    required SyncActiveContextStore activeContextStore,
    required SyncRowMetaRepository rowMetaRepository,
    DateTime Function()? now,
  })  : _activeContextStore = activeContextStore,
        _rowMetaRepository = rowMetaRepository,
        _now = now ?? DateTime.now;

  factory LocalSyncMutationRecorder.forDatabase(AppDatabase db) =>
      LocalSyncMutationRecorder(
        db,
        activeContextStore: SyncActiveContextStore(db),
        rowMetaRepository: SyncRowMetaRepository(db),
      );

  final AppDatabase _db;
  final SyncActiveContextStore _activeContextStore;
  final SyncRowMetaRepository _rowMetaRepository;
  final DateTime Function() _now;

  Future<T> runRecorded<T>({
    required String collection,
    required String rowId,
    required SyncLocalMutationOp op,
    required FutureOr<T> Function() mutate,
  }) =>
      runRecordedBatch(
        mutations: [
          SyncMutationTarget(collection: collection, rowId: rowId, op: op),
        ],
        mutate: mutate,
      );

  Future<T> runRecordedBatch<T>({
    required Iterable<SyncMutationTarget> mutations,
    required FutureOr<T> Function() mutate,
  }) async {
    final targets = mutations.toList(growable: false);
    final candidateContext = await _activeContextStore.readSnapshot();

    return _db.transaction(() async {
      final result = await mutate();
      if (targets.isEmpty) return result;

      final currentContext = await _activeContextStore.readSnapshot();
      final candidate = candidateContext?.context;
      final stillStable = candidate != null &&
          currentContext != null &&
          currentContext.token == candidateContext!.token &&
          currentContext.context == candidate;

      // The live generation, or while Sync is stopped the one this device's
      // data is still a copy of. The accepted state is frozen here, at the
      // moment of the change, whichever it is.
      final held = SyncHeldGeneration(_db);
      final context = stillStable ? candidate : await held.read();

      for (final target in targets) {
        var causalBase = const SyncCausalBase.unbound();
        String? causalUid;
        String? causalGenerationId;

        final kept =
            context == null ? null : await _unresolvedEntry(target, context);
        if (kept != null) {
          // The entry's question is still open, whatever this edit is. Taking
          // the accepted state now would hide it: a row that lost to another
          // device's copy would read as absent, and a tie elsewhere would move.
          causalBase = kept.base;
          causalUid = kept.uid;
          causalGenerationId = kept.generationId;
        } else if (context != null) {
          causalUid = context.uid;
          causalGenerationId = context.generationId;
          final acceptedBase = await _rowMetaRepository.readAcceptedBase(
            collection: target.collection,
            rowId: target.rowId,
          );
          if (acceptedBase != null &&
              acceptedBase.state != SyncCausalBaseState.unbound) {
            causalBase = acceptedBase;
          } else if (await held.isSnapshotComplete(
            generationId: context.generationId,
            collection: target.collection,
          )) {
            // The whole collection has been seen, so the cloud lacks this row.
            causalBase = const SyncCausalBase.knownAbsent();
          }
          // Otherwise unknown until the first snapshot: it stays unbound, with
          // its account and generation, and that snapshot settles it.
        }

        final mutationEpoch = await _advanceEpoch();
        final revision = await _nextRevision(
          collection: target.collection,
          rowId: target.rowId,
        );
        final recordedAt = _now().toUtc();

        await _db.customStatement(
          'insert into sync_local_mutations '
          '(collection,row_id,op,revision,mutation_epoch,causal_uid,'
          'causal_generation_id,causal_base_state,base_updated_at,recorded_at) '
          'values (?,?,?,?,?,?,?,?,?,?) '
          'on conflict(collection,row_id) do update set '
          'op=excluded.op, revision=excluded.revision, '
          'mutation_epoch=excluded.mutation_epoch, '
          'causal_uid=excluded.causal_uid, '
          'causal_generation_id=excluded.causal_generation_id, '
          'causal_base_state=excluded.causal_base_state, '
          'base_updated_at=excluded.base_updated_at, '
          'recorded_at=excluded.recorded_at',
          <Object?>[
            target.collection,
            target.rowId,
            target.op.storageValue,
            revision,
            mutationEpoch,
            causalUid,
            causalGenerationId,
            causalBase.state.storageValue,
            causalBase.updatedAt?.toUtc().millisecondsSinceEpoch,
            recordedAt.millisecondsSinceEpoch,
          ],
        );
      }

      // A raw statement does not wake the engine's watch on the journal.
      _db.notifyUpdates({TableUpdate.onTable(_db.syncLocalMutations)});
      return result;
    });
  }

  /// The journal entry for [target] if it is unbound or tied elsewhere than
  /// [context]. Only the full choice settles those.
  Future<_UnresolvedEntry?> _unresolvedEntry(
    SyncMutationTarget target,
    SyncActiveContext context,
  ) async {
    final row = await _db.customSelect(
      'select causal_uid,causal_generation_id,causal_base_state, '
      'cast(base_updated_at as integer) as base_updated_at '
      'from sync_local_mutations where collection = ? and row_id = ?',
      variables: [
        Variable<String>(target.collection),
        Variable<String>(target.rowId),
      ],
    ).getSingleOrNull();
    if (row == null) return null;
    final uid = row.readNullable<String>('causal_uid');
    final generationId = row.readNullable<String>('causal_generation_id');
    final state = row.read<String>('causal_base_state');
    if (state != SyncCausalBaseState.unbound.storageValue &&
        uid == context.uid &&
        generationId == context.generationId) {
      return null;
    }
    final millis = row.readNullable<int>('base_updated_at');
    return _UnresolvedEntry(
      uid: uid,
      generationId: generationId,
      base: state == SyncCausalBaseState.knownAbsent.storageValue
          ? const SyncCausalBase.knownAbsent()
          : state == SyncCausalBaseState.knownVersion.storageValue &&
                  millis != null
              ? SyncCausalBase.knownVersion(
                  DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
                )
              : const SyncCausalBase.unbound(),
    );
  }

  Future<int> readMutationEpoch() async {
    final rows = await _db
        .customSelect(
          "select value from sync_meta where key = 'localMutationEpoch'",
        )
        .get();
    if (rows.isEmpty) return 0;
    final raw = rows.single.read<String>('value');
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 0) {
      throw StateError('Invalid localMutationEpoch: $raw');
    }
    return parsed;
  }

  Future<int> _advanceEpoch() async {
    final next = await readMutationEpoch() + 1;
    await _db.customStatement(
      'insert into sync_meta (key,value) values (?,?) '
      'on conflict(key) do update set value=excluded.value',
      <Object?>['localMutationEpoch', '$next'],
    );
    return next;
  }

  Future<int> _nextRevision({
    required String collection,
    required String rowId,
  }) async {
    final rows = await _db.customSelect(
      'select revision from sync_local_mutations '
      'where collection = ? and row_id = ?',
      variables: [
        Variable<String>(collection),
        Variable<String>(rowId),
      ],
    ).get();
    if (rows.isEmpty) return 1;
    return rows.single.read<int>('revision') + 1;
  }
}

class _UnresolvedEntry {
  const _UnresolvedEntry({
    required this.uid,
    required this.generationId,
    required this.base,
  });

  final String? uid;
  final String? generationId;
  final SyncCausalBase base;
}
