import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/metrics/signals/counted_attempts.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';

class PerQuestionSpeedSignal implements Signal<LatencyDistribution> {
  const PerQuestionSpeedSignal(
    this._db, {
    AttemptItemReader? reader,
    AttemptScope? scope,
  })  : _reader = reader ?? const AttemptItemReader(),
        _scope = scope;

  final AppDatabase _db;
  final AttemptScope? _scope;
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
    final scope = _scope;
    if (scope != null) {
      // Own-exam answers plus, when the student carries them over, answers
      // from other exams on questions this exam lists.
      final items = [
        for (final attempt in await scope.attempts(_db, examId))
          if (!AttemptOrigins.untimed.contains(attempt.row.origin) &&
              !attempt.row.startedAt.isAfter(window.end) &&
              (window.start == null ||
                  !attempt.row.startedAt.isBefore(window.start!)))
            for (final item in _reader.read(attempt.row.itemsJson))
              if (attempt.counts(item.questionId)) item,
      ];
      return MetricCalculations.speed(items);
    }
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

    return MetricCalculations.speed([
      for (final row in await query.get()) ..._reader.read(row.itemsJson),
    ]);
  }
}
