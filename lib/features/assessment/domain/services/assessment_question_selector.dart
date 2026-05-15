import 'dart:math' as math;

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_question.dart';

class AssessmentQuestionSelector {
  AssessmentQuestionSelector(this._content, this._reviewRepo);

  final ContentRepository _content;
  final ReviewStateRepository _reviewRepo;

  Future<List<AssessmentQuestion>> select(ExamId examId) async {
    final topics = await _content.topicsByExam(examId);
    if (topics.isEmpty) return [];

    final questionsPerTopic = math.max(1, math.min(3, 35 ~/ topics.length));
    final buckets = <List<AssessmentQuestion>>[];

    for (final topic in topics) {
      final questions = await _content.questionsByTopic(topic.id);
      if (questions.isEmpty) continue;

      final scored = <(double, Question)>[];
      for (final q in questions) {
        final rs = await _reviewRepo.byQuestionId(q.id);
        final score = (rs == null || rs.stage == ReviewStage.newCard)
            ? 0.0
            : rs.stability;
        scored.add((score, q));
      }
      scored.sort((a, b) => a.$1.compareTo(b.$1));

      final picked = scored
          .take(questionsPerTopic)
          .map((s) => AssessmentQuestion(question: s.$2, topicId: topic.id))
          .toList();
      if (picked.isNotEmpty) buckets.add(picked);
    }

    // Round-robin interleave across topic buckets
    final result = <AssessmentQuestion>[];
    final maxLen = buckets.fold(0, (m, b) => math.max(m, b.length));
    for (var i = 0; i < maxLen; i++) {
      for (final bucket in buckets) {
        if (i < bucket.length) result.add(bucket[i]);
      }
    }
    return result;
  }
}
