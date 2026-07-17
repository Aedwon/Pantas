import 'dart:math' as math;

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/assessment_question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';

import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';

class AssessmentQuestionSelector {
  AssessmentQuestionSelector(this._content, this._reviewRepo);

  static const _maxQuestions = 35;

  final ContentRepository _content;
  final ReviewStateRepository _reviewRepo;

  Future<List<AssessmentQuestion>> select(
    ExamId examId, {
    List<Topic>? topics,
  }) async {
    final topicList = topics ?? await _content.topicsByExam(examId);
    if (topicList.isEmpty) return [];

    final contributing = <({TopicId topicId, List<Question> questions})>[];
    for (final topic in topicList) {
      final questions = await _content.questionsByTopic(topic.id);
      if (questions.isNotEmpty) {
        contributing.add((topicId: topic.id, questions: questions));
      }
    }
    if (contributing.isEmpty) return [];

    final questionsPerTopic =
        math.max(1, math.min(3, _maxQuestions ~/ contributing.length));
    final buckets = <List<AssessmentQuestion>>[];

    for (final topic in contributing) {
      final scored = <(double, Question)>[];
      for (final q in topic.questions) {
        final rs = await _reviewRepo.byQuestionId(q.id);
        final score = (rs == null || rs.stage == ReviewStage.newCard)
            ? 0.0
            : rs.stability;
        scored.add((score, q));
      }
      scored.sort((a, b) => a.$1.compareTo(b.$1));

      final picked = scored
          .take(questionsPerTopic)
          .map(
            (s) => AssessmentQuestion(question: s.$2, topicId: topic.topicId),
          )
          .toList();
      if (picked.isNotEmpty) buckets.add(picked);
    }

    final result = <AssessmentQuestion>[];
    final maxLen = buckets.fold(0, (m, b) => math.max(m, b.length));
    for (var i = 0; i < maxLen; i++) {
      for (final bucket in buckets) {
        if (i < bucket.length) result.add(bucket[i]);
      }
    }
    return result.take(_maxQuestions).toList();
  }
}
