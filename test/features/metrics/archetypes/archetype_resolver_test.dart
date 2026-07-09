import 'package:cse_cet_reviewer/features/metrics/archetypes/archetype_catalog.dart';
import 'package:cse_cet_reviewer/features/metrics/archetypes/archetype_resolver.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_key.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog contains the 14 starter archetypes from the spec', () {
    expect(archetypeCatalog, hasLength(14));
    expect(
      archetypeCatalog.map((a) => a.label),
      containsAll([
        'Night-Owl Sprinter',
        'Early Bird Marathoner',
        'Weekday Warrior',
        'Game-Day Player',
        'Pressure Tightener',
        'Bookmark Strategist',
        'Time Master',
        'Closer',
        'Wordsmith',
        'Numbers Person',
        'Generalist',
        'Scholar',
        'Long Memory',
        'Self-Aware',
      ]),
    );
  });

  test('resolver applies category priority before raw match score', () {
    final resolved = const ArchetypeResolver().resolve(
      archetypeCatalog,
      {
        SignalKey.testModeDelta: const PressureDelta(
          practiceAccuracy: 0.8,
          mockAccuracy: 0.9,
        ),
        SignalKey.timeOfDay: const DayHourHistogram(
          buckets: [DayHourBucket(hour: 21, correct: 10, total: 10)],
        ),
        SignalKey.sessionShape: const DurationDistribution(
          averageMinutes: 8,
          sessionCount: 20,
        ),
        SignalKey.perQuestionSpeed: const LatencyDistribution(
          averageMs: 8000,
          correctAverageMs: 7000,
          incorrectAverageMs: 12000,
          sampleCount: 20,
        ),
      },
    );

    expect(resolved?.label, 'Game-Day Player');
  });

  test('resolver skips archetypes with missing required signals', () {
    final resolved = const ArchetypeResolver().resolve(
      archetypeCatalog,
      {
        SignalKey.timeOfDay: const DayHourHistogram(
          buckets: [DayHourBucket(hour: 21, correct: 10, total: 10)],
        ),
      },
    );

    expect(resolved, isNull);
  });

  test('resolver uses alphabetical tie-break inside the same category', () {
    final resolved = const ArchetypeResolver().resolve(
      archetypeCatalog,
      {
        SignalKey.subjectAffinity: const SubjectAccuracySpeed(
          subjects: {
            'Math': SubjectAccuracySpeedRow(
              correct: 8,
              total: 10,
              averageMs: 8000,
            ),
            'Reading': SubjectAccuracySpeedRow(
              correct: 8,
              total: 10,
              averageMs: 8000,
            ),
          },
        ),
      },
    );

    expect(resolved?.label, 'Generalist');
  });
}
