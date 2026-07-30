import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

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
    final buckets = <int, _Bucket>{};

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
      buckets
          .putIfAbsent(row.startedAt.hour, _Bucket.new)
          .add(correct: row.correctCount, total: row.currentIndex);
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
      buckets
          .putIfAbsent(submittedAt.hour, _Bucket.new)
          .add(correct: correct, total: total);
    }

    if (buckets.isEmpty) return null;
    return DayHourHistogram(
      buckets: [
        for (final entry in buckets.entries)
          DayHourBucket(
            hour: entry.key,
            correct: entry.value.correct,
            total: entry.value.total,
          ),
      ]..sort((a, b) => a.hour.compareTo(b.hour)),
    );
  }
}

class _Bucket {
  int correct = 0;
  int total = 0;

  void add({required int correct, required int total}) {
    this.correct += correct;
    this.total += total;
  }
}
