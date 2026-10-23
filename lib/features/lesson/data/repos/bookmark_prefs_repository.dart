import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
import 'package:pantas/features/lesson/domain/models/bookmark_order.dart';

class BookmarkRemoval {
  const BookmarkRemoval({
    required this.examId,
    required this.rows,
    required this.order,
    required this.boundaryToken,
  });
  final String examId;
  final String boundaryToken;
  final List<LessonBookmarkLocalRow> rows;
  final List<String> order;
}

/// Account prefs carry each exam's sort and JSON lesson-id order.
/// The existing schema and synced row shape stay the same.
class BookmarkPrefsRepository {
  BookmarkPrefsRepository(this._db);
  static const orderKey = 'bookmark_order';
  final AppDatabase _db;
  late final _guard = ReaderPositionRepository(
    AppPreferencesRepository(_db),
    database: _db,
  );

  Future<String?> captureToken({required bool Function() isCurrent}) =>
      _guard.captureToken(isCurrent: isCurrent);

  Future<String?> readToken() async =>
      (await SyncActiveContextStore(_db).readSnapshot())?.token;

  Future<bool> isBoundaryCurrent(
    ReaderBoundary boundary, {
    required bool Function() isCurrent,
  }) =>
      _guard.isBoundaryCurrent(boundary, isCurrent: isCurrent);

  Future<T> _guarded<T>(
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
    Future<T> Function() operation,
  ) async {
    if (boundary == null) return operation();
    late T result;
    final valid = await _guard.runGuarded(
      boundary,
      () async {
        result = await operation();
      },
      isCurrent: isCurrent!,
    );
    if (!valid) throw const BookmarkActionExpired();
    return result;
  }

  Future<String?> _read(String key) async =>
      (await (_db.select(_db.accountPrefs)..where((r) => r.key.equals(key)))
              .getSingleOrNull())
          ?.value;
  Future<void> _write(String key, String value) =>
      _db.into(_db.accountPrefs).insertOnConflictUpdate(
            AccountPrefsCompanion.insert(key: key, value: value),
          );

  Future<BookmarkOrder> readOrder({
    String? examId,
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) async {
    if (examId == null) return BookmarkOrder.fromStorage(await _read(orderKey));
    final current = isCurrent ?? () => true;
    final captured = boundary ??
        (isCurrent == null
            ? await _guard.readBoundary(examId, isCurrent: current)
            : null);
    if (!current()) throw const BookmarkActionExpired();
    final saved = await _read('bookmark_sort.$examId');
    if (saved != null) {
      await _validateRead(captured, current);
      return BookmarkOrder.fromStorage(saved);
    }
    final legacy = BookmarkOrder.fromStorage(await _read(orderKey));
    if (captured != null) {
      await saveOrder(
        legacy,
        examId: examId,
        boundary: captured,
        isCurrent: current,
      );
    }
    await _validateRead(captured, current);
    return legacy;
  }

  Future<void> saveOrder(
    BookmarkOrder order, {
    String? examId,
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) =>
      _guarded(
        boundary,
        isCurrent,
        () => _write(
          examId == null ? orderKey : 'bookmark_sort.$examId',
          order.storageValue,
        ),
      );

  Future<List<String>> readCustomOrder(
    String examId, {
    List<String>? legacyOrder,
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) async {
    final current = isCurrent ?? () => true;
    final captured = boundary ??
        (isCurrent == null
            ? await _guard.readBoundary(examId, isCurrent: current)
            : null);
    if (!current()) throw const BookmarkActionExpired();
    final raw = await _read('bookmark_order.$examId');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List<Object?> && decoded.every((v) => v is String)) {
          await _validateRead(captured, current);
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
    if (captured != null) {
      await saveCustomOrder(
        examId,
        ids,
        boundary: captured,
        isCurrent: current,
      );
    }
    await _validateRead(captured, current);
    return ids;
  }

  Future<void> _validateRead(
    ReaderBoundary? boundary,
    bool Function() current,
  ) async {
    if (!current() ||
        (boundary != null &&
            !await _guard.isBoundaryCurrent(boundary, isCurrent: current))) {
      throw const BookmarkActionExpired();
    }
  }

  Future<void> saveCustomOrder(
    String examId,
    List<String> ids, {
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) =>
      _guarded(
        boundary,
        isCurrent,
        () => _write(
          'bookmark_order.$examId',
          jsonEncode(ids.toSet().toList()),
        ),
      );

  Future<BookmarkRemoval> remove(
    String examId,
    Set<String> ids, {
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) =>
      _guarded(
        boundary,
        isCurrent,
        () => _db.transaction(() async {
          final contexts = SyncActiveContextStore(_db);
          final snapshot = await contexts.readSnapshot();
          if (snapshot == null) throw const BookmarkActionExpired();
          final rows = await (_db.select(_db.lessonBookmarksLocal)
                ..where((r) => r.lessonId.isIn(ids)))
              .get();
          final order = await readCustomOrder(examId, isCurrent: () => true);
          await LessonBookmarksRepository(_db).unmarkAll(ids);
          await saveCustomOrder(
            examId,
            order.where((id) => !ids.contains(id)).toList(),
          );
          return BookmarkRemoval(
            examId: examId,
            rows: rows,
            order: order,
            boundaryToken: snapshot.token,
          );
        }),
      );

  Future<bool> isRemovalCurrent(BookmarkRemoval removal) async {
    final snapshot = await SyncActiveContextStore(_db).readSnapshot();
    if (snapshot == null || snapshot.token != removal.boundaryToken) {
      return false;
    }
    final exam = await AppPreferencesRepository(_db).selectedExamId();
    return exam == null || exam == removal.examId;
  }

  /// An expired token returns false without writing membership or preferences.
  Future<bool> restore(
    BookmarkRemoval removal, {
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) =>
      _guarded(
        boundary,
        isCurrent,
        () => _db.transaction(() async {
          if (!await isRemovalCurrent(removal)) return false;
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
          final current =
              await readCustomOrder(removal.examId, isCurrent: () => true);
          // Keep new bookmarks, then restore the exact prior positions.
          await saveCustomOrder(removal.examId, [
            ...current.where((id) => !removal.order.contains(id)),
            ...removal.order,
          ]);
          return true;
        }),
      );
}

class BookmarkActionExpired implements Exception {
  const BookmarkActionExpired();
}
