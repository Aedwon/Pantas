import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('new installs create the lesson bookmarks table', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final tables = await db
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name = 'lesson_bookmarks_local'",
        )
        .get();

    expect(
      tables.map((row) => row.read<String>('name')).toList(),
      equals(['lesson_bookmarks_local']),
    );
  });

  test('a bookmark row round-trips with a null sort index', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final markedAt = DateTime.utc(2026, 8, 2, 9, 30);
    await db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: 'l1',
            markedAt: markedAt,
          ),
        );

    final rows = await db.select(db.lessonBookmarksLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.lessonId, 'l1');
    expect(rows.single.markedAt, markedAt);
    expect(rows.single.sortIndex, isNull);
    expect(rows.single.syncState, 'pending');
  });
}
