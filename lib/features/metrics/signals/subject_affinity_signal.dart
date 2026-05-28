import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metric_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/attempt_item_reader.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/signal_content_helpers.dart';
import 'package:drift/drift.dart';

class SubjectAffinitySignal implements Signal<SubjectAccuracySpeed> {
  SubjectAffinitySignal(this._db)
      : _reader = const AttemptItemReader(),
        _content = SignalContentHelpers(_db);

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
      for (final item in _reader.read(row.itemsJson)) {
        final subject = await _content.subjectNameForQuestion(item.questionId);
        if (subject == null) continue;
        stats.putIfAbsent(subject, _SubjectStats.new).add(
              isCorrect: item.isCorrect,
              responseMs: item.responseMs,
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

  void add({required bool isCorrect, required int responseMs}) {
    total += 1;
    totalMs += responseMs;
    if (isCorrect) correct += 1;
  }

  double get averageMs => total == 0 ? 0 : totalMs / total;
}
