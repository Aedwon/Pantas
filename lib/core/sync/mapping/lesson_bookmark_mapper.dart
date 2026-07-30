import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';

class LessonBookmarkMapper implements SyncMapper {
  const LessonBookmarkMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'lesson_bookmarks';

  String documentId(LessonBookmarkLocalRow row) => row.lessonId;

  Map<String, Object?> toFirestore(
    LessonBookmarkLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'lessonId': row.lessonId,
      'markedAt': row.markedAt.toUtc().toIso8601String(),
      'sortIndex': row.sortIndex,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  LessonBookmarkLocalRow fromFirestore(Map<String, Object?> doc) {
    return LessonBookmarkLocalRow(
      lessonId: doc['lessonId']! as String,
      markedAt: DateTime.parse(doc['markedAt']! as String),
      sortIndex: doc['sortIndex'] as int?,
      syncState: 'synced',
    );
  }

  LessonBookmarksLocalCompanion toCompanion(LessonBookmarkLocalRow row) {
    return LessonBookmarksLocalCompanion(
      lessonId: Value(row.lessonId),
      markedAt: Value(row.markedAt),
      sortIndex: Value(row.sortIndex),
      syncState: Value(row.syncState),
    );
  }
}
