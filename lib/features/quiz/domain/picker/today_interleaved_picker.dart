import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/picker/today_topic_picker.dart';
import 'package:pantas/features/quiz/domain/selectors/recency_filter.dart';

class TodayInterleavedPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    return RecencyFilter.noConsecutiveSameTopic(
      _composeForInterleaved(context),
    );
  }
}

List<Question> _composeForInterleaved(PickContext context) {
  return TodayTopicPicker().pick(
    PickContext(
      allQuestions: context.allQuestions,
      dueQuestions: context.dueQuestions,
      weaknessQuestions: context.weaknessQuestions,
      newQuestions: context.newQuestions,
      requestedLength: context.requestedLength,
    ),
  );
}
