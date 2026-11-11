import 'dart:convert';

import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

/// The single section-result decoder, also used by the history contract.
/// Legacy counts come from the saved selections, never a guessed split.
MockResults? decodeMockResults(
  MockAttempt attempt, {
  Set<String>? activeQuestionIds,
}) {
  final raw = attempt.sectionResultsJson;
  if (raw == null) return null;
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final sample = jsonDecode(attempt.sampledQuestionsJson) as List<dynamic>;
  final answers = jsonDecode(attempt.answersJson) as Map<String, dynamic>;
  final sections = <SectionResult>[];
  for (final value in decoded['sections'] as List<dynamic>? ?? []) {
    final map = value as Map<String, dynamic>;
    final id = map['sectionId'] as String;
    final correct = map['correct'] as int;
    final total = map['total'] as int;
    var wrong = map['wrong'] as int?;
    var blank = map['blank'] as int?;
    if (wrong == null || blank == null) {
      var answered = 0;
      for (final value in sample) {
        final part = value as Map<String, dynamic>;
        if (part['sectionId'] != id) continue;
        for (final questionId in part['questionIds'] as List<dynamic>) {
          if (activeQuestionIds != null &&
              !activeQuestionIds.contains(questionId)) {
            continue;
          }
          final answer = answers[questionId] as Map<String, dynamic>?;
          if (answer != null && (answer['selectedIndex'] as int) >= 0) {
            answered++;
          }
        }
      }
      wrong ??= answered - correct;
      blank ??= total - answered;
      if (wrong < 0 || blank < 0) {
        throw const FormatException('Saved counts do not match the answers');
      }
    }
    sections.add(
      SectionResult(
        sectionId: id,
        name: map['name'] as String,
        correct: correct,
        total: total,
        wrong: wrong,
        blank: blank,
        retiredCount: map['retiredCount'] as int,
        timeSeconds: map['timeSeconds'] as int,
      ),
    );
  }
  return MockResults(
    scoreRaw: sections.fold(0, (sum, section) => sum + section.correct),
    scoreTotal: sections.fold(0, (sum, section) => sum + section.total),
    percent: mockScorePercent(examId: attempt.examId, sections: sections),
    sections: List.unmodifiable(sections),
    topWeak: [
      for (final value in decoded['topWeak'] as List<dynamic>? ?? [])
        WeakTopic(
          topicId: (value as Map<String, dynamic>)['topicId'] as String,
          correct: value['correct'] as int,
          total: value['total'] as int,
        ),
    ],
    totalTimeSeconds: attempt.totalTimeSeconds ?? attempt.elapsedSeconds,
    wasStrict: attempt.strictMode,
  );
}
