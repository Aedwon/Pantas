import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:drift/drift.dart';

class DifficultyCalibrationSignal implements Signal<CalibrationCurve> {
  DifficultyCalibrationSignal(this._db) : _reader = const AttemptItemReader();

  final AppDatabase _db;
  final AttemptItemReader _reader;

  @override
  int get minDataPoints => 14;

  @override
  Set<MetricsWindow> get supportedWindows => {MetricsWindow.prepWindow};

  @override
  Future<CalibrationCurve?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final stats = <double, _CalibrationStats>{};
    final attempts = await (_db.select(_db.attemptsLocal)
          ..where(
            (row) =>
                row.examId.equals(examId) &
                row.completedAt.isNotNull() &
                row.origin.isNotIn(AttemptOrigins.untimed.toList()),
          ))
        .get();
    for (final attempt in attempts) {
      for (final item in _reader.read(attempt.itemsJson)) {
        final state = await (_db.select(_db.reviewStateLocal)
              ..where((row) => row.questionId.equals(item.questionId)))
            .getSingleOrNull();
        if (state == null) continue;
        stats.putIfAbsent(state.difficulty, _CalibrationStats.new).add(
              isCorrect: item.isCorrect,
              responseMs: item.responseMs,
            );
      }
    }
    if (stats.isEmpty) return null;
    return CalibrationCurve(
      points: [
        for (final entry in stats.entries)
          CalibrationPoint(
            difficulty: entry.key,
            averageMs: entry.value.averageMs,
            accuracy: entry.value.accuracy,
          ),
      ]..sort((a, b) => a.difficulty.compareTo(b.difficulty)),
    );
  }
}

class _CalibrationStats {
  int correct = 0;
  int total = 0;
  int totalMs = 0;

  void add({required bool isCorrect, required int responseMs}) {
    total += 1;
    totalMs += responseMs;
    if (isCorrect) correct += 1;
  }

  double get averageMs => totalMs / total;
  double get accuracy => correct / total;
}
