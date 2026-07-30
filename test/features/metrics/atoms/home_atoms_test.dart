import 'package:pantas/features/metrics/atoms/home_atoms.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('time of day atom reports the sharpest hour', () async {
    final atom = TimeOfDayAtom(
      _reader({
        SignalKey.timeOfDay: const DayHourHistogram(
          buckets: [
            DayHourBucket(hour: 9, correct: 7, total: 10),
            DayHourBucket(hour: 21, correct: 9, total: 10),
          ],
        ),
      }),
    );

    final chip = await atom.select(examId: 'exam_cse');

    expect(chip?.text, 'Sharpest at 9pm');
    expect(chip?.metric, '9 PM');
  });

  test('session shape atom rounds average minutes', () async {
    final atom = SessionShapeAtom(
      _reader({
        SignalKey.sessionShape: const DurationDistribution(
          averageMinutes: 8.4,
          sessionCount: 7,
        ),
      }),
    );

    expect((await atom.select(examId: 'exam_cse'))?.text, 'Avg 8-min sits');
  });

  test('consistency atom reports current streak', () async {
    final atom = ConsistencyAtom(
      _reader({
        SignalKey.consistency: const StreakPattern(
          currentStreakDays: 18,
          longestStreakDays: 31,
          weekdayCounts: {},
        ),
      }),
    );

    expect((await atom.select(examId: 'exam_cse'))?.text, 'Day 18 streak');
  });

  test('per question speed atom reports average seconds', () async {
    final atom = PerQuestionSpeedAtom(
      _reader({
        SignalKey.perQuestionSpeed: const LatencyDistribution(
          averageMs: 12000,
          correctAverageMs: 9000,
          incorrectAverageMs: 18000,
          sampleCount: 20,
        ),
      }),
    );

    expect(
      (await atom.select(examId: 'exam_cse'))?.text,
      '12s avg, fast and accurate',
    );
  });

  test('subject affinity atom reports fastest subject delta', () async {
    final atom = SubjectAffinityAtom(
      _reader({
        SignalKey.subjectAffinity: const SubjectAccuracySpeed(
          subjects: {
            'Grammar': SubjectAccuracySpeedRow(
              correct: 8,
              total: 10,
              averageMs: 7000,
            ),
            'Math': SubjectAccuracySpeedRow(
              correct: 8,
              total: 10,
              averageMs: 10000,
            ),
          },
        ),
      }),
    );

    expect((await atom.select(examId: 'exam_cse'))?.text, 'Grammar 30% faster');
  });

  test('coverage breadth atom reports syllabus coverage percent', () async {
    final atom = CoverageBreadthAtom(
      _reader({
        SignalKey.coverageBreadth: const CoveragePct(
          coveredTopics: 78,
          totalTopics: 100,
        ),
      }),
    );

    expect(
      (await atom.select(examId: 'exam_cse'))?.text,
      'Touched 78% of syllabus',
    );
  });

  test('retention shape atom reports lapse rate', () async {
    final atom = RetentionShapeAtom(
      _reader({
        SignalKey.retentionShape: const RetentionCurve(
          averageStability: 10,
          lapseRate: 0.03,
        ),
      }),
    );

    expect(
      (await atom.select(examId: 'exam_cse'))?.text,
      'Strong cards lapse 3%',
    );
  });

  test('atom returns null when its signal is unavailable', () async {
    final atom = TimeOfDayAtom(_reader({}));

    expect(await atom.select(examId: 'exam_cse'), isNull);
  });
}

SignalReader _reader(Map<SignalKey, Object> values) {
  return ({
    required SignalKey signal,
    required MetricsWindow window,
    required String examId,
  }) async =>
      values[signal];
}
