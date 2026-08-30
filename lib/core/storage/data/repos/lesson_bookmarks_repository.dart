import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';

/// Lessons the student marked to come back to. Ordering by subject is not here
/// on purpose: it needs the subject tree, which lives in `ContentRepository`,
/// and is composed a layer up.
class LessonBookmarksRepository {
  LessonBookmarksRepository(
    this._db, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> mark(LessonId lessonId) async {
    final placed = await _minimumSortIndex();
    await _syncRecorder.runRecorded(
      collection: 'lesson_bookmarks',
      rowId: lessonId,
      op: SyncLocalMutationOp.upsert,
      mutate: () => _db.into(_db.lessonBookmarksLocal).insertOnConflictUpdate(
            LessonBookmarksLocalCompanion(
              lessonId: Value(lessonId),
              markedAt: Value(DateTime.now()),
              sortIndex: placed == null ? const Value(null) : Value(placed - 1),
              syncState: Value(SyncState.pending.name),
            ),
          ),
    );
  }

  Future<void> unmark(LessonId lessonId) => _syncRecorder.runRecorded(
        collection: 'lesson_bookmarks',
        rowId: lessonId,
        op: SyncLocalMutationOp.delete,
        mutate: () => (_db.delete(_db.lessonBookmarksLocal)
              ..where((row) => row.lessonId.equals(lessonId)))
            .go(),
      );

  Future<void> unmarkAll(Iterable<LessonId> lessonIds) async {
    final ids = lessonIds.toList();
    if (ids.isEmpty) return;
    await _syncRecorder.runRecordedBatch(
      mutations: [
        for (final id in ids)
          SyncMutationTarget(
            collection: 'lesson_bookmarks',
            rowId: id,
            op: SyncLocalMutationOp.delete,
          ),
      ],
      mutate: () => (_db.delete(_db.lessonBookmarksLocal)
            ..where((row) => row.lessonId.isIn(ids)))
          .go(),
    );
  }

  Future<bool> isMarked(LessonId lessonId) async {
    final row = await (_db.select(_db.lessonBookmarksLocal)
          ..where((bookmark) => bookmark.lessonId.equals(lessonId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<LessonId>> markedIds() async {
    final rows = await _db.select(_db.lessonBookmarksLocal).get();
    return rows.map((row) => row.lessonId).toSet();
  }

  Future<List<LessonBookmarkLocalRow>> recentFirst() {
    return (_db.select(_db.lessonBookmarksLocal)
          ..orderBy([(row) => OrderingTerm.desc(row.markedAt)]))
        .get();
  }

  Future<List<LessonBookmarkLocalRow>> oldestFirst() {
    return (_db.select(_db.lessonBookmarksLocal)
          ..orderBy([(row) => OrderingTerm.asc(row.markedAt)]))
        .get();
  }

  Future<List<LessonBookmarkLocalRow>> customOrder() {
    return (_db.select(_db.lessonBookmarksLocal)
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.sortIndex,
                  nulls: NullsOrder.last,
                ),
            (row) => OrderingTerm.desc(row.markedAt),
          ]))
        .get();
  }

  Future<void> reorder(List<LessonId> lessonIdsInOrder) =>
      _syncRecorder.runRecordedBatch(
        mutations: [
          for (final id in lessonIdsInOrder)
            SyncMutationTarget(
              collection: 'lesson_bookmarks',
              rowId: id,
              op: SyncLocalMutationOp.upsert,
            ),
        ],
        mutate: () async {
          for (var index = 0; index < lessonIdsInOrder.length; index++) {
            await (_db.update(_db.lessonBookmarksLocal)
                  ..where(
                    (row) => row.lessonId.equals(lessonIdsInOrder[index]),
                  ))
                .write(
              LessonBookmarksLocalCompanion(
                sortIndex: Value(index),
                syncState: Value(SyncState.pending.name),
              ),
            );
          }
        },
      );

  Future<void> clearCustomOrder() async {
    final rows = await _db.select(_db.lessonBookmarksLocal).get();
    if (rows.isEmpty) return;
    await _syncRecorder.runRecordedBatch(
      mutations: [
        for (final row in rows)
          SyncMutationTarget(
            collection: 'lesson_bookmarks',
            rowId: row.lessonId,
            op: SyncLocalMutationOp.upsert,
          ),
      ],
      mutate: () => _db.update(_db.lessonBookmarksLocal).write(
            LessonBookmarksLocalCompanion(
              sortIndex: const Value(null),
              syncState: Value(SyncState.pending.name),
            ),
          ),
    );
  }

  Future<int> count() async {
    final total = _db.lessonBookmarksLocal.lessonId.count();
    final query = _db.selectOnly(_db.lessonBookmarksLocal)..addColumns([total]);
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  Future<int?> _minimumSortIndex() async {
    final smallest = _db.lessonBookmarksLocal.sortIndex.min();
    final query = _db.selectOnly(_db.lessonBookmarksLocal)
      ..addColumns([smallest]);
    final row = await query.getSingle();
    return row.read(smallest);
  }
}
