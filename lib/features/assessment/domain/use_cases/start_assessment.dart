import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_session.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart';

class StartAssessment {
  StartAssessment(this._selector);

  final AssessmentQuestionSelector _selector;

  Future<AssessmentSession> call(ExamId examId) async {
    final questions = await _selector.select(examId);
    if (questions.isEmpty) {
      throw StateError(
        'No questions available for assessment of exam $examId',
      );
    }
    return AssessmentSession(
      examId: examId,
      questions: questions,
      answers: {for (final q in questions) q.question.id: null},
    );
  }
}
