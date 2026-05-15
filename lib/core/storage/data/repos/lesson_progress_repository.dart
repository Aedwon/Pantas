import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:drift/drift.dart';

class LessonProgressRepository {
  LessonProgressRepository(this._db);

  final AppDatabase _db;

  Future<void> markRead(LessonId lessonId) async {
    await _db.into(_db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion.insert(
            lessonId: lessonId,
            readAt: DateTime.now(),
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
    final lessonIds = await (_db.select(_db.lessons)
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
