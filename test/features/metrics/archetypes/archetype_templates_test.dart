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
      "Exam-day pressure doesn't shake you."
    ),
    (
      'deep_thinker',
      {
        SignalKey.perQuestionSpeed: const LatencyDistribution(
          averageMs: 20000,
          correctAverageMs: 19000,
          incorrectAverageMs: 21000,
          sampleCount: 10,
          correctCount: 8,
          incorrectCount: 2,
        ),
      },
      'You take your sweet time, and it shows.'
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
      'Late nights are when you shine.'
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
      'Mornings fire you up and get you going.'
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
      'Numbers bend to your will.'
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
      'Words just make sense to you.'
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
      "Give you any subject and you'll handle it."
    ),
    (
      'scholar',
      {
        SignalKey.readThenQuiz:
            const WorkflowRatio(readThenQuizCount: 12, quizFirstCount: 4),
        SignalKey.coverageBreadth:
            const CoveragePct(coveredTopics: 8, totalTopics: 10),
      },
      'You learn it fully before you put it to work.'
    ),
    (
      'long_memory',
      {
        SignalKey.retentionShape:
            const RetentionCurve(averageStability: 9, lapseRate: 0.05),
      },
      'What you learn stays with you.'
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
      'You never leave a question unchecked.'
    ),
    (
      'time_master',
      {
        SignalKey.mockPacing: const PacingProfile(
          averageSpareSeconds: 90,
          sectionTimeSeconds: {},
        ),
      },
      'The clock works for you, not against you.'
    ),
    (
      'closer',
      {
        SignalKey.mockStamina:
            const StaminaDelta(firstHalfAccuracy: 0.7, secondHalfAccuracy: 0.8),
      },
      'You save your best for last.'
    ),
  ]) {
    test('$id line uses the approved identity', () {
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
}
