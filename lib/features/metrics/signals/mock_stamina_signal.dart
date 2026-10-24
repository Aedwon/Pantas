import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';
import 'package:pantas/features/metrics/signals/signal_content_helpers.dart';

class MockStaminaSignal implements Signal<StaminaDelta> {
  const MockStaminaSignal(
    this._db,
    this._contentDb, {
    MockPayloadReader? reader,
  }) : _reader = reader ?? const MockPayloadReader();

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final MockPayloadReader _reader;

  @override
  int get minDataPoints => 14;

  @override
  Set<MetricsWindow> get supportedWindows => {MetricsWindow.prepWindow};

  @override
  Future<StaminaDelta?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final observed = <List<bool>>[];

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
      final questionIds = [
        for (final section in payload.sections) ...section.questionIds,
      ];
      observed.add([
        for (final questionId in questionIds)
          payload.answers[questionId] != null &&
              payload.answers[questionId]!.selectedIndex ==
                  await _correctIndex(questionId),
      ]);
    }

    return MetricCalculations.stamina(observed);
  }

  Future<int?> _correctIndex(String questionId) =>
      SignalContentHelpers(_contentDb).correctIndex(questionId);
}
