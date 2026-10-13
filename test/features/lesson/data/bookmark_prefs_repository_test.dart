import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:pantas/features/lesson/domain/models/bookmark_order.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late BookmarkPrefsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = BookmarkPrefsRepository(db);
  });

  tearDown(() => db.close());

  test('an untouched install reads the default order', () async {
    expect(await repo.readOrder(), BookmarkOrder.recent);
  });

  test('a chosen order round-trips', () async {
    await repo.saveOrder(BookmarkOrder.custom);

    expect(await repo.readOrder(), BookmarkOrder.custom);
  });

  test('a stored value nobody recognises falls back rather than throwing',
      () async {
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(
            key: BookmarkPrefsRepository.orderKey,
            value: 'sideways',
          ),
        );

    expect(await repo.readOrder(), BookmarkOrder.recent);
  });

  test('first scoped read preserves the legacy sort independently', () async {
    await repo.saveOrder(BookmarkOrder.oldest);
    expect(await repo.readOrder(examId: 'e1'), BookmarkOrder.oldest);
    await repo.saveOrder(BookmarkOrder.recent);
    expect(await repo.readOrder(examId: 'e1'), BookmarkOrder.oldest);
    expect(await repo.readOrder(examId: 'e2'), BookmarkOrder.recent);
  });

  test('Undo restores timestamps and positions without losing new bookmarks',
      () async {
    await repo.saveCustomOrder('e1', ['a', 'b', 'c']);
    final timestamp = DateTime(2026, 10);
    await db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: 'b',
            markedAt: timestamp,
          ),
        );
    final removal = await repo.remove('e1', {'b'});
    await repo.saveCustomOrder('e1', ['d', 'a', 'c']);
    await repo.restore(removal);
    expect(await repo.readCustomOrder('e1'), ['d', 'a', 'b', 'c']);
    final row = await (db.select(db.lessonBookmarksLocal)
          ..where((r) => r.lessonId.equals('b')))
        .getSingle();
    expect(row.markedAt, timestamp);
  });

  test('custom order migrates once and remains isolated per exam', () async {
    expect(
      await repo.readCustomOrder('e1', legacyOrder: ['a', 'b']),
      ['a', 'b'],
    );
    await repo.saveCustomOrder('e1', ['b', 'a']);
    expect(await repo.readCustomOrder('e2', legacyOrder: ['c']), ['c']);
    expect(await repo.readCustomOrder('e1', legacyOrder: ['c']), ['b', 'a']);
    await repo.saveOrder(BookmarkOrder.custom, examId: 'e1');
    await repo.saveOrder(BookmarkOrder.oldest, examId: 'e2');
    expect(await repo.readOrder(examId: 'e1'), BookmarkOrder.custom);
    expect(await repo.readOrder(examId: 'e2'), BookmarkOrder.oldest);
  });

  test('clearing account preferences does not restore a prior account order',
      () async {
    await repo.saveCustomOrder('e1', ['private-lesson']);
    await repo.saveOrder(BookmarkOrder.custom, examId: 'e1');
    await db.delete(db.accountPrefs).go();
    expect(await repo.readCustomOrder('e1', legacyOrder: const []), isEmpty);
    expect(await repo.readOrder(examId: 'e1'), BookmarkOrder.recent);
  });
}
