import 'dart:math' as math;

import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/assessment_question.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question_selection_row.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/core/storage/domain/topic.dart';

class AssessmentQuestionSelector {
  AssessmentQuestionSelector(this._content, this._reviewRepo);

  static const _maxQuestions = 30;

  final ContentRepository _content;
  final ReviewStateRepository _reviewRepo;

  Future<List<AssessmentQuestion>> select(
    ExamId examId, {
    List<Topic>? topics,
  }) async {
    final topicList = topics ?? await _content.topicsByExam(examId);
    if (topicList.isEmpty) return [];

    final rowsByTopic = await _content.selectionRowsByTopics(
      [for (final topic in topicList) topic.id],
    );
    final contributing =
        <({TopicId topicId, List<QuestionSelectionRow> questions})>[];
    for (final topic in topicList) {
      final questions = rowsByTopic[topic.id] ?? const <QuestionSelectionRow>[];
      if (questions.isNotEmpty) {
        contributing.add((topicId: topic.id, questions: questions));
      }
    }
    if (contributing.isEmpty) return [];

    final questionsPerTopic =
        math.max(1, math.min(3, _maxQuestions ~/ contributing.length));
    final reviewStates = await _reviewRepo.byQuestionIds([
      for (final topic in contributing)
        for (final question in topic.questions) question.id,
    ]);
    final buckets = <List<QuestionSelectionRow>>[];

    for (final topic in contributing) {
      final scored = <(double, QuestionSelectionRow)>[];
      for (final question in topic.questions) {
        final state = reviewStates[question.id];
        final score = (state == null || state.stage == ReviewStage.newCard)
            ? 0.0
            : state.stability;
        scored.add((score, question));
      }
      scored.sort((a, b) => a.$1.compareTo(b.$1));

      final picked = scored.take(questionsPerTopic).map((s) => s.$2).toList();
      if (picked.isNotEmpty) buckets.add(picked);
    }

    final selected = <QuestionSelectionRow>[];
    final maxLen = buckets.fold(0, (m, b) => math.max(m, b.length));
    for (var i = 0; i < maxLen; i++) {
      for (final bucket in buckets) {
        if (i < bucket.length) selected.add(bucket[i]);
      }
    }
    final capped = selected.take(_maxQuestions).toList();
    final hydrated = await _content.hydrateSelectedQuestions(
      [for (final row in capped) row.id],
    );
    final byId = {for (final question in hydrated) question.id: question};

    return [
      for (final row in capped)
        if (byId[row.id] case final question?)
          AssessmentQuestion(question: question, topicId: row.topicId),
    ];
  }
}
