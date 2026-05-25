import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/drill_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';

class InlineLessonPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    return DrillPicker()
        .pick(
          PickContext(
            allQuestions: context.allQuestions,
            subtopicCandidates: context.subtopicCandidates,
            requestedLength: 5,
            subtopicId: context.subtopicId,
          ),
        )
        .take(5)
        .toList();
  }
}
