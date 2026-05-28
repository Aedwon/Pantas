import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metric_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/mock_payload_reader.dart';
import 'package:drift/drift.dart';

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
    var flagged = 0;
    var revisited = 0;
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
      flagged += payload.flaggedQuestionIds.length;
      revisited +=
          payload.flaggedQuestionIds.where(payload.answers.containsKey).length;
    }
    if (flagged == 0) return null;
    return FlagRevisitRatio(flaggedCount: flagged, revisitedCount: revisited);
  }
}
