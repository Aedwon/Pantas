import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';

class LessonRepo {
  LessonRepo(this._db);

  final ContentDatabase _db;
  ContentDatabase get database => _db;

  Future<List<Lesson>> byTopic(TopicId topicId) async {
    final rows = await (_db.select(_db.contentLessons)
          ..where(
            (row) => row.topicId.equals(topicId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.title)]))
        .get();
    return rows.map(_hydrateLesson).toList();
  }

  Future<Lesson?> findById(LessonId id) async {
    final row = await (_db.select(_db.contentLessons)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _hydrateLesson(row);
  }

  Lesson _hydrateLesson(ContentLessonRow row) {
    return Lesson(
      id: row.id,
      topicId: row.topicId,
      subtopicId: row.subtopicId,
      title: row.title,
      summary: row.summary,
      bodyJson: (jsonDecode(row.bodyJson) as List).cast<Map<String, dynamic>>(),
      estimatedMinutes: row.estimatedMinutes,
    );
  }
}
