import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/metrics/archetypes/archetype.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

void main() {
  const templates = ArchetypeTemplates();
  String line(String id, Map<SignalKey, Object> signals) {
    final label = archetypeCatalog.firstWhere((a) => a.id == id);
    return templates.synthesize(
      ArchetypeResult(
        id: id,
        label: label.label,
        category: label.category,
        matchScore: 0.8,
      ),
      signals,
    );
  }

  for (final (id, signals, expected)
      in <(String, Map<SignalKey, Object>, String)>[
    (
      'game_day_player',
      {
        SignalKey.testModeDelta:
            const PressureDelta(practiceAccuracy: 0.75, mockAccuracy: 0.85),
      },
      'Your mock accuracy runs 10 pts above practice.'
    ),
    (
      'pressure_tightener',
      {
        SignalKey.testModeDelta:
            const PressureDelta(practiceAccuracy: 0.85, mockAccuracy: 0.70),
      },
      'Your mock accuracy runs 15 pts below practice.'
    ),
    (
      'night_owl_sprinter',
      {
        SignalKey.timeOfDay: const DayHourHistogram(
          buckets: [
            DayHourBucket(hour: 9, correct: 1, total: 10),
            DayHourBucket(hour: 21, correct: 9, total: 10),
          ],
        ),
        SignalKey.sessionShape:
            const DurationDistribution(averageMinutes: 8, sessionCount: 20),
        SignalKey.perQuestionSpeed: const LatencyDistribution(
          averageMs: 8000,
          correctAverageMs: 7000,
          incorrectAverageMs: 12000,
          sampleCount: 20,
        ),
      },
      'Your best hour is 9 pm and your sessions average 8 minutes.'
    ),
    (
      'early_bird_marathoner',
      {
        SignalKey.timeOfDay: const DayHourHistogram(
          buckets: [DayHourBucket(hour: 7, correct: 9, total: 10)],
        ),
        SignalKey.sessionShape:
            const DurationDistribution(averageMinutes: 30, sessionCount: 20),
      },
      'You work best at 7 am and sit for 30 minutes on average.'
    ),
    (
      'numbers_person',
      {
        SignalKey.subjectAffinity: const SubjectAccuracySpeed(
          subjects: {
            'Mathematics':
                SubjectAccuracySpeedRow(correct: 9, total: 10, averageMs: 8000),
            'Verbal Ability':
                SubjectAccuracySpeedRow(correct: 1, total: 10, averageMs: 8000),
          },
        ),
      },
      'Your highest subject accuracy is 90% in math or science.'
    ),
    (
      'wordsmith',
      {
        SignalKey.subjectAffinity: const SubjectAccuracySpeed(
          subjects: {
            'Mathematics':
                SubjectAccuracySpeedRow(correct: 1, total: 10, averageMs: 8000),
            'Verbal Ability':
                SubjectAccuracySpeedRow(correct: 8, total: 10, averageMs: 8000),
          },
        ),
      },
      'Your highest subject accuracy is 80% in reading or language.'
    ),
    (
      'generalist',
      {
        SignalKey.subjectAffinity: const SubjectAccuracySpeed(
          subjects: {
            'Mathematics':
                SubjectAccuracySpeedRow(correct: 8, total: 10, averageMs: 8000),
            'Verbal Ability':
                SubjectAccuracySpeedRow(correct: 7, total: 10, averageMs: 8000),
          },
        ),
      },
      'Your subject accuracy ranges from 70% to 80%.'
    ),
    (
      'scholar',
      {
        SignalKey.readThenQuiz:
            const WorkflowRatio(readThenQuizCount: 12, quizFirstCount: 4),
        SignalKey.coverageBreadth:
            const CoveragePct(coveredTopics: 8, totalTopics: 10),
      },
      'You read first for 12 of 16 lessons and have practiced 8 of 10 topics.'
    ),
    (
      'long_memory',
      {
        SignalKey.retentionShape:
            const RetentionCurve(averageStability: 9, lapseRate: 0.05),
      },
      'You forget on 5% of your reviews.'
    ),
    (
      'bookmark_strategist',
      {
        SignalKey.flagRevisit:
            const FlagRevisitRatio(flaggedCount: 10, revisitedCount: 8),
        SignalKey.mockPacing: const PacingProfile(
          averageSpareSeconds: 20,
          sectionTimeSeconds: {},
        ),
      },
      'You revisit 8 of 10 questions you flag.'
    ),
    (
      'time_master',
      {
        SignalKey.mockPacing: const PacingProfile(
          averageSpareSeconds: 90,
          sectionTimeSeconds: {},
        ),
      },
      'You finish mocks with 90 seconds left on average.'
    ),
    (
      'closer',
      {
        SignalKey.mockStamina:
            const StaminaDelta(firstHalfAccuracy: 0.7, secondHalfAccuracy: 0.8),
      },
      'You score higher in the second half of a mock.'
    ),
  ]) {
    test('$id line states its measured inputs', () {
      expect(line(id, signals), expected);
      for (final key
          in archetypeCatalog.firstWhere((a) => a.id == id).requiredSignals) {
        expect(
          line(id, {...signals}..remove(key)),
          isEmpty,
          reason: 'Do not claim a pattern without $key',
        );
      }
      for (final banned in [
        '—',
        'FSRS',
        'stability',
        'retention',
        'retrievability',
        'algorithm',
      ]) {
        expect(line(id, signals), isNot(contains(banned)));
      }
    });
  }

  test('pressure lines follow a changed measured gap', () {
    expect(
      line('game_day_player', {
        SignalKey.testModeDelta:
            const PressureDelta(practiceAccuracy: 0.6, mockAccuracy: 0.85),
      }),
      'Your mock accuracy runs 25 pts above practice.',
    );
    expect(
      line('pressure_tightener', {
        SignalKey.testModeDelta:
            const PressureDelta(practiceAccuracy: 0.9, mockAccuracy: 0.7),
      }),
      'Your mock accuracy runs 20 pts below practice.',
    );
  });
}
