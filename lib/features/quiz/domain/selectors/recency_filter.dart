import 'package:cse_cet_reviewer/core/storage/domain/question.dart';

abstract final class RecencyFilter {
  static List<Question> noConsecutiveSameTopic(List<Question> questions) {
    final result = [...questions];
    for (var i = 1; i < result.length; i++) {
      if (result[i].topicId != result[i - 1].topicId) continue;

      final swapIndex = result.indexWhere(
        (question) => question.topicId != result[i - 1].topicId,
        i + 1,
      );
      if (swapIndex == -1) continue;
      final replacement = result[swapIndex];
      result[swapIndex] = result[i];
      result[i] = replacement;
    }
    return result;
  }
}
