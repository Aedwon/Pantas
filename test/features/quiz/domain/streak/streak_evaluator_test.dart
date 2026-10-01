import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/streak_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  for (final scenario in [
    (
      name: 'Friday to Saturday credits rest-day work',
      last: 2,
      today: 3,
      current: 6,
      freezeUsed: false,
      freezes: 1,
    ),
    (
      name: 'Friday to Monday preserves the freeze',
      last: 2,
      today: 5,
      current: 6,
      freezeUsed: false,
      freezes: 1
    ),
    (
      name: 'Friday to Tuesday uses one freeze',
      last: 2,
      today: 6,
      current: 6,
      freezeUsed: true,
      freezes: 0
    ),
    (
      name: 'Saturday work credits and Monday continues',
      last: 3,
      today: 5,
      current: 6,
      freezeUsed: false,
      freezes: 1
    ),
    (
      name: 'two missed study days reset',
      last: 2,
      today: 7,
      current: 1,
      freezeUsed: false,
      freezes: 1
    ),
  ]) {
    test(scenario.name, () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await db.into(db.accountPrefs).insert(
            AccountPrefsCompanion.insert(
              key: 'settings.study_days',
              value: '1,2,3,4,5',
            ),
          );
      await db.into(db.streakLocal).insert(
            StreakLocalCompanion.insert(
              current: const Value(5),
              longest: const Value(7),
              lastActiveDate: Value(DateTime(2026, 10, scenario.last)),
              freezesRemaining: const Value(1),
            ),
          );
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final result = await container.read(streakEvaluatorProvider).evaluate(
            origin: SessionOrigin.todayTopic,
            completedAt: DateTime(2026, 10, scenario.today, 9),
          );
      final snapshot = await StreakRepository(db).read();
      expect(result.credited, isTrue);
      expect(result.current, scenario.current);
      expect(result.freezeUsed, scenario.freezeUsed);
      expect(snapshot.freezesRemaining, scenario.freezes);
      expect(snapshot.lastActiveDate, DateTime(2026, 10, scenario.today));
    });
  }

  test('today topic completion awards streak once per local day', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = StreakRepository(db);
    final evaluator = StreakEvaluator(repo);

    final first = await evaluator.evaluate(
      origin: SessionOrigin.todayTopic,
      completedAt: DateTime(2026, 5, 18, 9),
    );
    final second = await evaluator.evaluate(
      origin: SessionOrigin.todayTopic,
      completedAt: DateTime(2026, 5, 18, 22),
    );

    expect(first.credited, isTrue);
    expect(second.credited, isFalse);
    expect((await repo.read()).current, 1);
  });

  test('today interleaved completion awards streak', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = StreakRepository(db);

    final result = await StreakEvaluator(repo).evaluate(
      origin: SessionOrigin.todayInterleaved,
      completedAt: DateTime(2026, 5, 18, 9),
    );

    expect(result.credited, isTrue);
    expect((await repo.read()).current, 1);
  });

  test('drill retake and inline completions do not award streak', () async {
    for (final origin in [
      SessionOrigin.drill,
      SessionOrigin.retake,
      SessionOrigin.inline,
    ]) {
      final db = inMemoryDatabase();
      try {
        final repo = StreakRepository(db);

        final result = await StreakEvaluator(repo).evaluate(
          origin: origin,
          completedAt: DateTime(2026, 5, 18, 9),
        );

        expect(result.credited, isFalse);
        expect((await repo.read()).current, 0);
      } finally {
        await db.close();
      }
    }
  });

  test('consecutive local days increment the streak', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = StreakRepository(db);
    await repo.writeCurrent(
      current: 3,
      lastActiveDate: DateTime(2026, 5, 17),
    );

    final result = await StreakEvaluator(repo).evaluate(
      origin: SessionOrigin.todayTopic,
      completedAt: DateTime(2026, 5, 18, 9),
    );

    expect(result.credited, isTrue);
    expect(result.current, 4);
    expect((await repo.read()).longest, 4);
  });

  test('missed day consumes an available freeze before resetting', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = StreakRepository(db);
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(
            current: const Value(5),
            longest: const Value(7),
            lastActiveDate: Value(DateTime(2026, 5, 16)),
            freezesRemaining: const Value(1),
          ),
        );

    final result = await StreakEvaluator(repo).evaluate(
      origin: SessionOrigin.todayTopic,
      completedAt: DateTime(2026, 5, 18, 9),
    );

    final snapshot = await repo.read();
    expect(result.freezeUsed, isTrue);
    expect(result.current, 6);
    expect(snapshot.current, 6);
    expect(snapshot.freezesRemaining, 0);
  });
}
