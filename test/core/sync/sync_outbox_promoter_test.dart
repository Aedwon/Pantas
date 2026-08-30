import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_outbox_promoter.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  final v1 = DateTime.utc(2026, 8, 30, 1);
  final v2 = DateTime.utc(2026, 8, 30, 2);
  final recordedAt = DateTime.utc(2026, 8, 30, 3);

  test('stable bound knownAbsent promotes to matching generation', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contextStore = SyncActiveContextStore(db);
    await contextStore.publishStable(uid: 'u1', generationId: 'g1');
    await _insertJournal(
      db,
      collection: 'quiz_attempts',
      rowId: 'a1',
      causalUid: 'u1',
      causalGenerationId: 'g1',
      causalBaseState: 'knownAbsent',
      revision: 1,
      recordedAt: recordedAt,
    );

    final promoter = SyncOutboxPromoter(
      db,
      activeContextStore: contextStore,
      pendingQueue: PendingQueue(db),
      mutationIdFactory: () => 'mutation-1',
    );

    expect(await promoter.promoteAvailable(), 1);

    final pending = (await PendingQueue(db).drain(limit: 10)).single;
    expect(pending.uid, 'u1');
    expect(pending.generationId, 'g1');
    expect(pending.tableType, 'quiz_attempts');
    expect(pending.rowId, 'a1');
    expect(pending.baseState, 'knownAbsent');
    expect(pending.baseUpdatedAt, isNull);
    expect(pending.mutationId, 'mutation-1');
    expect(pending.revision, 1);
    expect(await _journalCount(db), 0);
  });

  test('knownVersion V1 is never replaced by later accepted V2', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contextStore = SyncActiveContextStore(db);
    await contextStore.publishStable(uid: 'u1', generationId: 'g1');
    await _insertJournal(
      db,
      collection: 'fsrs_cards',
      rowId: 'q1',
      causalUid: 'u1',
      causalGenerationId: 'g1',
      causalBaseState: 'knownVersion',
      baseUpdatedAt: v1,
      revision: 4,
      recordedAt: recordedAt,
    );
    await SyncRowMetaRepository(db).acceptKnownVersion(
      collection: 'fsrs_cards',
      rowId: 'q1',
      updatedAt: v2,
    );

    await SyncOutboxPromoter(
      db,
      activeContextStore: contextStore,
      pendingQueue: PendingQueue(db),
      mutationIdFactory: () => 'mutation-v1',
    ).promoteAvailable();

    final pending = (await PendingQueue(db).drain(limit: 10)).single;
    expect(pending.baseState, 'knownVersion');
    expect(pending.baseUpdatedAt, v1);
    expect(pending.mutationId, 'mutation-v1');
  });

  test('unbound event never incrementally promotes after later accepted V2',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contextStore = SyncActiveContextStore(db);
    await contextStore.publishStable(uid: 'u1', generationId: 'g1');
    await _insertJournal(
      db,
      collection: 'lesson_progress',
      rowId: 'l1',
      causalBaseState: 'unbound',
      revision: 1,
      recordedAt: recordedAt,
    );
    await SyncRowMetaRepository(db).acceptKnownVersion(
      collection: 'lesson_progress',
      rowId: 'l1',
      updatedAt: v2,
    );

    final promoted = await SyncOutboxPromoter(
      db,
      activeContextStore: contextStore,
      pendingQueue: PendingQueue(db),
      mutationIdFactory: () => 'must-not-be-used',
    ).promoteAvailable();

    expect(promoted, 0);
    expect(await PendingQueue(db).drain(limit: 10), isEmpty);
    expect(await _journalCount(db), 1);
  });

  test('old uid or generation work is never retargeted', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contextStore = SyncActiveContextStore(db);
    await contextStore.publishStable(uid: 'u2', generationId: 'g2');
    await _insertJournal(
      db,
      collection: 'assessments',
      rowId: 'cse',
      causalUid: 'u1',
      causalGenerationId: 'g1',
      causalBaseState: 'knownAbsent',
      revision: 1,
      recordedAt: recordedAt,
    );

    expect(
      await SyncOutboxPromoter(
        db,
        activeContextStore: contextStore,
        pendingQueue: PendingQueue(db),
      ).promoteAvailable(),
      0,
    );
    expect(await PendingQueue(db).drain(limit: 10), isEmpty);
    expect(await _journalCount(db), 1);
  });

  test('journal revision N+1 survives acknowledgement of observed N', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contextStore = SyncActiveContextStore(db);
    await contextStore.publishStable(uid: 'u1', generationId: 'g1');
    await _insertJournal(
      db,
      collection: 'question_flags',
      rowId: 'q1',
      causalUid: 'u1',
      causalGenerationId: 'g1',
      causalBaseState: 'knownAbsent',
      revision: 1,
      recordedAt: recordedAt,
    );

    final queue = _HookedPendingQueue(
      db,
      beforeEnqueue: () => _insertJournal(
        db,
        collection: 'question_flags',
        rowId: 'q1',
        causalUid: 'u1',
        causalGenerationId: 'g1',
        causalBaseState: 'knownAbsent',
        revision: 2,
        recordedAt: recordedAt.add(const Duration(seconds: 1)),
      ),
    );

    await SyncOutboxPromoter(
      db,
      activeContextStore: contextStore,
      pendingQueue: queue,
      mutationIdFactory: () => 'mutation-n1',
    ).promoteAvailable();

    final exact = await db
        .customSelect(
          "select revision from sync_local_mutations "
          "where collection = 'question_flags' and row_id = 'q1'",
        )
        .getSingle();
    expect(exact.read<int>('revision'), 2);
  });

  test('same logical row remains distinct across uid and generation', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final now = DateTime.utc(2026, 8, 30, 4);

    await queue.enqueueGenerationBound(
      uid: 'u1',
      generationId: 'g1',
      tableType: 'quiz_attempts',
      rowId: 'a1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'm1',
      queuedAt: now,
    );
    await queue.enqueueGenerationBound(
      uid: 'u1',
      generationId: 'g2',
      tableType: 'quiz_attempts',
      rowId: 'a1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'm2',
      queuedAt: now,
    );
    await queue.enqueueGenerationBound(
      uid: 'u2',
      generationId: 'g1',
      tableType: 'quiz_attempts',
      rowId: 'a1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'm3',
      queuedAt: now,
    );

    expect(await queue.drain(limit: 10), hasLength(3));
  });
}

class _HookedPendingQueue extends PendingQueue {
  _HookedPendingQueue(
    super.db, {
    required this.beforeEnqueue,
  });

  final Future<void> Function() beforeEnqueue;

  @override
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
    await beforeEnqueue();
    return super.enqueueGenerationBound(
      uid: uid,
      generationId: generationId,
      tableType: tableType,
      rowId: rowId,
      op: op,
      baseState: baseState,
      baseUpdatedAt: baseUpdatedAt,
      mutationId: mutationId,
      queuedAt: queuedAt,
    );
  }
}

Future<void> _insertJournal(
  AppDatabase db, {
  required String collection,
  required String rowId,
  required String causalBaseState,
  required int revision,
  required DateTime recordedAt,
  String? causalUid,
  String? causalGenerationId,
  DateTime? baseUpdatedAt,
}) {
  return db.customStatement(
    'insert into sync_local_mutations '
    '(collection,row_id,op,revision,mutation_epoch,causal_uid,'
    'causal_generation_id,causal_base_state,base_updated_at,recorded_at) '
    'values (?,?,?,?,?,?,?,?,?,?) '
    'on conflict(collection,row_id) do update set '
    'op=excluded.op,revision=excluded.revision,mutation_epoch=excluded.mutation_epoch,'
    'causal_uid=excluded.causal_uid,causal_generation_id=excluded.causal_generation_id,'
    'causal_base_state=excluded.causal_base_state,base_updated_at=excluded.base_updated_at,'
    'recorded_at=excluded.recorded_at',
    <Object?>[
      collection,
      rowId,
      'upsert',
      revision,
      revision,
      causalUid,
      causalGenerationId,
      causalBaseState,
      baseUpdatedAt?.millisecondsSinceEpoch,
      recordedAt.millisecondsSinceEpoch,
    ],
  );
}

Future<int> _journalCount(AppDatabase db) async {
  final row = await db
      .customSelect(
        'select count(*) as count from sync_local_mutations',
      )
      .getSingle();
  return row.read<int>('count');
}
