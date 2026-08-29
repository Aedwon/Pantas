import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  const collection = 'quiz_attempts';
  const rowId = 'attempt-1';
  final recordedAt = DateTime.utc(2026, 8, 30, 2, 0);

  Future<Map<String, Object?>> journalRow(dynamic db) async {
    final row = await db.customSelect(
      'select collection,row_id,op,revision,mutation_epoch,causal_uid,'
      'causal_generation_id,causal_base_state,'
      'cast(base_updated_at as integer) as base_updated_at,recorded_at '
      'from sync_local_mutations where collection = ? and row_id = ?',
      variables: const [Variable<String>(collection), Variable<String>(rowId)],
    ).getSingle();
    return row.data;
  }

  Future<int> epoch(dynamic db) async {
    final rows = await db
        .customSelect(
          "select value from sync_meta where key = 'localMutationEpoch'",
        )
        .get();
    if (rows.isEmpty) return 0;
    return int.parse(rows.single.read<String>('value'));
  }

  Future<void> putDomainFact(dynamic db, String value) => db.customStatement(
        'insert into account_prefs (key,value) values (?,?) '
        'on conflict(key) do update set value=excluded.value',
        ['recorder-test', value],
      );

  LocalSyncMutationRecorder recorderFor(dynamic db) {
    return LocalSyncMutationRecorder(
      db,
      activeContextStore: SyncActiveContextStore(db),
      rowMetaRepository: SyncRowMetaRepository(db),
      now: () => recordedAt,
    );
  }

  test('no stable active context records unbound provenance', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final recorder = recorderFor(db);

    await recorder.runRecorded(
      collection: collection,
      rowId: rowId,
      op: SyncLocalMutationOp.upsert,
      mutate: () => putDomainFact(db, 'local'),
    );

    final row = await journalRow(db);
    expect(row['causal_base_state'], 'unbound');
    expect(row['causal_uid'], isNull);
    expect(row['causal_generation_id'], isNull);
    expect(row['base_updated_at'], isNull);
    expect(row['revision'], 1);
    expect(row['mutation_epoch'], 1);
    expect(await epoch(db), 1);
  });

  test('stable context plus accepted absence captures knownAbsent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final context = SyncActiveContextStore(db);
    final meta = SyncRowMetaRepository(db);
    final recorder = recorderFor(db);
    await context.publishStable(uid: 'uid-1', generationId: 'gen-1');
    await meta.acceptKnownAbsent(collection: collection, rowId: rowId);

    await recorder.runRecorded(
      collection: collection,
      rowId: rowId,
      op: SyncLocalMutationOp.upsert,
      mutate: () => putDomainFact(db, 'local'),
    );

    final row = await journalRow(db);
    expect(row['causal_base_state'], 'knownAbsent');
    expect(row['causal_uid'], 'uid-1');
    expect(row['causal_generation_id'], 'gen-1');
    expect(row['base_updated_at'], isNull);
  });

  test('stable context plus accepted V1 captures knownVersion V1', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final context = SyncActiveContextStore(db);
    final meta = SyncRowMetaRepository(db);
    final recorder = recorderFor(db);
    final v1 = DateTime.utc(2026, 8, 29, 12);
    await context.publishStable(uid: 'uid-1', generationId: 'gen-1');
    await meta.acceptKnownVersion(
      collection: collection,
      rowId: rowId,
      updatedAt: v1,
      originDeviceId: 'device-cloud',
    );

    await recorder.runRecorded(
      collection: collection,
      rowId: rowId,
      op: SyncLocalMutationOp.upsert,
      mutate: () => putDomainFact(db, 'local'),
    );

    final row = await journalRow(db);
    expect(row['causal_base_state'], 'knownVersion');
    expect(row['causal_uid'], 'uid-1');
    expect(row['causal_generation_id'], 'gen-1');
    expect(row['base_updated_at'], v1.millisecondsSinceEpoch);
  });

  test('context becoming unstable during transaction records unbound',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final context = SyncActiveContextStore(db);
    final meta = SyncRowMetaRepository(db);
    final recorder = recorderFor(db);
    await context.publishStable(uid: 'uid-1', generationId: 'gen-1');
    await meta.acceptKnownVersion(
      collection: collection,
      rowId: rowId,
      updatedAt: DateTime.utc(2026, 8, 29),
    );

    await recorder.runRecorded(
      collection: collection,
      rowId: rowId,
      op: SyncLocalMutationOp.upsert,
      mutate: () async {
        await putDomainFact(db, 'survives');
        await context.clearStable();
      },
    );

    final domain = await db
        .customSelect(
          "select value from account_prefs where key = 'recorder-test'",
        )
        .getSingle();
    expect(domain.read<String>('value'), 'survives');
    final row = await journalRow(db);
    expect(row['causal_base_state'], 'unbound');
    expect(row['causal_uid'], isNull);
    expect(row['causal_generation_id'], isNull);
    expect(row['base_updated_at'], isNull);
  });

  test('repeated edit advances revision and epoch', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final recorder = recorderFor(db);

    await recorder.runRecorded(
      collection: collection,
      rowId: rowId,
      op: SyncLocalMutationOp.upsert,
      mutate: () => putDomainFact(db, 'one'),
    );
    await recorder.runRecorded(
      collection: collection,
      rowId: rowId,
      op: SyncLocalMutationOp.delete,
      mutate: () => putDomainFact(db, 'two'),
    );

    final row = await journalRow(db);
    expect(row['revision'], 2);
    expect(row['mutation_epoch'], 2);
    expect(row['op'], 'delete');
    expect(await epoch(db), 2);
  });

  test('newer edit captures V2 while older observed revision retains V1',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final context = SyncActiveContextStore(db);
    final meta = SyncRowMetaRepository(db);
    final recorder = recorderFor(db);
    final v1 = DateTime.utc(2026, 8, 29, 12);
    final v2 = DateTime.utc(2026, 8, 29, 13);
    await context.publishStable(uid: 'uid-1', generationId: 'gen-1');
    await meta.acceptKnownVersion(
      collection: collection,
      rowId: rowId,
      updatedAt: v1,
    );
    await recorder.runRecorded(
      collection: collection,
      rowId: rowId,
      op: SyncLocalMutationOp.upsert,
      mutate: () => putDomainFact(db, 'one'),
    );
    final observedV1 = Map<String, Object?>.from(await journalRow(db));

    await meta.acceptKnownVersion(
      collection: collection,
      rowId: rowId,
      updatedAt: v2,
    );
    await recorder.runRecorded(
      collection: collection,
      rowId: rowId,
      op: SyncLocalMutationOp.upsert,
      mutate: () => putDomainFact(db, 'two'),
    );

    final current = await journalRow(db);
    expect(observedV1['revision'], 1);
    expect(observedV1['base_updated_at'], v1.millisecondsSinceEpoch);
    expect(current['revision'], 2);
    expect(current['base_updated_at'], v2.millisecondsSinceEpoch);
  });

  test('transaction rollback rolls back domain journal and epoch', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final recorder = recorderFor(db);

    await expectLater(
      recorder.runRecorded<void>(
        collection: collection,
        rowId: rowId,
        op: SyncLocalMutationOp.upsert,
        mutate: () async {
          await putDomainFact(db, 'rollback');
          throw StateError('fail transaction');
        },
      ),
      throwsStateError,
    );

    expect(
      await db
          .customSelect(
            "select * from account_prefs where key = 'recorder-test'",
          )
          .get(),
      isEmpty,
    );
    expect(await db.customSelect('select * from sync_local_mutations').get(),
        isEmpty);
    expect(await epoch(db), 0);
  });

  test('remote row-meta apply never records a local mutation', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final meta = SyncRowMetaRepository(db);

    await meta.acceptKnownAbsent(collection: collection, rowId: rowId);
    await meta.acceptKnownVersion(
      collection: collection,
      rowId: rowId,
      updatedAt: DateTime.utc(2026, 8, 29),
    );

    expect(await db.customSelect('select * from sync_local_mutations').get(),
        isEmpty);
    expect(await epoch(db), 0);
  });
}
