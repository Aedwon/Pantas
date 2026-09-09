import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/picker/today_topic_picker.dart';
import 'package:pantas/features/quiz/domain/selectors/recency_filter.dart';

class TodayFullyMixedPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    final candidate = TodayTopicPicker().pick(
      PickContext(
        allQuestions:
            RecencyFilter.noConsecutiveSameTopic(context.allQuestions),
        dueQuestions:
            RecencyFilter.noConsecutiveSameTopic(context.dueQuestions),
        weaknessQuestions:
            RecencyFilter.noConsecutiveSameTopic(context.weaknessQuestions),
        newQuestions:
            RecencyFilter.noConsecutiveSameTopic(context.newQuestions),
        requestedLength: context.requestedLength,
      ),
    );
    return _withoutAdjacentTopics(candidate);
  }
}

List<Question> _withoutAdjacentTopics(List<Question> questions) {
  final remaining = [...questions];
  final result = <Question>[];
  while (remaining.isNotEmpty) {
    final index = result.isEmpty
        ? 0
        : remaining.indexWhere(
            (question) => question.topicId != result.last.topicId,
          );
    if (index < 0) break;
    result.add(remaining.removeAt(index));
  }
  return result;
}
