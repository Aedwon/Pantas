import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

class SessionShapeSignal implements Signal<DurationDistribution> {
  const SessionShapeSignal(this._db);

  final AppDatabase _db;

  @override
  int get minDataPoints => 7;

  @override
  Set<MetricsWindow> get supportedWindows => {
        MetricsWindow.rolling30d,
        MetricsWindow.prepWindow,
      };

  @override
  Future<DurationDistribution?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final minutes = <double>[];

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
      final completedAt = row.completedAt;
      if (completedAt == null) continue;
      minutes.add(completedAt.difference(row.startedAt).inSeconds / 60);
    }

    var mockQuery = _db.select(_db.mockAttempts)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.submittedAt.isNotNull() &
            row.submittedAt.isSmallerOrEqualValue(window.end),
      );
    if (window.start != null) {
      mockQuery = mockQuery
        ..where((row) => row.submittedAt.isBiggerOrEqualValue(window.start!));
    }
    for (final row in await mockQuery.get()) {
      final seconds = row.totalTimeSeconds;
      if (seconds != null && seconds > 0) {
        minutes.add(seconds / 60);
      } else {
        final submittedAt = row.submittedAt;
        if (submittedAt != null) {
          minutes.add(submittedAt.difference(row.startedAt).inSeconds / 60);
        }
      }
    }

    if (minutes.isEmpty) return null;
    final average = minutes.reduce((a, b) => a + b) / minutes.length;
    return DurationDistribution(
      averageMinutes: average,
      sessionCount: minutes.length,
    );
  }
}
