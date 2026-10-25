import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/data/repos/bookmark_prefs_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late LessonBookmarksRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    repo = LessonBookmarksRepository(db);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Chemistry',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'Lesson l1',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 13,
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't1',
      title: 'Lesson l2',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 10,
    );

    await seedContentSubject(
      contentDb,
      subjectId: 's2',
      examId: 'e1',
      name: 'Math',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't2',
      subjectId: 's2',
      name: 'Algebra',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l3',
      topicId: 't2',
      title: 'Lesson l3',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 15,
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l4',
      topicId: 't2',
      title: 'Lesson l4',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 12,
    );

    await container
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('e1');
  });

  Future<List<BookmarkRow>> readRows() {
    // Model the sheet's active subscription while async invalidations settle.
    container.listen(bookmarkRowsProvider, (_, __) {});
    return container.read(bookmarkRowsProvider.future);
  }

  for (final dispose in [false, true]) {
    test('legacy membership held before migration reset dispose=$dispose',
        () async {
      await SyncActiveContextStore(db).clearStable();
      await repo.mark('l1');
      final held = _HeldLegacyMembership(db);
      final owner = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          lessonBookmarksRepositoryProvider.overrideWithValue(held),
        ],
      );
      if (!dispose) addTearDown(owner.dispose);
      owner.listen(bookmarkRowsProvider, (_, __) {});
      final pending = owner.read(bookmarkRowsProvider.future);
      final completion = pending.then<List<BookmarkRow>?>(
        (rows) => rows,
        onError: (Object _) => null,
      );
      await held.entered.future;
      await SyncLocalStateWiper(db).wipeAll();
      await SyncActiveContextStore(db)
          .publishStable(uid: 'fresh', generationId: 'g2');
      await AppPreferencesRepository(db).setSelectedExamId('e1');
      await repo.mark('l2');
      final prefs = BookmarkPrefsRepository(db);
      await prefs.saveCustomOrder('e1', ['l2']);
      await prefs.saveOrder(BookmarkOrder.recent, examId: 'e1');
      if (dispose) owner.dispose();
      held.release.complete();
      await completion;
      expect(await prefs.readCustomOrder('e1'), ['l2']);
      expect(await prefs.readOrder(examId: 'e1'), BookmarkOrder.recent);
    });
  }

  test('absent-token provider rejects rows fetched before replacement',
      () async {
    await repo.mark('l1');
    final held = _HeldLegacyMembership(db);
    final owner = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        lessonBookmarksRepositoryProvider.overrideWithValue(held),
      ],
    );
    addTearDown(owner.dispose);
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    owner.listen(bookmarkRowsProvider, (_, __) {});
    final pending = owner.read(bookmarkRowsProvider.future);
    final completion = pending.then<List<BookmarkRow>?>(
      (rows) => rows,
      onError: (Object _) => null,
    );
    await held.entered.future;
    await SyncLocalStateWiper(db).wipeAll();
    await SyncActiveContextStore(db)
        .publishStable(uid: 'fresh', generationId: 'g2');
    await AppPreferencesRepository(db).setSelectedExamId('e1');
    await repo.mark('l2');
    final prefs = BookmarkPrefsRepository(db);
    await prefs.saveCustomOrder('e1', ['l2']);
    held.release.complete();
    final rows = (await completion) ?? const <BookmarkRow>[];
    expect(rows.map((row) => row.lessonId), isNot(contains('l1')));
    expect(await prefs.readCustomOrder('e1'), ['l2']);
  });

  for (final change in ['wipe', 'membership', 'preferences']) {
    test('absent-token held read reacts to $change before publication',
        () async {
      await repo.mark('l1');
      if (change == 'preferences') await repo.mark('l2');
      final prefs = BookmarkPrefsRepository(db);
      if (change == 'preferences') {
        await prefs.saveOrder(BookmarkOrder.oldest, examId: 'e1');
      }
      final held = _HeldLegacyMembership(db);
      final owner = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          lessonBookmarksRepositoryProvider.overrideWithValue(held),
        ],
      );
      addTearDown(owner.dispose);
      owner.listen(bookmarkRowsProvider, (_, __) {});
      final pending = owner.read(bookmarkRowsProvider.future);
      final completion = pending.then<List<BookmarkRow>?>(
        (rows) => rows,
        onError: (Object _) => null,
      );
      await held.entered.future;
      if (change == 'wipe') {
        await SyncLocalStateWiper(db).wipeAll();
      } else if (change == 'membership') {
        await repo.unmark('l1');
        await repo.mark('l2');
      } else {
        await prefs.saveOrder(BookmarkOrder.recent, examId: 'e1');
      }
      held.release.complete();
      final rows = (await completion) ?? const <BookmarkRow>[];
      if (change == 'preferences') {
        expect(rows.first.lessonId, 'l2');
        expect(
          await owner.read(bookmarkOrderProvider.future),
          BookmarkOrder.recent,
        );
      } else {
        expect(rows.map((r) => r.lessonId), isNot(contains('l1')));
      }
      expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    });
  }

  test('sort is stored per exam and leaves the legacy value intact', () async {
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(key: 'bookmark_order', value: 'oldest'),
        );
    expect(
      await container.read(bookmarkOrderProvider.future),
      BookmarkOrder.oldest,
    );
    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.custom);
    final scoped = await (db.select(db.accountPrefs)
          ..where((row) => row.key.equals('bookmark_sort.e1')))
        .getSingleOrNull();
    expect(scoped?.value, 'custom');
    final legacy = await (db.select(db.accountPrefs)
          ..where((row) => row.key.equals('bookmark_order')))
        .getSingle();
    expect(legacy.value, 'oldest');
  });
  test('recent order is newest first', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l3');

    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.recent);

    expect(
      (await readRows()).map((row) => row.lessonId).toList(),
      ['l3', 'l1'],
    );
  });

  test('oldest order is its reverse', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l3');

    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.oldest);

    expect(
      (await readRows()).map((row) => row.lessonId).toList(),
      ['l1', 'l3'],
    );
  });

  test('by subject follows the corpus, not the marking', () async {
    // l3 is in the second subject and was marked first.
    await repo.mark('l3');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l1');

    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.bySubject);

    expect(
      (await readRows()).map((row) => row.lessonId).toList(),
      ['l1', 'l3'],
    );
  });

  test('custom order puts hand-placed rows ahead of unplaced ones', () async {
    await repo.mark('l1');
    await repo.mark('l3');
    await repo.reorder(['l3']);

    await container
        .read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.custom);

    expect(
      (await readRows()).map((row) => row.lessonId).toList(),
      ['l3', 'l1'],
    );
  });

  test('a row carries the title, topic and minutes its row prints', () async {
    await repo.mark('l1');

    final row = (await readRows()).single;

    expect(row.title, 'Lesson l1');
    expect(row.topicName, 'Chemistry');
    expect(row.estimatedMinutes, 13);
  });

  test('a bookmark whose lesson is gone is dropped, not drawn blank', () async {
    await repo.mark('l1');
    await db.delete(db.lessonBookmarksLocal).go();
    await db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: 'l_missing',
            markedAt: DateTime.now(),
          ),
        );

    expect(await readRows(), isEmpty);
  });

  test('the count is the number of rows', () async {
    await repo.mark('l1');
    await repo.mark('l3');

    expect(await container.read(bookmarkCountProvider.future), 2);
  });
}

class _HeldLegacyMembership extends LessonBookmarksRepository {
  _HeldLegacyMembership(super.db);
  final entered = Completer<void>();
  final release = Completer<void>();
  bool held = false;
  @override
  Future<List<LessonBookmarkLocalRow>> customOrder() async {
    final rows = await super.customOrder();
    if (!held) {
      held = true;
      entered.complete();
      await release.future;
    }
    return rows;
  }
}
