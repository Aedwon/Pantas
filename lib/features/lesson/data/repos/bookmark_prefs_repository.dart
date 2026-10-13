import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/features/lesson/domain/models/bookmark_order.dart';

class BookmarkRemoval {
  const BookmarkRemoval({
    required this.examId,
    required this.rows,
    required this.order,
  });
  final String examId;
  final List<LessonBookmarkLocalRow> rows;
  final List<String> order;
}

/// Account prefs carry each exam's sort and JSON lesson-id order.
/// The existing schema and synced row shape stay the same.
class BookmarkPrefsRepository {
  BookmarkPrefsRepository(this._db);
  static const orderKey = 'bookmark_order';
  final AppDatabase _db;

  Future<String?> _read(String key) async =>
      (await (_db.select(_db.accountPrefs)..where((r) => r.key.equals(key)))
              .getSingleOrNull())
          ?.value;
  Future<void> _write(String key, String value) =>
      _db.into(_db.accountPrefs).insertOnConflictUpdate(
            AccountPrefsCompanion.insert(key: key, value: value),
          );

  Future<BookmarkOrder> readOrder({String? examId}) async {
    if (examId == null) return BookmarkOrder.fromStorage(await _read(orderKey));
    final saved = await _read('bookmark_sort.$examId');
    if (saved != null) return BookmarkOrder.fromStorage(saved);
    final legacy = BookmarkOrder.fromStorage(await _read(orderKey));
    await saveOrder(legacy, examId: examId);
    return legacy;
  }

  Future<void> saveOrder(BookmarkOrder order, {String? examId}) => _write(
        examId == null ? orderKey : 'bookmark_sort.$examId',
        order.storageValue,
      );

  Future<List<String>> readCustomOrder(
    String examId, {
    List<String>? legacyOrder,
  }) async {
    final raw = await _read('bookmark_order.$examId');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List<Object?> && decoded.every((v) => v is String)) {
          return decoded.cast<String>().toSet().toList();
        }
      } on FormatException {
        /* Use the saved membership when a preference is malformed. */
      }
    }
    final ids = legacyOrder ??
        [
          for (final row in await LessonBookmarksRepository(_db).customOrder())
            row.lessonId,
        ];
    await saveCustomOrder(examId, ids);
    return ids;
  }

  Future<void> saveCustomOrder(String examId, List<String> ids) =>
      _write('bookmark_order.$examId', jsonEncode(ids.toSet().toList()));

  Future<BookmarkRemoval> remove(String examId, Set<String> ids) =>
      _db.transaction(() async {
        final rows = await (_db.select(_db.lessonBookmarksLocal)
              ..where((r) => r.lessonId.isIn(ids)))
            .get();
        final order = await readCustomOrder(examId);
        await LessonBookmarksRepository(_db).unmarkAll(ids);
        await saveCustomOrder(
          examId,
          order.where((id) => !ids.contains(id)).toList(),
        );
        return BookmarkRemoval(examId: examId, rows: rows, order: order);
      });

  Future<void> restore(BookmarkRemoval removal) => _db.transaction(() async {
        await LocalSyncMutationRecorder.forDatabase(_db).runRecordedBatch(
          mutations: [
            for (final row in removal.rows)
              SyncMutationTarget(
                collection: 'lesson_bookmarks',
                rowId: row.lessonId,
                op: SyncLocalMutationOp.upsert,
              ),
          ],
          mutate: () async {
            for (final row in removal.rows) {
              await _db.into(_db.lessonBookmarksLocal).insertOnConflictUpdate(
                    LessonBookmarksLocalCompanion.insert(
                      lessonId: row.lessonId,
                      markedAt: row.markedAt,
                      sortIndex: Value(row.sortIndex),
                      syncState: Value(SyncState.pending.name),
                    ),
                  );
            }
          },
        );
        final current = await readCustomOrder(removal.examId);
        // Keep new bookmarks, then restore the exact prior positions.
        await saveCustomOrder(removal.examId, [
          ...current.where((id) => !removal.order.contains(id)),
          ...removal.order,
        ]);
      });
}
