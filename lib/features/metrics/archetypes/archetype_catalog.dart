import 'dart:math' as math;

import 'package:pantas/features/metrics/archetypes/archetype.dart';
import 'package:pantas/features/metrics/archetypes/subject_kinds.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

final archetypeCatalog = <Archetype>[
  Archetype(
    id: 'night_owl_sprinter',
    label: 'Night Owl',
    category: ArchetypeCategory.pace,
    requiredSignals: const {
      SignalKey.timeOfDay,
      SignalKey.sessionShape,
      SignalKey.perQuestionSpeed,
    },
    match: (s) {
      final t1 = s[SignalKey.timeOfDay]! as DayHourHistogram;
      final t2 = s[SignalKey.sessionShape]! as DurationDistribution;
      final p1 = s[SignalKey.perQuestionSpeed]! as LatencyDistribution;
      final late = _bestHour(t1) >= 18 ? 0.4 : 0.0;
      final short = t2.averageMinutes <= 12 ? 0.3 : 0.0;
      final fast = p1.averageMs <= 12000 ? 0.3 : 0.0;
      return late + short + fast;
    },
  ),
  Archetype(
    id: 'early_bird_marathoner',
    label: 'Early Bird',
    category: ArchetypeCategory.pace,
    requiredSignals: const {SignalKey.timeOfDay, SignalKey.sessionShape},
    match: (s) {
      final hour = _bestHour(s[SignalKey.timeOfDay]! as DayHourHistogram);
      final sessions = s[SignalKey.sessionShape]! as DurationDistribution;
      return (hour < 12 ? 0.5 : 0) + (sessions.averageMinutes >= 25 ? 0.5 : 0);
    },
  ),
  Archetype(
    id: 'game_day_player',
    label: 'Levelheaded',
    category: ArchetypeCategory.pressureMode,
    requiredSignals: const {SignalKey.testModeDelta},
    match: (s) {
      final x1 = s[SignalKey.testModeDelta]! as PressureDelta;
      return x1.delta > 0 ? math.min(1, 0.7 + x1.delta).toDouble() : 0.0;
    },
  ),
  Archetype(
    id: 'deep_thinker',
    label: 'Deep Thinker',
    category: ArchetypeCategory.pace,
    requiredSignals: const {SignalKey.perQuestionSpeed},
    match: (s) {
      final speed = s[SignalKey.perQuestionSpeed]! as LatencyDistribution;
      // Slow is the complement of Night Owl's <= 12000 ms fast rule.
      // Accuracy uses the existing measured correct/incorrect split: more
      // correct answers than incorrect answers, with no inferred evidence.
      if (speed.averageMs <= 12000 ||
          speed.correctCount <= speed.incorrectCount) return 0;
      return speed.correctCount / (speed.correctCount + speed.incorrectCount);
    },
  ),
  Archetype(
    id: 'bookmark_strategist',
    label: 'Thorough Reviewer',
    category: ArchetypeCategory.strategy,
    requiredSignals: const {SignalKey.flagRevisit, SignalKey.mockPacing},
    match: (s) => (s[SignalKey.flagRevisit]! as FlagRevisitRatio).ratio,
  ),
  Archetype(
    id: 'time_master',
    label: 'Time Master',
    category: ArchetypeCategory.strategy,
    requiredSignals: const {SignalKey.mockPacing},
    match: (s) =>
        (s[SignalKey.mockPacing]! as PacingProfile).averageSpareSeconds > 0
            ? 0.8
            : 0.0,
  ),
  Archetype(
    id: 'closer',
    label: 'Closer',
    category: ArchetypeCategory.strategy,
    requiredSignals: const {SignalKey.mockStamina},
    match: (s) =>
        (s[SignalKey.mockStamina]! as StaminaDelta).delta > 0 ? 0.8 : 0.0,
  ),
  Archetype(
    id: 'wordsmith',
    label: 'Wordsmith',
    category: ArchetypeCategory.subject,
    requiredSignals: const {SignalKey.subjectAffinity},
    match: (s) {
      final subject = s[SignalKey.subjectAffinity]! as SubjectAccuracySpeed;
      return strongestSubjectKind(subject) == SubjectKind.words
          ? _subjectSpread(subject)
          : 0.0;
    },
  ),
  Archetype(
    id: 'numbers_person',
    label: 'Math Wizard',
    category: ArchetypeCategory.subject,
    requiredSignals: const {SignalKey.subjectAffinity},
    match: (s) {
      final subject = s[SignalKey.subjectAffinity]! as SubjectAccuracySpeed;
      return strongestSubjectKind(subject) == SubjectKind.numbers
          ? _subjectSpread(subject)
          : 0.0;
    },
  ),
  Archetype(
    id: 'generalist',
    label: 'All-Rounder',
    category: ArchetypeCategory.subject,
    requiredSignals: const {SignalKey.subjectAffinity},
    match: (s) {
      final spread =
          _subjectSpread(s[SignalKey.subjectAffinity]! as SubjectAccuracySpeed);
      return 1 - spread;
    },
  ),
  Archetype(
    id: 'scholar',
    label: 'Scholar',
    category: ArchetypeCategory.studyHabit,
    requiredSignals: const {SignalKey.readThenQuiz, SignalKey.coverageBreadth},
    match: (s) {
      final d1 = s[SignalKey.readThenQuiz]! as WorkflowRatio;
      final d3 = s[SignalKey.coverageBreadth]! as CoveragePct;
      return (d1.ratio + d3.percent) / 2;
    },
  ),
  Archetype(
    id: 'long_memory',
    label: 'Strong Recall',
    category: ArchetypeCategory.studyHabit,
    requiredSignals: const {SignalKey.retentionShape},
    match: (s) =>
        1 - (s[SignalKey.retentionShape]! as RetentionCurve).lapseRate,
  ),
];

int _bestHour(DayHourHistogram histogram) {
  final buckets = [...histogram.buckets]
    ..sort((a, b) => b.accuracy.compareTo(a.accuracy));
  return buckets.first.hour;
}

double _subjectSpread(SubjectAccuracySpeed signal) {
  if (signal.subjects.length < 2) return 0;
  final accuracies = signal.subjects.values.map((row) => row.accuracy).toList();
  return accuracies.reduce(math.max) - accuracies.reduce(math.min);
}
