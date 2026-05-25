import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/selectors/subtopic_filter.dart';

class DrillPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    final questions = context.subtopicId == null
        ? SubtopicFilter.general(context.subtopicCandidates)
        : SubtopicFilter.select(
            candidates: context.subtopicCandidates,
            subtopicId: context.subtopicId!,
          );
    return questions.take(context.requestedLength).toList();
  }
}
