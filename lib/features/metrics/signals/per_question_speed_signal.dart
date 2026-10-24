import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';

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

    return MetricCalculations.speed([
      for (final row in await query.get()) ..._reader.read(row.itemsJson),
    ]);
  }
}
