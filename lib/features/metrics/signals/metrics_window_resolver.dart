import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metrics_thresholds.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:drift/drift.dart';

class MetricsWindowResolver {
  const MetricsWindowResolver(this._db);

  final AppDatabase _db;

  Future<ResolvedMetricsWindow> resolve({
    required String examId,
    required MetricsWindow window,
    required DateTime now,
    DateTime? prepStartedAt,
  }) async {
    final start = switch (window) {
      MetricsWindow.rolling30d => now.subtract(const Duration(days: 30)),
      MetricsWindow.prepWindow => prepStartedAt,
      MetricsWindow.allTime => null,
    };
    final count = await _completedSessionCount(
      examId: examId,
      start: start,
      end: now,
    );
    return ResolvedMetricsWindow(
      window: window,
      start: start,
      end: now,
      sessionCount: count,
      minSessionCount: MetricsThresholds.minSessionsFor(window),
    );
  }

  Future<int> _completedSessionCount({
    required String examId,
    required DateTime? start,
    required DateTime end,
  }) async {
    final quizCount = await _completedQuizCount(
      examId: examId,
      start: start,
      end: end,
    );
    final mockCount = await _completedMockCount(
      examId: examId,
      start: start,
      end: end,
    );
    return quizCount + mockCount;
  }

  Future<int> _completedQuizCount({
    required String examId,
    required DateTime? start,
    required DateTime end,
  }) async {
    final count = _db.quizSessions.id.count();
    final query = _db.selectOnly(_db.quizSessions)..addColumns([count]);
    var where = _db.quizSessions.examId.equals(examId) &
        _db.quizSessions.completedAt.isNotNull() &
        _db.quizSessions.completedAt.isSmallerOrEqualValue(end);
    if (start != null) {
      where = where & _db.quizSessions.completedAt.isBiggerOrEqualValue(start);
    }
    query.where(where);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> _completedMockCount({
    required String examId,
    required DateTime? start,
    required DateTime end,
  }) async {
    final count = _db.mockAttempts.id.count();
    final query = _db.selectOnly(_db.mockAttempts)..addColumns([count]);
    var where = _db.mockAttempts.examId.equals(examId) &
        _db.mockAttempts.submittedAt.isNotNull() &
        _db.mockAttempts.status.isIn(['completed', 'forfeited']) &
        _db.mockAttempts.submittedAt.isSmallerOrEqualValue(end);
    if (start != null) {
      where = where & _db.mockAttempts.submittedAt.isBiggerOrEqualValue(start);
    }
    query.where(where);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
