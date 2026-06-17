import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('new installs create the question flags table', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final tables = await db
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name = 'question_flags_local'",
        )
        .get();

    expect(
      tables.map((row) => row.read<String>('name')).toList(),
      equals(['question_flags_local']),
    );
  });

  test('a flag row round-trips with a null sort index', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final flaggedAt = DateTime.utc(2026, 8, 2, 9, 30);
    await db.into(db.questionFlagsLocal).insert(
          QuestionFlagsLocalCompanion.insert(
            questionId: 'q1',
            flaggedAt: flaggedAt,
          ),
        );

    final rows = await db.select(db.questionFlagsLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.questionId, 'q1');
    expect(rows.single.flaggedAt, flaggedAt);
    expect(rows.single.sortIndex, isNull);
    expect(rows.single.syncState, 'pending');
  });
}
