import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';

const e05Indexes = <String>{
  'content_questions_topic_active_idx',
  'content_question_exams_exam_question_idx',
  'content_choices_question_active_order_idx',
};

void main() {
  Future<Set<String>> indexes(ContentDatabase db) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    return {for (final row in rows) row.read<String>('name')};
  }

  Future<String> plan(ContentDatabase db, String sql) async {
    final rows = await db.customSelect('EXPLAIN QUERY PLAN $sql').get();
    return rows.map((row) => row.read<String>('detail')).join(' | ');
  }

  test(
      'fresh schema 10 creates only the E05 indexes required by measured plans',
      () async {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 10);
    expect(await indexes(db), containsAll(e05Indexes));

    expect(
      await plan(
        db,
        'SELECT id, version, topic_id, lesson_id, passage_id, '
        'figure_spec_json FROM content_questions '
        "WHERE topic_id = 'topic' AND is_active = 1",
      ),
      contains('content_questions_topic_active_idx'),
    );
    expect(
      await plan(
        db,
        "SELECT question_id FROM content_question_exams WHERE exam_id = 'exam'",
      ),
      contains('content_question_exams_exam_question_idx'),
    );
    final choicePlan = await plan(
      db,
      "SELECT * FROM content_choices WHERE question_id IN ('q1','q2') "
      'AND is_active = 1 ORDER BY question_id, ordering',
    );
    expect(choicePlan, contains('content_choices_question_active_order_idx'));
    expect(choicePlan, isNot(contains('USE TEMP B-TREE')));
  });

  test('schema 8 upgrade creates the same required E05 indexes', () async {
    final dir = await Directory.systemTemp.createTemp('pantas_e05_schema_');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/content.db');

    final fixture = ContentDatabase(NativeDatabase(file));
    for (final name in e05Indexes) {
      await fixture.customStatement('DROP INDEX $name');
    }
    await fixture.customStatement(
      'ALTER TABLE content_mock_blueprints DROP COLUMN unscored_items',
    );
    await fixture.customStatement('PRAGMA user_version = 8');
    await fixture.close();

    final upgraded = ContentDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    expect(upgraded.schemaVersion, 10);
    expect(await indexes(upgraded), containsAll(e05Indexes));
    expect(
      await plan(
        upgraded,
        'SELECT id FROM content_questions '
        "WHERE topic_id = 'topic' AND is_active = 1",
      ),
      contains('content_questions_topic_active_idx'),
    );
  });
}
