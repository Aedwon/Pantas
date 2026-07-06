import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';

class AssessmentQuestion {
  const AssessmentQuestion({
    required this.question,
    required this.topicId,
  });

  final Question question;
  final TopicId topicId;
}
