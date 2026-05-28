import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';

class UserMetricsArchetypeCacheEntry {
  const UserMetricsArchetypeCacheEntry({
    required this.userId,
    required this.examId,
    required this.window,
    required this.archetypeId,
    required this.matchScore,
    required this.synthesizedCopy,
    required this.computedAt,
    required this.validUntil,
  });

  final String userId;
  final String examId;
  final String window;
  final String archetypeId;
  final double matchScore;
  final String synthesizedCopy;
  final DateTime computedAt;
  final DateTime validUntil;
}

class UserMetricsArchetypeRepository {
  const UserMetricsArchetypeRepository(this._db);

  final AppDatabase _db;

  Future<void> upsert(UserMetricsArchetypeCacheEntry entry) {
    return _db.into(_db.userMetricsArchetypesLocal).insertOnConflictUpdate(
          UserMetricsArchetypesLocalCompanion.insert(
            userId: entry.userId,
            examId: entry.examId,
            window: entry.window,
            archetypeId: entry.archetypeId,
            matchScore: entry.matchScore,
            synthesizedCopy: entry.synthesizedCopy,
            computedAt: entry.computedAt,
            validUntil: entry.validUntil,
          ),
        );
  }

  Future<UserMetricsArchetypeCacheEntry?> bestValid({
    required String userId,
    required String examId,
    required String window,
    required DateTime now,
  }) async {
    final row = await (_db.select(_db.userMetricsArchetypesLocal)
          ..where(
            (table) =>
                table.userId.equals(userId) &
                table.examId.equals(examId) &
                table.window.equals(window) &
                table.validUntil.isBiggerThanValue(now),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.matchScore)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return UserMetricsArchetypeCacheEntry(
      userId: row.userId,
      examId: row.examId,
      window: row.window,
      archetypeId: row.archetypeId,
      matchScore: row.matchScore,
      synthesizedCopy: row.synthesizedCopy,
      computedAt: row.computedAt,
      validUntil: row.validUntil,
    );
  }
}
