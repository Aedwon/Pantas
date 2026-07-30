import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:drift/drift.dart';

class NewCardIntroRepository {
  NewCardIntroRepository(this._db);

  final AppDatabase _db;

  Future<int> countForDay({
    required String userId,
    required ExamId examId,
    required DateTime day,
  }) async {
    final row = await (_db.select(_db.dailyNewCardIntro)
          ..where((table) => table.userId.equals(userId))
          ..where((table) => table.examId.equals(examId))
          ..where((table) => table.day.equals(_localMidnight(day))))
        .getSingleOrNull();
    return row?.newCardsIntroduced ?? 0;
  }

  Future<void> incrementForDay({
    required String userId,
    required ExamId examId,
    required DateTime day,
    int by = 1,
  }) async {
    if (by <= 0) return;
    final bucket = _localMidnight(day);
    await _db.transaction(() async {
      final existing = await (_db.select(_db.dailyNewCardIntro)
            ..where((table) => table.userId.equals(userId))
            ..where((table) => table.examId.equals(examId))
            ..where((table) => table.day.equals(bucket)))
          .getSingleOrNull();
      if (existing == null) {
        await _db.into(_db.dailyNewCardIntro).insert(
              DailyNewCardIntroCompanion.insert(
                userId: userId,
                examId: examId,
                day: bucket,
                newCardsIntroduced: Value(by),
              ),
            );
        return;
      }
      await (_db.update(_db.dailyNewCardIntro)
            ..where((table) => table.userId.equals(userId))
            ..where((table) => table.examId.equals(examId))
            ..where((table) => table.day.equals(bucket)))
          .write(
        DailyNewCardIntroCompanion(
          newCardsIntroduced: Value(existing.newCardsIntroduced + by),
        ),
      );
    });
  }

  DateTime _localMidnight(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
