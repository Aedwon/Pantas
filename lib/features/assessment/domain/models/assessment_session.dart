import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/assessment/domain/models/assessment_question.dart';

class AssessmentSession {
  const AssessmentSession({
    required this.examId,
    required this.questions,
    required this.answers,
  });

  final ExamId examId;
  final List<AssessmentQuestion> questions;

  /// questionId → chosen choiceId; null means unanswered
  final Map<String, String?> answers;

  AssessmentSession copyWithAnswer({
    required String questionId,
    required String chosenChoiceId,
  }) {
    return AssessmentSession(
      examId: examId,
      questions: questions,
      answers: Map.of(answers)..[questionId] = chosenChoiceId,
    );
  }
}
