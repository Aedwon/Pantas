import 'package:flutter/foundation.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';

enum MockFinaleOutcome { correct, wrong, blank }

@immutable
class MockFinaleQuestion {
  const MockFinaleQuestion({required this.id, required this.outcome});
  final String id;
  final MockFinaleOutcome outcome;
}

@immutable
class MockFinalePart {
  MockFinalePart({
    required this.name,
    required List<MockFinaleQuestion> questions,
  }) : questions = List.unmodifiable(questions);
  final String name;
  final List<MockFinaleQuestion> questions;
}

/// A submission-only view snapshot. History never reconstructs this input.
/// Retired questions are omitted; the cursor counts retained questions only.
/// Keep empty original parts. When every question retired, omit the finale.
@immutable
class MockFinaleInput {
  MockFinaleInput({
    required this.reason,
    required this.currentPartIndex,
    required this.currentQuestionIndex,
    required List<MockFinalePart> parts,
  }) : parts = List.unmodifiable(parts);
  final MockSubmitReason reason;
  final int currentPartIndex;
  final int currentQuestionIndex;
  final List<MockFinalePart> parts;
}

MockFinaleInput? buildMockFinaleInput({
  required MockSubmitReason reason,
  required List<String> questionIds,
  required List<({String name, int startIndex, int count})> partRanges,
  required Map<String, Question> questionsById,
  required Map<String, MockAnswer> answers,
  required int currentPartIndex,
  required int currentQuestionIndex,
}) {
  if (partRanges.isEmpty) return null;

  final parts = <MockFinalePart>[];
  var retainedTotal = 0;
  for (final range in partRanges) {
    final start = range.startIndex < 0 ? 0 : range.startIndex;
    final requestedEnd = start + (range.count < 0 ? 0 : range.count);
    final end =
        requestedEnd > questionIds.length ? questionIds.length : requestedEnd;
    final questions = <MockFinaleQuestion>[];
    for (var index = start; index < end; index += 1) {
      final id = questionIds[index];
      final question = questionsById[id];
      if (question == null) continue;
      questions.add(
        MockFinaleQuestion(
          id: id,
          outcome: _finaleOutcome(question, answers[id]),
        ),
      );
    }
    retainedTotal += questions.length;
    parts.add(MockFinalePart(name: range.name, questions: questions));
  }
  if (retainedTotal == 0) return null;

  final safePartIndex = currentPartIndex < 0
      ? 0
      : currentPartIndex >= parts.length
          ? parts.length - 1
          : currentPartIndex;
  final activeRange = partRanges[safePartIndex];
  final start = activeRange.startIndex < 0 ? 0 : activeRange.startIndex;
  final requestedEnd = start + (activeRange.count < 0 ? 0 : activeRange.count);
  final end =
      requestedEnd > questionIds.length ? questionIds.length : requestedEnd;
  final cursor = end <= start
      ? start
      : currentQuestionIndex < start
          ? start
          : currentQuestionIndex >= end
              ? end - 1
              : currentQuestionIndex;
  var retainedBefore = 0;
  for (var index = start; index < cursor; index += 1) {
    if (questionsById.containsKey(questionIds[index])) retainedBefore += 1;
  }
  final currentQuestions = parts[safePartIndex].questions;
  final adjustedQuestionIndex = currentQuestions.isEmpty
      ? 0
      : retainedBefore >= currentQuestions.length
          ? currentQuestions.length - 1
          : retainedBefore;

  return MockFinaleInput(
    reason: reason,
    currentPartIndex: safePartIndex,
    currentQuestionIndex: adjustedQuestionIndex,
    parts: parts,
  );
}

MockFinaleOutcome _finaleOutcome(Question question, MockAnswer? answer) {
  if (answer == null || answer.selectedIndex < 0) {
    return MockFinaleOutcome.blank;
  }
  final correctIndex =
      question.choices.indexWhere((choice) => choice.isCorrect);
  return answer.selectedIndex == correctIndex
      ? MockFinaleOutcome.correct
      : MockFinaleOutcome.wrong;
}
