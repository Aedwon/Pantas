import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';

void main() {
  test('9 to 10 adds a nullable unscored_items column and keeps rows',
      () async {
    final db = ContentDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('''
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
            )''');
          raw
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
