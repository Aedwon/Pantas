import 'dart:async';

import 'package:drift/drift.dart' show Variable;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';

enum SyncLocalMutationOp {
  upsert,
  delete;

  String get storageValue => name;
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

  final AppDatabase _db;
  final SyncActiveContextStore _activeContextStore;
  final SyncRowMetaRepository _rowMetaRepository;
  final DateTime Function() _now;

  Future<T> runRecorded<T>({
    required String collection,
    required String rowId,
    required SyncLocalMutationOp op,
    required FutureOr<T> Function() mutate,
  }) async {
    final candidateContext = await _activeContextStore.readSnapshot();

    return _db.transaction(() async {
      final result = await mutate();
      final currentContext = await _activeContextStore.readSnapshot();

      var causalBase = const SyncCausalBase.unbound();
      String? causalUid;
      String? causalGenerationId;

      final candidate = candidateContext?.context;
      final stillStable = candidate != null &&
          currentContext != null &&
          currentContext.token == candidateContext!.token &&
          currentContext.context == candidate;

      if (stillStable) {
        final acceptedBase = await _rowMetaRepository.readAcceptedBase(
          collection: collection,
          rowId: rowId,
        );
        if (acceptedBase != null &&
            acceptedBase.state != SyncCausalBaseState.unbound) {
          causalBase = acceptedBase;
          causalUid = candidate.uid;
          causalGenerationId = candidate.generationId;
        }
      }

      final mutationEpoch = await _advanceEpoch();
      final revision = await _nextRevision(
        collection: collection,
        rowId: rowId,
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
          collection,
          rowId,
          op.storageValue,
          revision,
          mutationEpoch,
          causalUid,
          causalGenerationId,
          causalBase.state.storageValue,
          causalBase.updatedAt?.toUtc().millisecondsSinceEpoch,
          recordedAt.millisecondsSinceEpoch,
        ],
      );

      return result;
    });
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
