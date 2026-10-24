import 'dart:math' as math;

import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';

/// Shared aggregation of observations. Database readers and server codecs only
/// select and describe rows; these functions own the measured calculations.
abstract final class MetricCalculations {
  static DayHourHistogram? timeOfDay(
    Iterable<({int hour, int correct, int total})> rows,
  ) {
    final buckets = <int, ({int correct, int total})>{};
    for (final row in rows) {
      if (row.total <= 0) continue;
      final old = buckets[row.hour] ?? (correct: 0, total: 0);
      buckets[row.hour] = (
        correct: old.correct + row.correct,
        total: old.total + row.total,
      );
    }
    if (buckets.isEmpty) return null;
    return DayHourHistogram(
      buckets: [
        for (final entry in buckets.entries)
          DayHourBucket(
            hour: entry.key,
            correct: entry.value.correct,
            total: entry.value.total,
          ),
      ]..sort((a, b) => a.hour.compareTo(b.hour)),
    );
  }

  static DurationDistribution? sessionShape(Iterable<double> minutes) {
    final values = minutes.toList();
    if (values.isEmpty) return null;
    return DurationDistribution(
      averageMinutes: values.reduce((a, b) => a + b) / values.length,
      sessionCount: values.length,
    );
  }

  static LatencyDistribution? speed(Iterable<MetricAttemptItem> items) {
    final all = <int>[];
    final correct = <int>[];
    final incorrect = <int>[];
    for (final item in items) {
      if (item.responseMs <= 0) continue;
      all.add(item.responseMs);
      (item.isCorrect ? correct : incorrect).add(item.responseMs);
    }
    if (all.isEmpty) return null;
    final c = _logMoments(correct);
    final w = _logMoments(incorrect);
    return LatencyDistribution(
      averageMs: _average(all),
      correctAverageMs: _average(correct),
      incorrectAverageMs: _average(incorrect),
      sampleCount: all.length,
      correctCount: correct.length,
      incorrectCount: incorrect.length,
      correctLogMean: c.mean,
      incorrectLogMean: w.mean,
      correctLogVariance: c.variance,
      incorrectLogVariance: w.variance,
    );
  }

  static PressureDelta? pressure({
    required Iterable<bool> practice,
    required Iterable<bool> mock,
    required bool allowEmpty,
  }) {
    final p = practice.toList();
    final m = mock.toList();
    if (!allowEmpty && (p.isEmpty || m.isEmpty)) return null;
    final pc = p.where((x) => x).length;
    final mc = m.where((x) => x).length;
    return PressureDelta(
      practiceAccuracy: p.isEmpty ? 0 : pc / p.length,
      mockAccuracy: m.isEmpty ? 0 : mc / m.length,
      practiceCorrect: pc,
      practiceTotal: p.length,
      mockCorrect: mc,
      mockTotal: m.length,
    );
  }

  static StaminaDelta? stamina(Iterable<List<bool>> mocks) {
    var firstCorrect = 0;
    var firstTotal = 0;
    var secondCorrect = 0;
    var secondTotal = 0;
    for (final mock in mocks) {
      final midpoint = mock.length ~/ 2;
      for (var i = 0; i < mock.length; i++) {
        if (i < midpoint) {
          firstTotal++;
          if (mock[i]) firstCorrect++;
        } else {
          secondTotal++;
          if (mock[i]) secondCorrect++;
        }
      }
    }
    if (firstTotal == 0 || secondTotal == 0) return null;
    return StaminaDelta(
      firstHalfAccuracy: firstCorrect / firstTotal,
      secondHalfAccuracy: secondCorrect / secondTotal,
      firstHalfCorrect: firstCorrect,
      firstHalfTotal: firstTotal,
      secondHalfCorrect: secondCorrect,
      secondHalfTotal: secondTotal,
    );
  }

  static WorkflowRatio? workflow({
    required Iterable<({String topicId, DateTime startedAt})> attempts,
    required Iterable<({String topicId, DateTime readAt, bool inExam})> lessons,
    required bool allowEmpty,
  }) {
    final first = <String, DateTime>{};
    for (final row in attempts) {
      final old = first[row.topicId];
      if (old == null || row.startedAt.isBefore(old)) {
        first[row.topicId] = row.startedAt;
      }
    }
    var before = 0;
    var after = 0;
    var reads = 0;
    for (final row in lessons) {
      if (row.inExam) reads++;
      final attempt = first[row.topicId];
      if (attempt == null) continue;
      if (!row.readAt.isAfter(attempt)) {
        before++;
      } else {
        after++;
      }
    }
    if (before + after == 0 && !allowEmpty) return null;
    return WorkflowRatio(
      readThenQuizCount: before,
      quizFirstCount: after,
      readLessonCount: reads,
      practicedTopicCount: first.length,
    );
  }

  static RetentionCurve? retention(
    Iterable<({double stability, int reps, int lapses})> rows,
  ) {
    final states = rows.toList();
    if (states.isEmpty) return null;
    final stability = states.fold<double>(0, (sum, row) => sum + row.stability);
    final reviews =
        states.fold<int>(0, (sum, row) => sum + math.max(row.reps - 1, 0));
    final lapses = states.fold<int>(0, (sum, row) => sum + row.lapses);
    return RetentionCurve(
      averageStability: stability / states.length,
      lapseRate: reviews == 0 ? 0 : lapses / reviews,
      reviewCount: reviews,
      lapseCount: lapses,
    );
  }

  static SubjectAccuracySpeed? subjectAffinity(
    Iterable<({String subject, MetricAttemptItem item, bool timed})> rows,
  ) {
    final groups = <String, ({int correct, int total, int ms, int timed})>{};
    for (final row in rows) {
      final old =
          groups[row.subject] ?? (correct: 0, total: 0, ms: 0, timed: 0);
      groups[row.subject] = (
        correct: old.correct + (row.item.isCorrect ? 1 : 0),
        total: old.total + 1,
        ms: old.ms + (row.timed ? row.item.responseMs : 0),
        timed: old.timed + (row.timed ? 1 : 0)
      );
    }
    if (groups.isEmpty) return null;
    return SubjectAccuracySpeed(
      subjects: {
        for (final entry in groups.entries)
          entry.key: SubjectAccuracySpeedRow(
            correct: entry.value.correct,
            total: entry.value.total,
            averageMs:
                entry.value.timed == 0 ? 0 : entry.value.ms / entry.value.timed,
          ),
      },
    );
  }

  static FlagRevisitRatio? flagRevisit(
    Iterable<({Set<String> flagged, Set<String> answered})> rows,
  ) {
    var flagged = 0;
    var revisited = 0;
    for (final row in rows) {
      flagged += row.flagged.length;
      revisited += row.flagged.where(row.answered.contains).length;
    }
    return flagged == 0
        ? null
        : FlagRevisitRatio(flaggedCount: flagged, revisitedCount: revisited);
  }

  static PacingProfile? pacing(
    Iterable<({int spareSeconds, Map<String, int> sectionTimes})> rows,
  ) {
    final spare = <int>[];
    final totals = <String, int>{};
    final counts = <String, int>{};
    for (final row in rows) {
      spare.add(row.spareSeconds);
      for (final entry in row.sectionTimes.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
        counts[entry.key] = (counts[entry.key] ?? 0) + 1;
      }
    }
    if (spare.isEmpty) return null;
    return PacingProfile(
      averageSpareSeconds: _average(spare),
      sectionTimeSeconds: {
        for (final entry in totals.entries)
          entry.key: (entry.value / counts[entry.key]!).round(),
      },
    );
  }

  static CoveragePct? coverage(
    Set<String> examTopics,
    Iterable<String> readTopics,
  ) {
    if (examTopics.isEmpty) return null;
    return CoveragePct(
      coveredTopics: readTopics.where(examTopics.contains).toSet().length,
      totalTopics: examTopics.length,
    );
  }

  static double _average(List<int> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

  static ({double mean, double variance}) _logMoments(List<int> values) {
    var count = 0;
    var mean = 0.0;
    var sumSquares = 0.0;
    for (final value in values) {
      count++;
      final logTime = math.log(value);
      final delta = logTime - mean;
      mean += delta / count;
      sumSquares += delta * (logTime - mean);
    }
    return (mean: mean, variance: count < 2 ? 0 : sumSquares / (count - 1));
  }
}
