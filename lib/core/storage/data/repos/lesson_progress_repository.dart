import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';

/// What a student has read is theirs; which lessons a topic has is corpus.
/// Counting the first against the second is why this holds both databases.
class LessonProgressRepository {
  LessonProgressRepository(
    this._db,
    this._contentDb, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> markRead(LessonId lessonId) => _syncRecorder.runRecorded(
        collection: 'lesson_progress',
        rowId: lessonId,
        op: SyncLocalMutationOp.upsert,
        mutate: () => _db.into(_db.lessonProgressLocal).insertOnConflictUpdate(
              LessonProgressLocalCompanion(
                lessonId: Value(lessonId),
                readAt: Value(DateTime.now()),
                syncState: Value(SyncState.pending.name),
              ),
            ),
      );

  Future<bool> isRead(LessonId lessonId) async {
    final row = await (_db.select(_db.lessonProgressLocal)
          ..where((p) => p.lessonId.equals(lessonId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<LessonId>> readLessonIds() async {
    final rows = await _db.select(_db.lessonProgressLocal).get();
    return rows.map((r) => r.lessonId).toSet();
  }

  Future<int> readCountForTopic(TopicId topicId) async {
    final lessonIds = await (_contentDb.select(_contentDb.contentLessons)
          ..where((l) => l.topicId.equals(topicId)))
        .map((r) => r.id)
        .get();
    if (lessonIds.isEmpty) return 0;
    final readRows = await (_db.select(_db.lessonProgressLocal)
          ..where((p) => p.lessonId.isIn(lessonIds)))
        .get();
    return readRows.length;
  }

  Future<bool> hasAnyRead() async {
    final row =
        await (_db.select(_db.lessonProgressLocal)..limit(1)).getSingleOrNull();
    return row != null;
  }
}
