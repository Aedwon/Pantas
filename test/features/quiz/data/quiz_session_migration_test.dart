import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
      'v23 migration adds outcomes and closes only answered legacy '
      'active sessions', () async {
    final temp = await Directory.systemTemp.createTemp('pantas-quiz-v23-');
    addTearDown(() => temp.delete(recursive: true));
    final file = File('${temp.path}/legacy.db');
    sqlite.sqlite3.open(file.path)
      ..execute(
        'create table quiz_sessions ( '
        'id text not null primary key, '
        'user_id text not null, exam_id text not null, origin text not null, '
        'topic_id text null, subtopic_id text null, lesson_id text null, '
        'question_ids_json text not null, '
        'current_index integer not null default 0, '
        'correct_count integer not null default 0, '
        'started_at integer not null, last_answered_at integer null, '
        'completed_at integer null, quit_at integer null)',
      )
      ..execute(
        'insert into quiz_sessions '
        '(id,user_id,exam_id,origin,question_ids_json,current_index,'
        'correct_count,started_at,last_answered_at) values '
        "('answered','local','exam','today_topic','[\"q1\",\"q2\"]',1,1,10,20)",
      )
      ..execute(
        'insert into quiz_sessions '
        '(id,user_id,exam_id,origin,question_ids_json,current_index,'
        'correct_count,started_at) values '
        "('untouched','local','exam-b','today_topic','[\"q3\"]',0,0,30)",
      )
      ..execute('pragma user_version = 23')
      ..close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final columns =
        await db.customSelect('pragma table_info(quiz_sessions)').get();
    expect(
      columns.map((row) => row.read<String>('name')),
      contains('outcomes_json'),
    );

    final rows = await db
        .customSelect(
          'select id,outcomes_json,current_index,quit_at '
          'from quiz_sessions order by id',
        )
        .get();
    expect(rows, hasLength(2));

    final answered =
        rows.firstWhere((row) => row.read<String>('id') == 'answered');
    expect(answered.read<String>('outcomes_json'), '[]');
    expect(answered.read<int>('current_index'), 1);
    expect(answered.readNullable<int>('quit_at'), isNotNull);

    final untouched =
        rows.firstWhere((row) => row.read<String>('id') == 'untouched');
    expect(untouched.read<String>('outcomes_json'), '[]');
    expect(untouched.read<int>('current_index'), 0);
    expect(untouched.readNullable<int>('quit_at'), isNull);
  });
}
