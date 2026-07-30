import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<List<String>> tableNames(GeneratedDatabase database) async {
    final rows = await database
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name not like 'sqlite_%' order by name",
        )
        .get();
    return rows.map((row) => row.read<String>('name')).toList();
  }

  test(
    'app database creates pending_sync and sync_meta at current schema version',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(db.schemaVersion, greaterThanOrEqualTo(5));
      expect(
        await tableNames(db),
        containsAll(<String>[
          'pending_sync',
          'sync_meta',
        ]),
      );
    },
  );

  test('pending_sync coalesces tableType and rowId through a unique index',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queuedAt = DateTime.utc(2026, 5, 18);

    await db.into(db.pendingSync).insert(
          PendingSyncCompanion.insert(
            tableType: 'quiz_attempts',
            rowId: 'attempt_1',
            op: 'upsert',
            queuedAt: queuedAt,
          ),
        );

    expect(
      () => db.into(db.pendingSync).insert(
            PendingSyncCompanion.insert(
              tableType: 'quiz_attempts',
              rowId: 'attempt_1',
              op: 'delete',
              queuedAt: queuedAt.add(const Duration(seconds: 1)),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('sync_meta stores one value per key', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.syncMeta).insert(
          SyncMetaCompanion.insert(
            key: 'deviceId',
            value: 'device-1',
          ),
        );
    await db.into(db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(
            key: 'deviceId',
            value: 'device-2',
          ),
        );

    final row = await db.select(db.syncMeta).getSingle();
    expect(row.value, equals('device-2'));
  });

  test('content database schema does not include pending sync metadata',
      () async {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await tableNames(db), isNot(contains('pending_sync')));
    expect(await tableNames(db), isNot(contains('sync_meta')));
  });
}
