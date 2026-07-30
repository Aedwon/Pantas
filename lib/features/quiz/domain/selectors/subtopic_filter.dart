import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';

class SubtopicQuestion {
  const SubtopicQuestion({required this.question, required this.subtopicId});

  final Question question;
  final SubtopicId? subtopicId;
}

abstract final class SubtopicFilter {
  static List<Question> select({
    required List<SubtopicQuestion> candidates,
    required SubtopicId subtopicId,
  }) {
    return [
      for (final candidate in candidates)
        if (candidate.subtopicId == subtopicId) candidate.question,
    ];
  }

  static List<Question> general(List<SubtopicQuestion> candidates) {
    return [
      for (final candidate in candidates)
        if (candidate.subtopicId == null) candidate.question,
    ];
  }
}
