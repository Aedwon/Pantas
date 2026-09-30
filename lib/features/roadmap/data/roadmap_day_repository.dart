import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';

/// One stored plan per exam and local day. Device-local: the plan is derived
/// from synced facts and rebuilt whenever it is missing.
class RoadmapDayRepository {
  RoadmapDayRepository(this._db);

  final AppDatabase _db;

  /// Days kept per exam. Enough to compare against yesterday after a gap.
  static const keptDays = 14;

  Future<DaySnapshot?> read(ExamId examId, DateTime day) async {
    final row = await (_db.select(_db.roadmapDayLocal)
          ..where((r) => r.examId.equals(examId) & r.day.equals(dayKey(day))))
        .getSingleOrNull();
    return row == null ? null : _decode(row);
  }

  /// The most recent stored day strictly before [day].
  Future<DaySnapshot?> latestBefore(ExamId examId, DateTime day) async {
    final row = await (_db.select(_db.roadmapDayLocal)
          ..where(
            (r) =>
                r.examId.equals(examId) & r.day.isSmallerThanValue(dayKey(day)),
          )
          ..orderBy([(r) => OrderingTerm.desc(r.day)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _decode(row);
  }

  Future<void> write(ExamId examId, DaySnapshot snapshot, DateTime now) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.roadmapDayLocal)
            ..where(
              (r) =>
                  r.examId.equals(examId) & r.day.equals(dayKey(snapshot.day)),
            ))
          .getSingleOrNull();
      await _db.into(_db.roadmapDayLocal).insertOnConflictUpdate(
            RoadmapDayLocalCompanion.insert(
              examId: examId,
              day: dayKey(snapshot.day),
              planJson: jsonEncode(snapshot.toJson()),
              inputsDigest: snapshot.digest.encode(),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
      final days = await (_db.selectOnly(_db.roadmapDayLocal)
            ..addColumns([_db.roadmapDayLocal.day])
            ..where(_db.roadmapDayLocal.examId.equals(examId))
            ..orderBy([OrderingTerm.desc(_db.roadmapDayLocal.day)]))
          .map((r) => r.read(_db.roadmapDayLocal.day)!)
          .get();
      if (days.length > keptDays) {
        final oldestKept = days[keptDays - 1];
        await (_db.delete(_db.roadmapDayLocal)
              ..where(
                (r) =>
                    r.examId.equals(examId) &
                    r.day.isSmallerThanValue(oldestKept),
              ))
            .go();
      }
    });
  }

  DaySnapshot _decode(RoadmapDayLocalRow row) => DaySnapshot.fromJson(
        jsonDecode(row.planJson) as Map<String, Object?>,
      );
}
