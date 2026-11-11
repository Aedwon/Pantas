import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/assessment/domain/models/assessment_question.dart';

class AssessmentSession {
  const AssessmentSession({
    required this.examId,
    required this.questions,
    required this.answers,
    this.startedAt,
    this.attemptId,
    this.responseMs = const {},
  });

  final ExamId examId;
  final DateTime? startedAt;
  final String? attemptId;
  final Map<String, int> responseMs;
  final List<AssessmentQuestion> questions;

  /// questionId → chosen choiceId; null means unanswered
  final Map<String, String?> answers;

  AssessmentSession copyWithAnswer({
    required String questionId,
    required String chosenChoiceId,
    int? elapsedMs,
  }) {
    return AssessmentSession(
      examId: examId,
      startedAt: startedAt,
      attemptId: attemptId,
      responseMs: {...responseMs, if (elapsedMs != null) questionId: elapsedMs},
      questions: questions,
      answers: Map.of(answers)..[questionId] = chosenChoiceId,
    );
  }
}
