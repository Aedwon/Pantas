import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_resolver.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

void main() {
  test('calibration alone does not assign a profile', () {
    expect(
      const ArchetypeResolver().resolve(archetypeCatalog, {
        SignalKey.difficultyCalibration: const CalibrationCurve(
          points: [
            CalibrationPoint(difficulty: 3, averageMs: 10000, accuracy: 0.8),
          ],
        ),
      }),
      isNull,
    );
  });

  for (final (subject, expectedLabel) in [
    ('subj_upcat_mathematics', 'Numbers Person'),
    ('Mathematics', 'Numbers Person'),
    ('subj_upcat_science', 'Numbers Person'),
    ('Science', 'Numbers Person'),
    ('subj_upcat_language_proficiency', 'Wordsmith'),
    ('Language Proficiency (English & Filipino)', 'Wordsmith'),
    ('subj_upcat_reading_comprehension', 'Wordsmith'),
    ('Reading Comprehension (English & Filipino)', 'Wordsmith'),
    ('subj_cse_verbal', 'Wordsmith'),
    ('Verbal Ability', 'Wordsmith'),
    ('subj_upcat_reasoning', null),
    ('General Information', null),
    ('new_subject', null),
  ]) {
    test('strongest subject $subject gives $expectedLabel', () {
      final weaker =
          expectedLabel == 'Numbers Person' ? 'Verbal Ability' : 'Mathematics';
      final signal = SubjectAccuracySpeed(
        subjects: {
          subject: const SubjectAccuracySpeedRow(
            correct: 9,
            total: 10,
            averageMs: 8000,
          ),
          weaker: const SubjectAccuracySpeedRow(
            correct: 1,
            total: 10,
            averageMs: 8000,
          ),
        },
      );
      final labels = archetypeCatalog
          .where((a) => a.id == 'numbers_person' || a.id == 'wordsmith')
          .toList();
      final result = const ArchetypeResolver()
          .resolve(labels, {SignalKey.subjectAffinity: signal});
      expect(result?.label, expectedLabel);
      if (expectedLabel != null) {
        expect(result?.matchScore, closeTo(0.8, 0.0001));
      }
    });
  }

  test('catalog contains the 12 supported archetypes', () {
    expect(archetypeCatalog, hasLength(12));
    expect(
      archetypeCatalog.map((a) => a.label),
      containsAll([
        'Night-Owl Sprinter',
        'Early Bird Marathoner',
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
