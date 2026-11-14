import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/repos/content_fetch_hook.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';

class LessonRepo {
  /// [fetchHook] is passed on web only; see [ContentFetchHook].
  LessonRepo(this._db, {ContentFetchHook? fetchHook}) : _fetchHook = fetchHook;

  final ContentDatabase _db;
  final ContentFetchHook? _fetchHook;
  ContentDatabase get database => _db;

  Future<List<Lesson>> byTopic(TopicId topicId) async {
    final rows = await (_db.select(_db.contentLessons)
          ..where(
            (row) =>
                row.topicId.equals(topicId) &
                row.isActive.equals(true) &
                row.status.equals('active'),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.title)]))
        .get();
    return rows.map(_hydrateLesson).toList();
  }

  /// A retired lesson resolves to the first id in its `replacedBy`, followed
  /// through chains. A loop or a retired lesson that replaces nothing is null.
  Future<Lesson?> findById(LessonId id) async {
    final seen = <LessonId>{};
    var current = id;
    while (seen.add(current)) {
      final stored = await (_db.select(_db.contentLessons)
            ..where((table) => table.id.equals(current)))
          .getSingleOrNull();
      if (stored != null && stored.status == 'retired') {
        final raw = stored.replacedBy;
        final list = raw == null ? const <Object?>[] : jsonDecode(raw) as List;
        if (list.isEmpty) return null;
        current = list.first as String;
        continue;
      }
      if (!await _bodyAvailable(current)) return null;
      final row = await (_db.select(_db.contentLessons)
            ..where((table) => table.id.equals(current)))
          .getSingleOrNull();
      return row == null ? null : _hydrateLesson(row);
    }
    return null;
  }

  Future<bool> _bodyAvailable(LessonId id) async {
    final hook = _fetchHook;
    return hook == null || await hook.ensureLesson(id);
  }

  Lesson _hydrateLesson(ContentLessonRow row) {
    return Lesson(
      id: row.id,
      topicId: row.topicId,
      subtopicId: row.subtopicId,
      title: row.title,
      summary: row.summary,
      bodyJson: (jsonDecode(row.bodyJson) as List).cast<Map<String, dynamic>>(),
      quizSize: row.quizSize,
      status: row.status,
      replacedBy: row.replacedBy == null
          ? null
          : (jsonDecode(row.replacedBy!) as List).cast<String>(),
      part: row.part,
      partCount: row.partCount,
      keyPoints: row.keyPointsJson == null
          ? null
          : (jsonDecode(row.keyPointsJson!) as List).cast<String>(),
      ordering: row.ordering,
      estimatedMinutes: row.estimatedMinutes,
    );
  }
}
