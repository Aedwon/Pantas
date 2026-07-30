import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/review_state.dart';

abstract final class FsrsDueSelector {
  static List<Question> select({
    required List<ReviewState> states,
    required Map<QuestionId, Question> questionsById,
    required DateTime now,
    TopicId? topicId,
    int? limit,
  }) {
    final dueStates = states.where((state) {
      final question = questionsById[state.questionId];
      if (question == null) return false;
      if (topicId != null && question.topicId != topicId) return false;
      return !state.due.isAfter(now);
    }).toList()
      ..sort((a, b) {
        final dueOrder = a.due.compareTo(b.due);
        if (dueOrder != 0) return dueOrder;
        return b.lapses.compareTo(a.lapses);
      });

    final questions = [
      for (final state in dueStates) questionsById[state.questionId]!,
    ];
    return limit == null ? questions : questions.take(limit).toList();
  }
}
