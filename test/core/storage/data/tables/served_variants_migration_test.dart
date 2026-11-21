import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';

void main() {
  test('schema 27 rebuilds served variants and preserves review rows', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute('''
              CREATE TABLE review_state_local (
                question_id TEXT PRIMARY KEY, reps INTEGER NOT NULL
              )
            ''')
            ..execute("INSERT INTO review_state_local VALUES ('qt-test', 5)")
            ..execute('''
              CREATE TABLE attempts_local (
                started_at INTEGER, completed_at INTEGER, items_json TEXT
              )
            ''')
            ..execute('''
              INSERT INTO attempts_local VALUES
                (100, 120, '[{"questionId":"qt-test","variantIndex":0}]'),
                (140, 150, '[{"questionId":"qt-test","variantIndex":0}]'),
                (200, 220, '[{"questionId":"qt-test"}]')
            ''')
            ..execute('''
              CREATE TABLE mock_attempts (
                started_at INTEGER, submitted_at INTEGER, status TEXT,
                answers_json TEXT
              )
            ''')
            ..execute('''
              INSERT INTO mock_attempts VALUES
                (100, 400, 'completed',
                  '{"qt-test":{"variantIndex":1,"selectedIndex":0,"atSec":60}}'),
                (100, NULL, 'in_progress',
                  '{"qt-test":{"variantIndex":2,"selectedIndex":0,"atSec":90}}')
            ''')
            ..execute('CREATE TABLE quiz_sessions (id TEXT PRIMARY KEY)')
            ..execute("INSERT INTO quiz_sessions VALUES ('old')")
            ..execute('PRAGMA user_version = 26');
        },
      ),
    );
    addTearDown(db.close);

    final row = await db.customSelect(
      'SELECT reps, served_variants_json FROM review_state_local',
    ).getSingle();
    expect(row.read<int>('reps'), 5);
    expect(
      jsonDecode(row.read<String>('served_variants_json')),
      {'0': '1970-01-01T00:02:30Z', '1': '1970-01-01T00:02:40Z'},
    );
    final session = await db.customSelect(
      'SELECT variant_indexes_json FROM quiz_sessions',
    ).getSingle();
    expect(session.read<String>('variant_indexes_json'), '{}');
    expect(db.schemaVersion, 27);
  });
}
