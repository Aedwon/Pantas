import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/features/assessment/domain/models/assessment_session.dart';
import 'package:pantas/features/assessment/domain/services/assessment_question_selector.dart';

class NoAssessmentQuestionsError extends StateError {
  NoAssessmentQuestionsError(ExamId examId)
      : super('No questions available for assessment of exam $examId');
}

class StartAssessment {
  StartAssessment(this._selector);

  final AssessmentQuestionSelector _selector;

  Future<AssessmentSession> call(ExamId examId, {List<Topic>? topics}) async {
    final questions = await _selector.select(examId, topics: topics);
    if (questions.isEmpty) {
      throw NoAssessmentQuestionsError(examId);
    }
    return AssessmentSession(
      examId: examId,
      questions: questions,
      answers: {for (final q in questions) q.question.id: null},
    );
  }
}
