import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';
import 'package:pantas/features/metrics/signals/signal_content_helpers.dart';

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
    final observed = <({String subject, MetricAttemptItem item, bool timed})>[];
    final rows = await _attemptRows(window: window, examId: examId);
    for (final row in rows) {
      final timed = !AttemptOrigins.untimed.contains(row.origin);
      for (final item in _reader.read(row.itemsJson)) {
        final subject = await _content.subjectNameForQuestion(item.questionId);
        if (subject == null) continue;
        observed.add((subject: subject, item: item, timed: timed));
      }
    }
    return MetricCalculations.subjectAffinity(observed);
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
