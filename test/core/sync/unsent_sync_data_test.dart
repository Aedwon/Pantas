import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/unsent_sync_data.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('an empty device has nothing unsent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    expect(await hasUnsentSyncData(db), isFalse);
  });

  test('a queued change is unsent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.pendingSync).insert(
          PendingSyncCompanion.insert(
            tableType: 'attempts',
            rowId: 'r1',
            op: 'upsert',
            queuedAt: DateTime(2026, 11, 23),
          ),
        );
    expect(await hasUnsentSyncData(db), isTrue);
  });

  test('a recorded local change waiting to be promoted is unsent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.customStatement(
      'insert into sync_local_mutations (collection, row_id, op, revision, '
      'mutation_epoch, causal_base_state, recorded_at) '
      "values ('attempts', 'r1', 'upsert', 1, 1, 'unbound', 1)",
    );
    expect(await hasUnsentSyncData(db), isTrue);
  });

  test('a first full upload that has not run is unsent, a pull is not',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.syncMeta).insert(
          const SyncMetaCompanion(
            key: Value('pending_full_pull'),
            value: Value('1'),
          ),
        );
    expect(await hasUnsentSyncData(db), isFalse);
    await db.into(db.syncMeta).insert(
          const SyncMetaCompanion(
            key: Value('pending_full_push'),
            value: Value('1'),
          ),
        );
    expect(await hasUnsentSyncData(db), isTrue);
  });
}
