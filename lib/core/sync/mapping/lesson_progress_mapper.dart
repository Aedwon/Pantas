import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';

class LessonProgressMapper implements SyncMapper {
  const LessonProgressMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'lesson_progress';

  String documentId(LessonProgressLocalRow row) => row.lessonId;

  Map<String, Object?> toFirestore(
    LessonProgressLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'lessonId': row.lessonId,
      'readAt': row.readAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  LessonProgressLocalRow fromFirestore(Map<String, Object?> doc) {
    return LessonProgressLocalRow(
      lessonId: doc['lessonId']! as String,
      readAt: DateTime.parse(doc['readAt']! as String),
      syncState: 'synced',
    );
  }

  LessonProgressLocalCompanion toCompanion(LessonProgressLocalRow row) {
    return LessonProgressLocalCompanion(
      lessonId: Value(row.lessonId),
      readAt: Value(row.readAt),
      syncState: Value(row.syncState),
    );
  }
}
