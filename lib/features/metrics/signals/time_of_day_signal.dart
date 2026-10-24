import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';

class TimeOfDaySignal implements Signal<DayHourHistogram> {
  const TimeOfDaySignal(this._db);

  final AppDatabase _db;

  @override
  int get minDataPoints => 7;

  @override
  Set<MetricsWindow> get supportedWindows => {
        MetricsWindow.rolling30d,
        MetricsWindow.prepWindow,
      };

  @override
  Future<DayHourHistogram?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final rows = <({int hour, int correct, int total})>[];

    var quizQuery = _db.select(_db.quizSessions)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.completedAt.isNotNull() &
            row.startedAt.isSmallerOrEqualValue(window.end),
      );
    if (window.start != null) {
      quizQuery = quizQuery
        ..where((row) => row.startedAt.isBiggerOrEqualValue(window.start!));
    }
    for (final row in await quizQuery.get()) {
      if (row.currentIndex <= 0) continue;
      rows.add(
        (
          hour: row.startedAt.hour,
          correct: row.correctCount,
          total: row.currentIndex
        ),
      );
    }

    var mockQuery = _db.select(_db.mockAttempts)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.submittedAt.isNotNull() &
            row.scoreRaw.isNotNull() &
            row.scoreTotal.isNotNull() &
            row.submittedAt.isSmallerOrEqualValue(window.end),
      );
    if (window.start != null) {
      mockQuery = mockQuery
        ..where((row) => row.submittedAt.isBiggerOrEqualValue(window.start!));
    }
    for (final row in await mockQuery.get()) {
      final total = row.scoreTotal;
      final correct = row.scoreRaw;
      final submittedAt = row.submittedAt;
      if (total == null ||
          total <= 0 ||
          correct == null ||
          submittedAt == null) {
        continue;
      }
      rows.add((hour: submittedAt.hour, correct: correct, total: total));
    }

    return MetricCalculations.timeOfDay(rows);
  }
}
