import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';

abstract final class NewCardSelector {
  static List<Question> select({
    required List<Question> questions,
    required Set<QuestionId> seenQuestionIds,
    required int capRemaining,
    required int limit,
    TopicId? topicId,
  }) {
    if (capRemaining <= 0 || limit <= 0) return const [];
    final effectiveLimit = capRemaining < limit ? capRemaining : limit;
    return questions
        .where((question) => !seenQuestionIds.contains(question.id))
        .where((question) => topicId == null || question.topicId == topicId)
        .take(effectiveLimit)
        .toList();
  }
}
