import 'package:pantas/core/metrics/overall_accuracy.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';

typedef ExamSubjectGroup = ({String id, String name, List<Topic> topics});

/// Groups scoped content for display without changing stored relationships.
List<ExamSubjectGroup> examSubjectGroups({
  required String examId,
  required List<Subject> subjects,
  required List<Topic> topics,
}) {
  final parts = csePartsForExam(examId);
  if (parts.isEmpty) {
    return [
      for (final subject in subjects)
        (
          id: subject.id,
          name: subject.name,
          topics: topics.where((t) => t.subjectId == subject.id).toList(),
        ),
    ];
  }
  // A part with nothing to show for this student is left out, as an empty
  // subject is. A topic is known by its name or by its id.
  return [
    for (final part in parts)
      if (_topicsOf(part, topics) case final partTopics
          when partTopics.isNotEmpty)
        (id: part.key, name: part.name, topics: partTopics),
  ];
}

List<Topic> _topicsOf(CseExamPart part, List<Topic> topics) {
  int order(Topic topic) {
    final index = part.topicNames.indexOf(topic.name);
    return index < 0 ? part.topicNames.length : index;
  }

  return [
    for (final topic in topics)
      if (part.topicNames.contains(topic.name) ||
          part.topicIds.contains(topic.id))
        topic,
  ]..sort((a, b) => order(a).compareTo(order(b)));
}
