import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/streak_repository.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/home/application/home_today.dart';

import '../../../helpers/in_memory_database.dart';

// P10/U61: Home's day-off line reads the streak against today.
void main() {
  Future<bool> standsOn(DateTime today) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(
            id: const Value(1),
            current: const Value(6),
            longest: const Value(6),
            lastActiveDate: Value(DateTime(2026, 10, 2)),
            freezesRemaining: const Value(1),
          ),
        );
    return streakStandsOn(StreakRepository(db), today, StudyDays.all);
  }

  test('a rest day right after a study day keeps it', () async {
    expect(await standsOn(DateTime(2026, 10, 3)), isTrue);
  });

  test('a streak with three weeks of gap no longer stands', () async {
    expect(await standsOn(DateTime(2026, 10, 23)), isFalse);
  });

  test('no stored streak does not stand', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    expect(
      await streakStandsOn(
        StreakRepository(db),
        DateTime(2026, 10, 3),
        StudyDays.all,
      ),
      isFalse,
    );
  });
}
