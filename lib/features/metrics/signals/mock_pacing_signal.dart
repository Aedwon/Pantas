import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';

class MockPacingSignal implements Signal<PacingProfile> {
  const MockPacingSignal(this._db, {MockPayloadReader? reader})
      : _reader = reader ?? const MockPayloadReader();

  final AppDatabase _db;
  final MockPayloadReader _reader;

  @override
  int get minDataPoints => 14;

  @override
  Set<MetricsWindow> get supportedWindows => {
        MetricsWindow.rolling30d,
        MetricsWindow.prepWindow,
      };

  @override
  Future<PacingProfile?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final observed = <({int spareSeconds, Map<String, int> sectionTimes})>[];

    var query = _db.select(_db.mockAttempts)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.submittedAt.isNotNull() &
            row.totalTimeSeconds.isNotNull() &
            row.submittedAt.isSmallerOrEqualValue(window.end),
      );
    if (window.start != null) {
      query = query
        ..where((row) => row.submittedAt.isBiggerOrEqualValue(window.start!));
    }

    for (final row in await query.get()) {
      final total = row.totalTimeSeconds;
      if (total == null) continue;

      final payload = _reader.read(
        sampledQuestionsJson: row.sampledQuestionsJson,
        answersJson: row.answersJson,
        flagsJson: row.flagsJson,
        sectionResultsJson: row.sectionResultsJson,
      );
      observed.add(
        (
          spareSeconds: row.durationMinutes * 60 - total,
          sectionTimes: {
            for (final section in payload.sectionResults)
              section.sectionId: section.timeSeconds,
          }
        ),
      );
    }

    return MetricCalculations.pacing(observed);
  }
}
