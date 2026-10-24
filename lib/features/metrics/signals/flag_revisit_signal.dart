import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';

class FlagRevisitSignal implements Signal<FlagRevisitRatio> {
  const FlagRevisitSignal(this._db, {MockPayloadReader? reader})
      : _reader = reader ?? const MockPayloadReader();

  final AppDatabase _db;
  final MockPayloadReader _reader;

  @override
  int get minDataPoints => 14;

  @override
  Set<MetricsWindow> get supportedWindows => {MetricsWindow.prepWindow};

  @override
  Future<FlagRevisitRatio?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final observed = <({Set<String> flagged, Set<String> answered})>[];
    var query = _db.select(_db.mockAttempts)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.submittedAt.isNotNull() &
            row.submittedAt.isSmallerOrEqualValue(window.end),
      );
    if (window.start != null) {
      query = query
        ..where((row) => row.submittedAt.isBiggerOrEqualValue(window.start!));
    }
    for (final row in await query.get()) {
      final payload = _reader.read(
        sampledQuestionsJson: row.sampledQuestionsJson,
        answersJson: row.answersJson,
        flagsJson: row.flagsJson,
        sectionResultsJson: row.sectionResultsJson,
      );
      observed.add(
        (
          flagged: payload.flaggedQuestionIds.toSet(),
          answered: payload.answers.keys.toSet()
        ),
      );
    }
    return MetricCalculations.flagRevisit(observed);
  }
}
