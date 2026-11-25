import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/streak_repository.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';

const _studyDaysKey = 'settings.study_days';

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

    // The stored count is stale after missed days, so it is read against the
    // window's end by the streak evaluator's own rule (P10/U61).
    final studyDays = StudyDays.fromStorage(
      (await (_db.select(_db.accountPrefs)
                ..where((pref) => pref.key.equals(_studyDaysKey)))
              .getSingleOrNull())
          ?.value,
    );
    return StreakPattern(
      currentStreakDays: streak == null
          ? 0
          : streakOn(
              StreakSnapshot(
                current: streak.current,
                longest: streak.longest,
                lastActiveDate: streak.lastActiveDate,
                freezesRemaining: streak.freezesRemaining,
              ),
              window.end.toLocal(),
              studyDays,
            ),
      longestStreakDays: streak?.longest ?? 0,
      weekdayCounts: Map.unmodifiable(weekdays),
    );
  }
}
