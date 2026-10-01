import 'dart:math' as math;

import 'package:pantas/features/metrics/archetypes/archetype.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

class ArchetypeTemplates {
  const ArchetypeTemplates();

  String synthesize(
    ArchetypeResult archetype,
    Map<SignalKey, Object> signals,
  ) {
    final matches = archetypeCatalog.where((a) => a.id == archetype.id);
    if (matches.isEmpty ||
        !signals.keys.toSet().containsAll(matches.first.requiredSignals)) {
      return '';
    }
    switch (archetype.id) {
      case 'game_day_player':
      case 'pressure_tightener':
        final pressure = signals[SignalKey.testModeDelta]! as PressureDelta;
        final points = (pressure.delta * 100).abs().round();
        final direction = pressure.delta < 0 ? 'below' : 'above';
        return 'Your mock accuracy runs $points pts $direction practice.';
      case 'night_owl_sprinter':
      case 'early_bird_marathoner':
        final hours = signals[SignalKey.timeOfDay]! as DayHourHistogram;
        if (hours.buckets.isEmpty) return '';
        final best = [...hours.buckets]
          ..sort((a, b) => b.accuracy.compareTo(a.accuracy));
        final hour = _formatHour(best.first.hour);
        final sessions =
            signals[SignalKey.sessionShape]! as DurationDistribution;
        final minutes = sessions.averageMinutes.round();
        return archetype.id == 'night_owl_sprinter'
            ? 'Your best hour is $hour and your sessions average '
                '$minutes minutes.'
            : 'You work best at $hour and sit for $minutes minutes on average.';
      case 'numbers_person':
      case 'wordsmith':
      case 'generalist':
        final subject =
            signals[SignalKey.subjectAffinity]! as SubjectAccuracySpeed;
        if (subject.subjects.isEmpty) return '';
        final accuracies = subject.subjects.values.map((s) => s.accuracy);
        final high = (accuracies.reduce(math.max) * 100).round();
        if (archetype.id == 'generalist') {
          final low = (accuracies.reduce(math.min) * 100).round();
          return 'Your subject accuracy ranges from $low% to $high%.';
        }
        final kind = archetype.id == 'numbers_person'
            ? 'math or science'
            : 'reading or language';
        return 'Your highest subject accuracy is $high% in $kind.';
      case 'scholar':
        final workflow = signals[SignalKey.readThenQuiz]! as WorkflowRatio;
        final coverage = signals[SignalKey.coverageBreadth]! as CoveragePct;
        final reads = workflow.readThenQuizCount;
        final lessons = reads + workflow.quizFirstCount;
        return 'You read first for $reads of $lessons lessons '
            'and have practiced '
            '${coverage.coveredTopics} of ${coverage.totalTopics} topics.';
      case 'long_memory':
        final memory = signals[SignalKey.retentionShape]! as RetentionCurve;
        final percent = (memory.lapseRate * 100).round();
        return 'You forget on $percent% of your reviews.';
      case 'bookmark_strategist':
        final flags = signals[SignalKey.flagRevisit]! as FlagRevisitRatio;
        return 'You revisit ${flags.revisitedCount} of ${flags.flaggedCount} '
            'questions you flag.';
      case 'time_master':
        final pace = signals[SignalKey.mockPacing]! as PacingProfile;
        return 'You finish mocks with ${pace.averageSpareSeconds.round()} '
            'seconds left on average.';
      case 'closer':
        return 'You score higher in the second half of a mock.';
    }
    return '';
  }
}

String _formatHour(int hour) {
  if (hour == 0) return '12 am';
  if (hour == 12) return '12 pm';
  if (hour < 12) return '$hour am';
  return '${hour - 12} pm';
}
