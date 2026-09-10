import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  Future<List<String>> tableNames(AppDatabase db) async {
    final rows = await db
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name not like 'sqlite_%' order by name",
        )
        .get();
    return rows.map((row) => row.read<String>('name')).toList();
  }

  Future<List<String>> columns(AppDatabase db, String table) async {
    final rows = await db.customSelect('pragma table_info($table)').get();
    return rows.map((row) => row.read<String>('name')).toList();
  }

  test('schema 24 creates the complete structured Sync state', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 24);
    expect(
      await tableNames(db),
      containsAll(<String>[
        'sync_row_meta',
        'sync_local_mutations',
        'pending_sync',
        'custom_track_meta_local',
        'sync_meta',
      ]),
    );

    expect(
      await columns(db, 'sync_local_mutations'),
      containsAll(<String>[
        'collection',
        'row_id',
        'op',
        'revision',
        'mutation_epoch',
        'causal_uid',
        'causal_generation_id',
        'causal_base_state',
        'base_updated_at',
        'recorded_at',
      ]),
    );
    expect(
      await columns(db, 'pending_sync'),
      containsAll(<String>[
        'uid',
        'generation_id',
        'table_type',
        'row_id',
        'op',
        'base_state',
        'base_updated_at',
        'mutation_id',
        'revision',
        'queued_at',
        'attempts',
        'last_error',
        'last_attempt_at',
      ]),
    );
  });

  test('causal base states round-trip without null ambiguity', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final v1 = DateTime.utc(2026, 8, 30, 1, 2, 3);
    final storedV1 = v1.millisecondsSinceEpoch;

    await db.customStatement(
      'insert into sync_local_mutations '
      '(collection,row_id,op,revision,mutation_epoch,causal_uid,'
      'causal_generation_id,causal_base_state,base_updated_at,recorded_at) '
      'values (?,?,?,?,?,?,?,?,?,?)',
      <Object?>[
        'quiz_attempts',
        'unbound',
        'upsert',
        1,
        1,
        null,
        null,
        'unbound',
        null,
        storedV1,
      ],
    );
    await db.customStatement(
      'insert into sync_local_mutations '
      '(collection,row_id,op,revision,mutation_epoch,causal_uid,'
      'causal_generation_id,causal_base_state,base_updated_at,recorded_at) '
      'values (?,?,?,?,?,?,?,?,?,?)',
      <Object?>[
        'quiz_attempts',
        'absent',
        'upsert',
        1,
        2,
        'uid-1',
        'gen-1',
        'knownAbsent',
        null,
        storedV1,
      ],
    );
    await db.customStatement(
      'insert into sync_local_mutations '
      '(collection,row_id,op,revision,mutation_epoch,causal_uid,'
      'causal_generation_id,causal_base_state,base_updated_at,recorded_at) '
      'values (?,?,?,?,?,?,?,?,?,?)',
      <Object?>[
        'quiz_attempts',
        'version',
        'upsert',
        1,
        3,
        'uid-1',
        'gen-1',
        'knownVersion',
        storedV1,
        storedV1,
      ],
    );

    final rows = await db
        .customSelect(
          'select row_id, causal_base_state, base_updated_at '
          'from sync_local_mutations order by mutation_epoch',
        )
        .get();

    expect(
      rows.map((row) => row.read<String>('causal_base_state')),
      ['unbound', 'knownAbsent', 'knownVersion'],
    );
    expect(rows[0].readNullable<int>('base_updated_at'), null);
    expect(rows[1].readNullable<int>('base_updated_at'), null);
    expect(rows[2].read<int>('base_updated_at'), storedV1);
  });

  test('domain tables do not gain Sync transport identity columns', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const domainTables = <String>[
      'attempts_local',
      'assessment_results_local',
      'review_state_local',
      'lesson_progress_local',
      'lesson_bookmarks_local',
      'question_flags_local',
      'mock_attempts',
      'review_logs',
      'track_scope_local',
      'custom_blueprints_local',
      'custom_track_meta_local',
    ];
    const forbidden = <String>{
      'uid',
      'generation_id',
      'base_updated_at',
      'mutation_id',
    };

    for (final table in domainTables) {
      expect(
        (await columns(db, table)).toSet().intersection(forbidden),
        isEmpty,
        reason: table,
      );
    }
  });

  test('version 22 migration preserves legacy user change facts as unbound',
      () async {
    final temp = await Directory.systemTemp.createTemp('pantas-sync-v22-');
    addTearDown(() => temp.delete(recursive: true));
    final file = File('${temp.path}/legacy.db');
    sqlite.sqlite3.open(file.path)
      ..execute(
        'create table quiz_sessions ( '
        'id text not null primary key, user_id text not null, '
        'exam_id text not null, origin text not null, topic_id text null, '
        'subtopic_id text null, lesson_id text null, '
        'question_ids_json text not null, '
        'current_index integer not null default 0, '
        'correct_count integer not null default 0, '
        'started_at integer not null, '
        'last_answered_at integer null, completed_at integer null, '
        'quit_at integer null)',
      )
      ..execute(
        'create table sync_meta ( '
        '"key" text not null primary key, "value" text not null)',
      )
      ..execute(
        'create table pending_sync ( '
        'id integer not null primary key autoincrement, '
        'table_type text not null, row_id text not null, op text not null, '
        'queued_at integer not null, attempts integer not null default 0, '
        'last_error text null, last_attempt_at integer null)',
      )
      ..execute(
        'create unique index pending_sync_table_row_idx '
        'on pending_sync (table_type, row_id)',
      )
      ..execute(
        "insert into sync_meta (key,value) values ('deviceId','device-legacy')",
      )
      ..execute(
        'insert into pending_sync '
        '(table_type,row_id,op,queued_at,attempts) '
        "values ('quiz_attempts','attempt-legacy','upsert',1,0)",
      )
      ..execute('pragma user_version = 22')
      ..close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final device = await db
        .customSelect(
          "select value from sync_meta where key = 'deviceId'",
        )
        .getSingle();
    expect(device.read<String>('value'), 'device-legacy');

    final journal = await db
        .customSelect(
          'select collection,row_id,op,causal_base_state '
          "from sync_local_mutations where row_id = 'attempt-legacy'",
        )
        .getSingle();
    expect(journal.read<String>('collection'), 'quiz_attempts');
    expect(journal.read<String>('op'), 'upsert');
    expect(journal.read<String>('causal_base_state'), 'unbound');

    expect(await db.customSelect('select * from pending_sync').get(), isEmpty);
    expect(
      await db.customSelect('select * from custom_track_meta_local').get(),
      isEmpty,
    );
  });
}
