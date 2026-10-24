import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';

class RetentionShapeSignal implements Signal<RetentionCurve> {
  const RetentionShapeSignal(this._db);

  final AppDatabase _db;

  @override
  int get minDataPoints => 7;

  @override
  Set<MetricsWindow> get supportedWindows => {
        MetricsWindow.rolling30d,
        MetricsWindow.prepWindow,
      };

  @override
  Future<RetentionCurve?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final states = await _db.select(_db.reviewStateLocal).get();
    return MetricCalculations.retention([
      for (final row in states)
        (stability: row.stability, reps: row.reps, lapses: row.lapses),
    ]);
  }
}
