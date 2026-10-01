import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/metrics/data/user_metrics_archetype_repository.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/providers/current_archetype_provider.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';

void main() {
  for (final removedId in ['weekday_warrior', 'self_aware']) {
    test('cached $removedId falls through to fresh resolve', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.utc(2026, 6, 10);
      await UserMetricsArchetypeRepository(db).upsert(
        UserMetricsArchetypeCacheEntry(
          userId: 'user_1',
          examId: 'exam_cse',
          window: 'prepWindow',
          archetypeId: removedId,
          matchScore: 1,
          synthesizedCopy: 'Old claim',
          computedAt: now,
          validUntil: now.add(const Duration(hours: 24)),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          metricsSignalProvider.overrideWith((ref, request) async {
            if (request.signal != SignalKey.testModeDelta) return null;
            return SignalResult<Object?>(
              window: ResolvedMetricsWindow(
                window: request.window,
                start: DateTime.utc(2026, 5),
                end: now,
                sessionCount: 14,
                minSessionCount: 14,
              ),
              value: const PressureDelta(
                practiceAccuracy: 0.75,
                mockAccuracy: 0.85,
              ),
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      final result = await container.read(
        currentArchetypeProvider(
          CurrentArchetypeRequest(
            userId: 'user_1',
            examId: 'exam_cse',
            window: MetricsWindow.prepWindow,
            now: now,
          ),
        ).future,
      );
      expect(result?.id, 'game_day_player');
      expect(result?.synthesizedCopy, isNot('Old claim'));
      final rows = await db.select(db.userMetricsArchetypesLocal).get();
      expect(rows.any((r) => r.archetypeId == 'game_day_player'), isTrue);
    });
  }

  test('resolves archetype from signal provider and writes cache', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 6, 10);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        metricsSignalProvider.overrideWith((ref, request) async {
          if (request.signal != SignalKey.testModeDelta) return null;
          return SignalResult<Object?>(
            window: ResolvedMetricsWindow(
              window: request.window,
              start: DateTime.utc(2026, 5),
              end: now,
              sessionCount: 14,
              minSessionCount: 14,
            ),
            value: const PressureDelta(
              practiceAccuracy: 0.75,
              mockAccuracy: 0.85,
            ),
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      currentArchetypeProvider(
        CurrentArchetypeRequest(
          userId: 'user_1',
          examId: 'exam_cse',
          window: MetricsWindow.prepWindow,
          now: now,
        ),
      ).future,
    );

    expect(result?.label, 'Game-Day Player');
    expect(
      result?.synthesizedCopy,
      'Your mock accuracy runs 10 pts above practice.',
    );
    expect(await db.select(db.userMetricsArchetypesLocal).get(), hasLength(1));
  });
}
