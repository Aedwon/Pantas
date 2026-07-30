import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';

class AssessmentQuestion {
  const AssessmentQuestion({
    required this.question,
    required this.topicId,
  });

  final Question question;
  final TopicId topicId;
}
