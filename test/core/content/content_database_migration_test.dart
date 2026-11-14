import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';

void main() {
  test('10 to 11 keeps lesson and question rows with metadata defaults',
      () async {
    final db = ContentDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute(
              'CREATE TABLE content_lessons (id TEXT PRIMARY KEY, title TEXT)',
            )
            ..execute("INSERT INTO content_lessons VALUES ('old', 'Kept')")
            ..execute('CREATE TABLE content_questions (id TEXT PRIMARY KEY)')
            ..execute("INSERT INTO content_questions VALUES ('q')")
            ..execute('PRAGMA user_version = 10');
        },
      ),
    );
    addTearDown(db.close);
    final row =
        await db.customSelect('SELECT * FROM content_lessons').getSingle();
    expect(row.data, containsPair('title', 'Kept'));
    expect(row.data, containsPair('quiz_size', 5));
    expect(row.data, containsPair('status', 'active'));
    for (final key in [
      'replaced_by',
      'part',
      'part_count',
      'key_points_json',
    ]) {
      expect(row.data, containsPair(key, null));
    }
    final question =
        await db.customSelect('SELECT * FROM content_questions').getSingle();
    expect(question.data, {'id': 'q', 'key_point': null});
    expect(db.schemaVersion, 11);
  });

  test('9 to 10 adds a nullable unscored_items column and keeps rows',
      () async {
    final db = ContentDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute('CREATE TABLE content_lessons (id TEXT PRIMARY KEY)')
            ..execute('CREATE TABLE content_questions (id TEXT PRIMARY KEY)')
            ..execute('''
            CREATE TABLE content_mock_blueprints (
              id TEXT NOT NULL PRIMARY KEY,
              schema_version INTEGER NOT NULL,
              is_active INTEGER NOT NULL DEFAULT 1,
              updated_at TEXT NOT NULL,
              exam_id TEXT NOT NULL,
              name TEXT NOT NULL,
              duration_minutes INTEGER NOT NULL,
              sections_json TEXT NOT NULL,
              sectional_timing TEXT,
              score_bands_json TEXT,
              total_published_items INTEGER,
              source TEXT,
              source_note TEXT
            )''')
            ..execute(
              'INSERT INTO content_mock_blueprints VALUES '
              "('bp', 2, 1, '2026-05-17T00:00:00.000Z', 'exam', 'CSE', 90, "
              "'[]', NULL, NULL, 170, 'published', NULL)",
            )
            ..execute('PRAGMA user_version = 9');
        },
      ),
    );
    addTearDown(db.close);

    final rows = await db.select(db.contentMockBlueprints).get();
    expect(rows, hasLength(1));
    expect(rows.single.totalPublishedItems, 170);
    expect(rows.single.unscoredItems, isNull);
  });
}
