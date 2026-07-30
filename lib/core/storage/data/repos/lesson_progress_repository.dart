import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';
import 'package:drift/drift.dart';

/// What a student has read is theirs; which lessons a topic has is corpus.
/// Counting the first against the second is why this holds both databases.
class LessonProgressRepository {
  LessonProgressRepository(this._db, this._contentDb);

  final AppDatabase _db;
  final ContentDatabase _contentDb;

  Future<void> markRead(LessonId lessonId) async {
    // readAt updates on every call: records most-recent confirmation,
    // not first-read time.
    await _db.into(_db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion(
            lessonId: Value(lessonId),
            readAt: Value(DateTime.now()),
            syncState: Value(SyncState.pending.name),
          ),
        );
  }

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
