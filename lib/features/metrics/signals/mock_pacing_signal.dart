import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metric_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/mock_payload_reader.dart';
import 'package:drift/drift.dart';

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
    final spareSeconds = <int>[];
    final sectionTotals = <String, int>{};
    final sectionCounts = <String, int>{};

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
      spareSeconds.add((row.durationMinutes * 60) - total);
      final payload = _reader.read(
        sampledQuestionsJson: row.sampledQuestionsJson,
        answersJson: row.answersJson,
        flagsJson: row.flagsJson,
        sectionResultsJson: row.sectionResultsJson,
      );
      for (final section in payload.sectionResults) {
        sectionTotals.update(
          section.sectionId,
          (value) => value + section.timeSeconds,
          ifAbsent: () => section.timeSeconds,
        );
        sectionCounts.update(
          section.sectionId,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    if (spareSeconds.isEmpty) return null;
    return PacingProfile(
      averageSpareSeconds: _average(spareSeconds),
      sectionTimeSeconds: {
        for (final entry in sectionTotals.entries)
          entry.key: (entry.value / sectionCounts[entry.key]!).round(),
      },
    );
  }

  double _average(List<int> values) =>
      values.reduce((a, b) => a + b) / values.length;
}
