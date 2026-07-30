import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/providers/current_archetype_provider.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';

void main() {
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
    expect(result?.synthesizedCopy, contains('mock mode'));
    expect(await db.select(db.userMetricsArchetypesLocal).get(), hasLength(1));
  });
}
