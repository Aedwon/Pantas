import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';
import 'package:pantas/features/metrics/signals/signal_content_helpers.dart';
import 'package:drift/drift.dart';

class TestModeDeltaSignal implements Signal<PressureDelta> {
  TestModeDeltaSignal(this._db, ContentDatabase contentDb)
      : _attemptReader = const AttemptItemReader(),
        _mockReader = const MockPayloadReader(),
        _content = SignalContentHelpers(contentDb);

  final AppDatabase _db;
  final AttemptItemReader _attemptReader;
  final MockPayloadReader _mockReader;
  final SignalContentHelpers _content;

  @override
  int get minDataPoints => 14;

  @override
  Set<MetricsWindow> get supportedWindows => {MetricsWindow.prepWindow};

  @override
  Future<PressureDelta?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    var practiceCorrect = 0;
    var practiceTotal = 0;
    var mockCorrect = 0;
    var mockTotal = 0;

    final attempts = _db.select(_db.attemptsLocal)
      ..where((row) => row.examId.equals(examId) & row.completedAt.isNotNull());
    for (final row in await attempts.get()) {
      for (final item in _attemptReader.read(row.itemsJson)) {
        practiceTotal += 1;
        if (item.isCorrect) practiceCorrect += 1;
      }
    }

    final mocks = _db.select(_db.mockAttempts)
      ..where((row) => row.examId.equals(examId) & row.submittedAt.isNotNull());
    for (final row in await mocks.get()) {
      final payload = _mockReader.read(
        sampledQuestionsJson: row.sampledQuestionsJson,
        answersJson: row.answersJson,
        flagsJson: row.flagsJson,
        sectionResultsJson: row.sectionResultsJson,
      );
      for (final section in payload.sections) {
        for (final questionId in section.questionIds) {
          final answer = payload.answers[questionId];
          final correctIndex = await _content.correctIndex(questionId);
          if (answer == null || correctIndex == null) continue;
          mockTotal += 1;
          if (answer.selectedIndex == correctIndex) mockCorrect += 1;
        }
      }
    }
    if (practiceTotal == 0 || mockTotal == 0) return null;
    return PressureDelta(
      practiceAccuracy: practiceCorrect / practiceTotal,
      mockAccuracy: mockCorrect / mockTotal,
    );
  }
}
