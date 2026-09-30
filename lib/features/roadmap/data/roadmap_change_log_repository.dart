import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:uuid/uuid.dart';

/// Why the plan changed, kept on this device. Append-only.
///
/// Not recorded for cloud sync in this build: the sync engine accepts only
/// registered collections, and the change log's collection was deferred on
/// 1 October 2026. Enabling it later needs a backfill of existing rows.
class RoadmapChangeLogRepository {
  RoadmapChangeLogRepository(this._db, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Future<void> append(ExamId examId, List<RoadmapChange> changes) async {
    if (changes.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(_db.roadmapChangeLogLocal, [
        for (final change in changes)
          RoadmapChangeLogLocalCompanion.insert(
            id: _uuid.v4(),
            examId: examId,
            occurredAt: change.occurredAt,
            cause: change.cause.name,
            beforeJson: Value(
              jsonEncode({
                ...?change.before?.toJson(),
                'topics': change.firstTopicsBefore,
              }),
            ),
            afterJson: Value(
              jsonEncode({
                ...?change.after?.toJson(),
                'topics': change.firstTopicsAfter,
                if (change.advancedCompleted != null)
                  'advancedCompleted': change.advancedCompleted,
              }),
            ),
          ),
      ]);
    });
  }

  /// Newest first.
  Future<List<RoadmapChange>> recent(ExamId examId, {int limit = 100}) async {
    final rows = await (_db.select(_db.roadmapChangeLogLocal)
          ..where((r) => r.examId.equals(examId))
          ..orderBy([(r) => OrderingTerm.desc(r.occurredAt)])
          ..limit(limit))
        .get();
    return [for (final row in rows) _decode(row)];
  }

  RoadmapChange _decode(RoadmapChangeLogLocalRow row) {
    final before = row.beforeJson == null
        ? const <String, Object?>{}
        : jsonDecode(row.beforeJson!) as Map<String, Object?>;
    final after = row.afterJson == null
        ? const <String, Object?>{}
        : jsonDecode(row.afterJson!) as Map<String, Object?>;
    RoadmapDayCounts? counts(Map<String, Object?> json) =>
        json.containsKey('lessons') ? RoadmapDayCounts.fromJson(json) : null;
    return RoadmapChange(
      cause: RoadmapChangeCause.values.byName(row.cause),
      occurredAt: row.occurredAt,
      before: counts(before),
      after: counts(after),
      firstTopicsBefore:
          ((before['topics'] as List?) ?? const []).cast<String>(),
      firstTopicsAfter: ((after['topics'] as List?) ?? const []).cast<String>(),
      advancedCompleted: after['advancedCompleted'] as int?,
    );
  }
}
