import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';

class RetakePicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    final byId = {
      for (final question in context.allQuestions) question.id: question,
    };
    final picked = <Question>[];
    final used = <String>{};
    for (final id in context.retakeQuestionIds) {
      final question = byId[id];
      if (question == null || !used.add(id)) continue;
      picked.add(question);
      if (picked.length >= context.requestedLength) break;
    }
    return picked;
  }
}
