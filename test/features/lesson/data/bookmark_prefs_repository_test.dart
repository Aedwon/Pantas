import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
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

  for (final custom in [true, false]) {
    test('held ${custom ? 'custom' : 'sort'} migration cannot cross reset',
        () async {
      final contexts = SyncActiveContextStore(db);
      await contexts.publishStable(uid: 'a', generationId: 'g1');
      final held = _HeldMigrationPrefs(db)..armed = true;
      if (!custom) await repo.saveOrder(BookmarkOrder.oldest);
      final pending = custom
          ? held.readCustomOrder('e1', legacyOrder: ['old'])
          : held.readOrder(examId: 'e1');
      await held.entered.future;
      await SyncLocalStateWiper(db).wipeAll();
      await contexts.publishStable(uid: 'a', generationId: 'g2');
      await repo.saveCustomOrder('e1', ['fresh']);
      await repo.saveOrder(BookmarkOrder.recent, examId: 'e1');
      held.release.complete();
      await expectLater(pending, throwsA(isA<BookmarkActionExpired>()));
      expect(await repo.readCustomOrder('e1'), ['fresh']);
      expect(await repo.readOrder(examId: 'e1'), BookmarkOrder.recent);
    });
  }

  test('absent envelope fallback reads never persist or initialize', () async {
    await SyncLocalStateWiper(db).wipeAll();
    expect(await repo.readCustomOrder('e1', legacyOrder: ['old']), ['old']);
    expect(await repo.readOrder(examId: 'e1'), BookmarkOrder.recent);
    expect(await db.select(db.accountPrefs).get(), isEmpty);
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
  });

  test('Remove without captured context cannot initialize or mutate', () async {
    await LessonBookmarksRepository(db).mark('old');
    await repo.saveCustomOrder('e1', ['old']);
    await expectLater(
      repo.remove('e1', {'old'}),
      throwsA(isA<BookmarkActionExpired>()),
    );
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    expect(await LessonBookmarksRepository(db).markedIds(), {'old'});
    expect(await repo.readCustomOrder('e1'), ['old']);
  });

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
    await SyncActiveContextStore(db).clearStable();
    await repo.saveOrder(BookmarkOrder.oldest);
    expect(await repo.readOrder(examId: 'e1'), BookmarkOrder.oldest);
    await repo.saveOrder(BookmarkOrder.recent);
    expect(await repo.readOrder(examId: 'e1'), BookmarkOrder.oldest);
    expect(await repo.readOrder(examId: 'e2'), BookmarkOrder.recent);
  });

  test('Undo restores timestamps and positions without losing new bookmarks',
      () async {
    await repo.captureToken(isCurrent: () => true);
    await repo.saveCustomOrder('e1', ['a', 'b', 'c']);
    final timestamp = DateTime(2026, 10);
    await db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: 'b',
            markedAt: timestamp,
            sortIndex: const Value(4),
          ),
        );
    final removal = await repo.remove('e1', {'b'});
    await LessonBookmarksRepository(db).mark('d');
    await repo.saveCustomOrder('e1', ['d', 'a', 'c']);
    await repo.restore(removal);
    expect(await repo.readCustomOrder('e1'), ['d', 'a', 'b', 'c']);
    final row = await (db.select(db.lessonBookmarksLocal)
          ..where((r) => r.lessonId.equals('b')))
        .getSingle();
    expect(row.markedAt, timestamp);
    expect(row.sortIndex, 4);
    expect(await LessonBookmarksRepository(db).markedIds(), {'b', 'd'});
  });

  test('custom order migrates once and remains isolated per exam', () async {
    await SyncActiveContextStore(db).clearStable();
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

  test('removal preserves a recognized active boundary through ordinary Undo',
      () async {
    final contexts = SyncActiveContextStore(db);
    await contexts.publishStable(uid: 'same', generationId: 'g1');
    final before = await contexts.readSnapshot();
    await LessonBookmarksRepository(db).mark('old');
    await repo.saveCustomOrder('e1', ['old']);
    final removal = await repo.remove('e1', {'old'});
    expect(removal.boundaryToken, before!.token);
    expect((await contexts.readSnapshot())!.token, before.token);
    expect(await repo.restore(removal), isTrue);
    final after = await contexts.readSnapshot();
    expect(after!.token, before.token);
    expect(after.context, before.context);
    expect(await LessonBookmarksRepository(db).markedIds(), {'old'});
  });

  test('held Undo cannot resurrect guest rows after the real wipe path',
      () async {
    final bookmarks = LessonBookmarksRepository(db);
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    await bookmarks.mark('old');
    await repo.saveCustomOrder('e1', ['old']);
    await repo.captureToken(isCurrent: () => true);
    final removal = await repo.remove('e1', {'old'});
    final initialized = await SyncActiveContextStore(db).readSnapshot();
    expect(initialized!.context, isNull);
    expect(initialized.token, removal.boundaryToken);
    await SyncLocalStateWiper(db).wipeAll();
    await repo.readCustomOrder('e1', legacyOrder: const []);
    expect(await repo.restore(removal), isFalse);
    expect(await bookmarks.markedIds(), isEmpty);
    expect(await repo.readCustomOrder('e1'), isEmpty);
  });

  test('held Undo cannot import rows into the next active account', () async {
    final contexts = SyncActiveContextStore(db);
    final bookmarks = LessonBookmarksRepository(db);
    await contexts.publishStable(uid: 'before', generationId: 'g1');
    await bookmarks.mark('old');
    await repo.saveCustomOrder('e1', ['old']);
    final removal = await repo.remove('e1', {'old'});
    await contexts.clearStable();
    await SyncLocalStateWiper(db).wipeAll();
    await contexts.publishStable(uid: 'after', generationId: 'g2');
    await bookmarks.mark('new-a');
    await bookmarks.mark('new-b');
    await repo.saveCustomOrder('e1', ['new-b', 'new-a']);
    expect(await repo.restore(removal), isFalse);
    expect(await bookmarks.markedIds(), {'new-a', 'new-b'});
    expect(await repo.readCustomOrder('e1'), ['new-b', 'new-a']);
  });

  test('held Undo expires when the existing boundary token rotates', () async {
    final contexts = SyncActiveContextStore(db);
    final bookmarks = LessonBookmarksRepository(db);
    await contexts.clearStable();
    await bookmarks.mark('old');
    await repo.saveCustomOrder('e1', ['old']);
    final removal = await repo.remove('e1', {'old'});
    await contexts.clearStable();
    expect(await repo.restore(removal), isFalse);
    expect(await bookmarks.markedIds(), isEmpty);
    expect(await repo.readCustomOrder('e1'), isEmpty);
  });

  test('held Undo cannot restore the previous exam while another is selected',
      () async {
    final preferences = AppPreferencesRepository(db);
    final bookmarks = LessonBookmarksRepository(db);
    await preferences.setSelectedExamId('e1');
    await repo.captureToken(isCurrent: () => true);
    await bookmarks.mark('old');
    await repo.saveCustomOrder('e1', ['old']);
    final removal = await repo.remove('e1', {'old'});
    await preferences.setSelectedExamId('e2');
    expect(await repo.restore(removal), isFalse);
    expect(await bookmarks.markedIds(), isEmpty);
    expect(await repo.readCustomOrder('e1'), isEmpty);
  });
}

class _HeldMigrationPrefs extends BookmarkPrefsRepository {
  _HeldMigrationPrefs(super.db);
  bool armed = false;
  final entered = Completer<void>();
  final release = Completer<void>();
  Future<void> hold() async {
    if (!armed) return;
    armed = false;
    entered.complete();
    await release.future;
  }

  @override
  Future<void> saveCustomOrder(
    String examId,
    List<String> ids, {
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) async {
    await hold();
    return super
        .saveCustomOrder(examId, ids, boundary: boundary, isCurrent: isCurrent);
  }

  @override
  Future<void> saveOrder(
    BookmarkOrder order, {
    String? examId,
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) async {
    await hold();
    return super.saveOrder(
      order,
      examId: examId,
      boundary: boundary,
      isCurrent: isCurrent,
    );
  }
}
