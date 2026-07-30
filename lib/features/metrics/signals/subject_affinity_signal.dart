import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/metrics/signals/signal_content_helpers.dart';
import 'package:drift/drift.dart';

class SubjectAffinitySignal implements Signal<SubjectAccuracySpeed> {
  SubjectAffinitySignal(this._db, ContentDatabase contentDb)
      : _reader = const AttemptItemReader(),
        _content = SignalContentHelpers(contentDb);

  final AppDatabase _db;
  final AttemptItemReader _reader;
  final SignalContentHelpers _content;

  @override
  int get minDataPoints => 7;

  @override
  Set<MetricsWindow> get supportedWindows => {
        MetricsWindow.rolling30d,
        MetricsWindow.prepWindow,
      };

  @override
  Future<SubjectAccuracySpeed?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final stats = <String, _SubjectStats>{};
    final rows = await _attemptRows(window: window, examId: examId);
    for (final row in rows) {
      final timed = !AttemptOrigins.untimed.contains(row.origin);
      for (final item in _reader.read(row.itemsJson)) {
        final subject = await _content.subjectNameForQuestion(item.questionId);
        if (subject == null) continue;
        stats.putIfAbsent(subject, _SubjectStats.new).add(
              isCorrect: item.isCorrect,
              responseMs: item.responseMs,
              timed: timed,
            );
      }
    }
    if (stats.isEmpty) return null;
    return SubjectAccuracySpeed(
      subjects: {
        for (final entry in stats.entries)
          entry.key: SubjectAccuracySpeedRow(
            correct: entry.value.correct,
            total: entry.value.total,
            averageMs: entry.value.averageMs,
          ),
      },
    );
  }

  Future<List<AttemptLocalRow>> _attemptRows({
    required ResolvedMetricsWindow window,
    required String examId,
  }) {
    var query = _db.select(_db.attemptsLocal)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.completedAt.isNotNull() &
            row.startedAt.isSmallerOrEqualValue(window.end),
      );
    if (window.start != null) {
      query = query
        ..where((row) => row.startedAt.isBiggerOrEqualValue(window.start!));
    }
    return query.get();
  }
}

class _SubjectStats {
  int correct = 0;
  int total = 0;
  int totalMs = 0;

  /// Items from a timed origin. The milliseconds divide by this, never by
  /// [total], or an assessment's zeros would halve the average.
  int timedTotal = 0;

  void add({
    required bool isCorrect,
    required int responseMs,
    required bool timed,
  }) {
    total += 1;
    if (isCorrect) correct += 1;
    if (!timed) return;
    timedTotal += 1;
    totalMs += responseMs;
  }

  double get averageMs => timedTotal == 0 ? 0 : totalMs / timedTotal;
}
