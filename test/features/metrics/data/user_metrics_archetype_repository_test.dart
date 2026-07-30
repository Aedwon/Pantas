import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/data/user_metrics_archetype_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns cached archetype only before validUntil', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserMetricsArchetypeRepository(db);
    final computedAt = DateTime.utc(2026, 6, 10);

    await repo.upsert(
      UserMetricsArchetypeCacheEntry(
        userId: 'user_1',
        examId: 'exam_cse',
        window: 'prepWindow',
        archetypeId: 'game_day_player',
        matchScore: 0.8,
        synthesizedCopy: 'You lift in mock mode.',
        computedAt: computedAt,
        validUntil: computedAt.add(const Duration(hours: 24)),
      ),
    );

    expect(
      (await repo.bestValid(
        userId: 'user_1',
        examId: 'exam_cse',
        window: 'prepWindow',
        now: computedAt.add(const Duration(hours: 23)),
      ))
          ?.archetypeId,
      'game_day_player',
    );
    expect(
      await repo.bestValid(
        userId: 'user_1',
        examId: 'exam_cse',
        window: 'prepWindow',
        now: computedAt.add(const Duration(hours: 25)),
      ),
      isNull,
    );
  });
}
