import 'package:pantas/features/metrics/archetypes/archetype.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';

class ArchetypeResolver {
  const ArchetypeResolver();

  ArchetypeResult? resolve(
    List<Archetype> catalog,
    Map<SignalKey, Object> signals,
  ) {
    final candidates = <ArchetypeResult>[];
    for (final archetype in catalog) {
      if (!signals.keys.toSet().containsAll(archetype.requiredSignals)) {
        continue;
      }
      final score = archetype.match(signals);
      if (score <= 0) continue;
      candidates.add(
        ArchetypeResult(
          id: archetype.id,
          label: archetype.label,
          category: archetype.category,
          matchScore: score.clamp(0, 1),
        ),
      );
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final category = _priority(a.category).compareTo(_priority(b.category));
      if (category != 0) return category;
      final score = b.matchScore.compareTo(a.matchScore);
      if (score != 0) return score;
      return a.id.compareTo(b.id);
    });
    return candidates.first;
  }

  int _priority(ArchetypeCategory category) {
    return switch (category) {
      ArchetypeCategory.pressureMode => 0,
      ArchetypeCategory.pace => 1,
      ArchetypeCategory.subject => 2,
      ArchetypeCategory.studyHabit => 3,
      ArchetypeCategory.strategy => 4,
    };
  }
}
