import 'package:cse_cet_reviewer/features/metrics/domain/signal_key.dart';

enum ArchetypeCategory {
  pressureMode,
  pace,
  subject,
  studyHabit,
  strategy,
}

class ArchetypeResult {
  const ArchetypeResult({
    required this.id,
    required this.label,
    required this.category,
    required this.matchScore,
  });

  final String id;
  final String label;
  final ArchetypeCategory category;
  final double matchScore;
}

class Archetype {
  const Archetype({
    required this.id,
    required this.label,
    required this.category,
    required this.requiredSignals,
    required this.match,
  });

  final String id;
  final String label;
  final ArchetypeCategory category;
  final Set<SignalKey> requiredSignals;
  final double Function(Map<SignalKey, Object> signals) match;
}
