import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';

class PerQuestionSpeedSignal implements Signal<LatencyDistribution> {
  const PerQuestionSpeedSignal(this._db, {AttemptItemReader? reader})
      : _reader = reader ?? const AttemptItemReader();

  final AppDatabase _db;
  final AttemptItemReader _reader;

  @override
  int get minDataPoints => 7;

  @override
  Set<MetricsWindow> get supportedWindows => {
        MetricsWindow.rolling30d,
        MetricsWindow.prepWindow,
      };

  @override
  Future<LatencyDistribution?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    var query = _db.select(_db.attemptsLocal)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.completedAt.isNotNull() &
            row.startedAt.isSmallerOrEqualValue(window.end) &
            // Untimed origins carry responseMs: 0 for every item. Averaging
            // them in would report answers given instantly.
            row.origin.isNotIn(AttemptOrigins.untimed.toList()),
      );
    if (window.start != null) {
      query = query
        ..where((row) => row.startedAt.isBiggerOrEqualValue(window.start!));
    }

    final all = <int>[];
    final correct = <int>[];
    final incorrect = <int>[];
    for (final row in await query.get()) {
      for (final item in _reader.read(row.itemsJson)) {
        // Log time is defined only for a positive measured duration.
        if (item.responseMs <= 0) continue;
        all.add(item.responseMs);
        (item.isCorrect ? correct : incorrect).add(item.responseMs);
      }
    }
    if (all.isEmpty) return null;
    final correctLogs = _logMoments(correct);
    final incorrectLogs = _logMoments(incorrect);
    return LatencyDistribution(
      averageMs: _average(all),
      correctAverageMs: _average(correct),
      incorrectAverageMs: _average(incorrect),
      sampleCount: all.length,
      correctCount: correct.length,
      incorrectCount: incorrect.length,
      correctLogMean: correctLogs.mean,
      incorrectLogMean: incorrectLogs.mean,
      correctLogVariance: correctLogs.variance,
      incorrectLogVariance: incorrectLogs.variance,
    );
  }

  ({double mean, double variance}) _logMoments(List<int> values) {
    // Welford's recurrence keeps sample variance stable for nearly equal times.
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

  double _average(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}
