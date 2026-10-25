import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/metrics/data/user_metrics_archetype_repository.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/providers/current_archetype_provider.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';

void main() {
  test(
      'account transition during initial context read keeps original ownership',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    final authEvents = StreamController<AuthState>();
    addTearDown(authEvents.close);
    authEvents.add(const AuthState.anonymous(uid: 'first'));
    final now = DateTime.utc(2026, 6, 10);
    final scope = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authStateProvider.overrideWith((_) => authEvents.stream),
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
    addTearDown(scope.dispose);
    await scope.read(authStateProvider.future);
    final entered = Completer<void>();
    final release = Completer<void>();
    final held = db.transaction(() async {
      entered.complete();
      await release.future;
    });
    await entered.future;
    final result = scope.read(
      currentArchetypeProvider(
        CurrentArchetypeRequest(
          userId: 'local',
          examId: 'exam_cse',
          window: MetricsWindow.prepWindow,
          now: now,
        ),
      ).future,
    );
    final rejected = expectLater(result, throwsStateError);
    final switched = Completer<void>();
    final subscription = scope.listen(authStateProvider, (_, next) {
      if (next.valueOrNull == const AuthState.anonymous(uid: 'second') &&
          !switched.isCompleted) {
        switched.complete();
      }
    });
    authEvents.add(const AuthState.anonymous(uid: 'second'));
    await switched.future;
    subscription.close();
    release.complete();
    await held;
    await rejected;
    expect(await db.select(db.userMetricsArchetypesLocal).get(), isEmpty);
  });

  for (final change in ['wipe', 'exam', 'account', 'same-account']) {
    test('delayed profile cannot cache or publish after $change', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final entered = Completer<void>();
      final release = Completer<void>();
      final now = DateTime.utc(2026, 6, 10);
      await SyncActiveContextStore(db).clearStable();
      final authEvents = StreamController<AuthState>();
      addTearDown(authEvents.close);
      authEvents.add(const AuthState.anonymous(uid: 'test'));
      final scope = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authStateProvider.overrideWith((_) => authEvents.stream),
          metricsSignalProvider.overrideWith((ref, request) async {
            if (request.signal != SignalKey.testModeDelta) return null;
            entered.complete();
            await release.future;
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
      addTearDown(scope.dispose);
      await scope.read(authStateProvider.future);
      final result = scope.read(
        currentArchetypeProvider(
          CurrentArchetypeRequest(
            userId: 'user_1',
            examId: 'exam_cse',
            window: MetricsWindow.prepWindow,
            now: now,
          ),
        ).future,
      );
      final rejected = expectLater(result, throwsStateError);
      await entered.future;
      if (change == 'wipe') {
        await SyncActiveContextStore(db).clearStable();
      } else if (change == 'exam') {
        await AppPreferencesRepository(db).setSelectedExamId('other');
      } else {
        Future<void> send(AuthState state) async {
          final seen = Completer<void>();
          final subscription = scope.listen(authStateProvider, (_, next) {
            if (next.valueOrNull == state && !seen.isCompleted) seen.complete();
          });
          authEvents.add(state);
          await seen.future;
          subscription.close();
        }

        await send(const AuthState.signedOut());
        await send(
          AuthState.anonymous(uid: change == 'account' ? 'other' : 'test'),
        );
      }
      release.complete();
      await rejected;
      expect(await db.select(db.userMetricsArchetypesLocal).get(), isEmpty);
    });
  }

  for (final removedId in [
    'weekday_warrior',
    'self_aware',
    'pressure_tightener',
  ]) {
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
          authStateProvider.overrideWith(
            (_) => Stream.value(const AuthState.anonymous(uid: 'test')),
          ),
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
      await container.read(authStateProvider.future);
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
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'test')),
        ),
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

    await container.read(authStateProvider.future);
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

    expect(result?.label, 'Levelheaded');
    expect(
      result?.synthesizedCopy,
      "Exam-day pressure doesn't shake you.",
    );
    expect(await db.select(db.userMetricsArchetypesLocal).get(), hasLength(1));
  });
}
