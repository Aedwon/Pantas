import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/storage/data/app_database.dart';

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

  test('app database creates structured sync state at current schema version',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, equals(23));
    expect(
      await tableNames(db),
      containsAll(<String>[
        'pending_sync',
        'sync_meta',
        'sync_row_meta',
        'sync_local_mutations',
        'custom_track_meta_local',
      ]),
    );
  });

  test('pending_sync scopes row identity by uid and generation', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const queuedAt = 1788048000000;

    Future<void> insert(String uid, String generationId) => db.customStatement(
          'insert into pending_sync '
          '(uid,generation_id,table_type,row_id,op,base_state,mutation_id,'
          'revision,queued_at) values (?,?,?,?,?,?,?,?,?)',
          <Object?>[
            uid,
            generationId,
            'quiz_attempts',
            'attempt_1',
            'upsert',
            'knownAbsent',
            '$uid-$generationId',
            1,
            queuedAt,
          ],
        );

    await insert('uid-1', 'gen-1');
    await insert('uid-1', 'gen-2');
    await insert('uid-2', 'gen-1');

    expect(await db.customSelect('select * from pending_sync').get(),
        hasLength(3));
    expect(
      () => insert('uid-1', 'gen-1'),
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

  test('content database schema does not include app sync metadata', () async {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final tables = await tableNames(db);

    expect(tables, isNot(contains('pending_sync')));
    expect(tables, isNot(contains('sync_meta')));
    expect(tables, isNot(contains('sync_row_meta')));
    expect(tables, isNot(contains('sync_local_mutations')));
    expect(tables, isNot(contains('custom_track_meta_local')));
  });
}
