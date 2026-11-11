import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_resolver.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/data/user_metrics_archetype_repository.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

@immutable
class CurrentArchetypeRequest {
  const CurrentArchetypeRequest({
    required this.userId,
    required this.examId,
    required this.window,
    required this.now,
    this.prepStartedAt,
  });

  final String userId;
  final String examId;
  final MetricsWindow window;
  final DateTime now;
  final DateTime? prepStartedAt;

  @override
  bool operator ==(Object other) {
    return other is CurrentArchetypeRequest &&
        other.userId == userId &&
        other.examId == examId &&
        other.window == window &&
        other.now == now &&
        other.prepStartedAt == prepStartedAt;
  }

  @override
  int get hashCode => Object.hash(userId, examId, window, now, prepStartedAt);
}

@immutable
class CurrentArchetype {
  const CurrentArchetype({
    required this.id,
    required this.label,
    required this.matchScore,
    required this.synthesizedCopy,
  });

  final String id;
  final String label;
  final double matchScore;
  final String synthesizedCopy;
}

final currentArchetypeProvider = FutureProvider.family
    .autoDispose<CurrentArchetype?, CurrentArchetypeRequest>(
        (ref, request) async {
  final db = ref.watch(appDatabaseProvider);
  var alive = true;
  ref.onDispose(() => alive = false);
  final contexts = SyncActiveContextStore(db);
  final auth = ref.watch(authStateProvider).unwrapPrevious().asData?.value;
  final preparer = ref.read(todayQuizPreparerProvider);
  final lifetime = preparer.accountLifetimeToken;
  if (auth == null || lifetime == null) {
    throw StateError('Profile owner unavailable');
  }
  final original = await contexts.readSnapshot();
  final prefs = ref.read(appPreferencesRepositoryProvider);
  final selected = await prefs.selectedExamId();
  Future<bool> current() async {
    if (!alive ||
        !identical(ref.read(appDatabaseProvider), db) ||
        preparer.accountLifetimeToken != lifetime ||
        ref.read(authStateProvider).unwrapPrevious().asData?.value != auth) {
      return false;
    }
    final snapshot = await contexts.readSnapshot();
    final exam = await prefs.selectedExamId();
    return alive &&
        snapshot?.token == original?.token &&
        exam == selected &&
        (exam == null || exam == request.examId) &&
        preparer.accountLifetimeToken == lifetime &&
        ref.read(authStateProvider).unwrapPrevious().asData?.value == auth;
  }

  Future<void> requireCurrent() async {
    if (!await current()) throw StateError('Profile owner changed');
  }

  await requireCurrent();
  final repo = UserMetricsArchetypeRepository(db);
  final windowName = request.window.name;
  final cached = await repo.bestValid(
    userId: request.userId,
    examId: request.examId,
    window: windowName,
    now: request.now,
  );
  await requireCurrent();
  if (cached != null) {
    final label = archetypeCatalog
        .where((archetype) => archetype.id == cached.archetypeId)
        .firstOrNull
        ?.label;
    if (label != null) {
      return CurrentArchetype(
        id: cached.archetypeId,
        label: label,
        matchScore: cached.matchScore,
        synthesizedCopy: archetypeIdentityLine(cached.archetypeId),
      );
    }
  }

  final signals = <SignalKey, Object>{};
  for (final key in SignalKey.values) {
    final result = await ref.read(
      metricsSignalProvider(
        MetricsSignalRequest(
          signal: key,
          window: request.window,
          examId: request.examId,
          now: request.now,
          prepStartedAt: request.prepStartedAt,
        ),
      ).future,
    );
    await requireCurrent();
    final value = result?.value;
    if (value != null) signals[key] = value;
  }
  await requireCurrent();
  final resolved = const ArchetypeResolver().resolve(archetypeCatalog, signals);
  if (resolved == null) return null;
  final copy = const ArchetypeTemplates().synthesize(resolved, signals);
  await repo.upsert(
    UserMetricsArchetypeCacheEntry(
      userId: request.userId,
      examId: request.examId,
      window: windowName,
      archetypeId: resolved.id,
      matchScore: resolved.matchScore,
      synthesizedCopy: copy,
      computedAt: request.now,
      validUntil: request.now.add(const Duration(hours: 24)),
    ),
    canPersist: current,
  );
  await requireCurrent();
  return CurrentArchetype(
    id: resolved.id,
    label: resolved.label,
    matchScore: resolved.matchScore,
    synthesizedCopy: copy,
  );
});

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
