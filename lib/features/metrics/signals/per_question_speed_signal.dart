import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt_origins.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metric_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/attempt_item_reader.dart';
import 'package:drift/drift.dart';

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
        all.add(item.responseMs);
        (item.isCorrect ? correct : incorrect).add(item.responseMs);
      }
    }
    if (all.isEmpty) return null;
    return LatencyDistribution(
      averageMs: _average(all),
      correctAverageMs: _average(correct),
      incorrectAverageMs: _average(incorrect),
    );
  }

  double _average(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}
