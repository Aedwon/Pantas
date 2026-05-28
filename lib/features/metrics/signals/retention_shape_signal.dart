import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metric_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';

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
    if (states.isEmpty) return null;
    final stability = states.fold<double>(0, (sum, row) => sum + row.stability);
    final reps = states.fold<int>(0, (sum, row) => sum + row.reps);
    final lapses = states.fold<int>(0, (sum, row) => sum + row.lapses);
    return RetentionCurve(
      averageStability: stability / states.length,
      lapseRate: reps == 0 ? 0 : lapses / reps,
    );
  }
}
