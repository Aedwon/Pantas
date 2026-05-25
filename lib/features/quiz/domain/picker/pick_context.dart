import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/selectors/subtopic_filter.dart';

class PickContext {
  const PickContext({
    required this.allQuestions,
    required this.requestedLength,
    this.dueQuestions = const [],
    this.weaknessQuestions = const [],
    this.newQuestions = const [],
    this.subtopicCandidates = const [],
    this.retakeQuestionIds = const [],
    this.topicId,
    this.subtopicId,
  });

  final List<Question> allQuestions;
  final List<Question> dueQuestions;
  final List<Question> weaknessQuestions;
  final List<Question> newQuestions;
  final List<SubtopicQuestion> subtopicCandidates;
  final List<QuestionId> retakeQuestionIds;
  final int requestedLength;
  final TopicId? topicId;
  final SubtopicId? subtopicId;
}
