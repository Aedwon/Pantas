import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';

class StreakSnapshot {
  const StreakSnapshot({
    required this.current,
    required this.longest,
    required this.lastActiveDate,
    required this.freezesRemaining,
  });

  final int current;
  final int longest;
  final DateTime? lastActiveDate;
  final int freezesRemaining;
}

class StreakRepository {
  StreakRepository(this._db);

  final AppDatabase _db;

  Future<StreakSnapshot> read() async {
    final row = await (_db.select(_db.streakLocal)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    return StreakSnapshot(
      current: row?.current ?? 0,
      longest: row?.longest ?? 0,
      lastActiveDate: row?.lastActiveDate,
      freezesRemaining: row?.freezesRemaining ?? 0,
    );
  }

  Future<void> writeCurrent({
    required int current,
    required DateTime lastActiveDate,
  }) async {
    final existing = await (_db.select(_db.streakLocal)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    final longest = existing == null
        ? current
        : (current > existing.longest ? current : existing.longest);
    await _db.into(_db.streakLocal).insertOnConflictUpdate(
          StreakLocalCompanion.insert(
            id: const Value(1),
            current: Value(current),
            longest: Value(longest),
            lastActiveDate: Value(lastActiveDate),
            freezesRemaining: Value(existing?.freezesRemaining ?? 0),
          ),
        );
  }

  Future<void> writeSnapshot({
    required int current,
    required int longest,
    required DateTime lastActiveDate,
    required int freezesRemaining,
  }) async {
    await _db.into(_db.streakLocal).insertOnConflictUpdate(
          StreakLocalCompanion.insert(
            id: const Value(1),
            current: Value(current),
            longest: Value(longest),
            lastActiveDate: Value(lastActiveDate),
            freezesRemaining: Value(freezesRemaining),
          ),
        );
  }
}
