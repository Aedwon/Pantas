import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metric_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/mock_payload_reader.dart';
import 'package:drift/drift.dart';

class MockStaminaSignal implements Signal<StaminaDelta> {
  const MockStaminaSignal(this._db, {MockPayloadReader? reader})
      : _reader = reader ?? const MockPayloadReader();

  final AppDatabase _db;
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
    var firstCorrect = 0;
    var firstTotal = 0;
    var secondCorrect = 0;
    var secondTotal = 0;

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
      final midpoint = questionIds.length ~/ 2;
      for (var i = 0; i < questionIds.length; i += 1) {
        final questionId = questionIds[i];
        final answer = payload.answers[questionId];
        final isCorrect = answer != null &&
            answer.selectedIndex == await _correctIndex(questionId);
        if (i < midpoint) {
          firstTotal += 1;
          if (isCorrect) firstCorrect += 1;
        } else {
          secondTotal += 1;
          if (isCorrect) secondCorrect += 1;
        }
      }
    }
    if (firstTotal == 0 || secondTotal == 0) return null;
    return StaminaDelta(
      firstHalfAccuracy: firstCorrect / firstTotal,
      secondHalfAccuracy: secondCorrect / secondTotal,
    );
  }

  Future<int?> _correctIndex(String questionId) async {
    final row = await (_db.select(_db.questions)
          ..where((question) => question.id.equals(questionId)))
        .getSingleOrNull();
    if (row == null) return null;
    final choices = jsonDecode(row.choicesJson) as List;
    for (var i = 0; i < choices.length; i += 1) {
      final choice = choices[i];
      if (choice is Map<String, Object?> && choice['isCorrect'] == true) {
        return i;
      }
    }
    return null;
  }
}
