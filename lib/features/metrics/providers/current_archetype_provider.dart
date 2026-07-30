import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_resolver.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/data/user_metrics_archetype_repository.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

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
  final repo = UserMetricsArchetypeRepository(db);
  final windowName = request.window.name;
  final cached = await repo.bestValid(
    userId: request.userId,
    examId: request.examId,
    window: windowName,
    now: request.now,
  );
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
        synthesizedCopy: cached.synthesizedCopy,
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
    final value = result?.value;
    if (value != null) signals[key] = value;
  }
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
  );
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
