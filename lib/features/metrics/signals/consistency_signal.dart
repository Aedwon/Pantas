import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

class ConsistencySignal implements Signal<StreakPattern> {
  const ConsistencySignal(this._db);

  final AppDatabase _db;

  @override
  int get minDataPoints => 1;

  @override
  Set<MetricsWindow> get supportedWindows => {
        MetricsWindow.allTime,
        MetricsWindow.prepWindow,
      };

  @override
  Future<StreakPattern?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final streak =
        await (_db.select(_db.streakLocal)..limit(1)).getSingleOrNull();
    final weekdays = <int, int>{};

    var quizQuery = _db.select(_db.quizSessions)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.completedAt.isNotNull() &
            row.completedAt.isSmallerOrEqualValue(window.end),
      );
    if (window.start != null) {
      quizQuery = quizQuery
        ..where((row) => row.completedAt.isBiggerOrEqualValue(window.start!));
    }
    for (final row in await quizQuery.get()) {
      final completedAt = row.completedAt;
      if (completedAt == null) continue;
      weekdays.update(
        completedAt.weekday,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
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
      final submittedAt = row.submittedAt;
      if (submittedAt == null) continue;
      weekdays.update(
        submittedAt.weekday,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return StreakPattern(
      currentStreakDays: streak?.current ?? 0,
      longestStreakDays: streak?.longest ?? 0,
      weekdayCounts: Map.unmodifiable(weekdays),
    );
  }
}
