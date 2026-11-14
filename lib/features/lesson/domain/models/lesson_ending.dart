import 'package:pantas/features/lesson/domain/models/study_map.dart';

sealed class LessonEnding {
  const LessonEnding();
}

final class TopicFinished extends LessonEnding {
  const TopicFinished({
    required this.studentName,
    required this.topicName,
    required this.examAndSubject,
    required this.footing,
    required this.dateLine,
    required this.next,
  });

  final String? studentName;
  final String topicName;
  final String examAndSubject;
  final String footing;
  final String dateLine;
  final StudyTopic? next;
}

final class TopicStoppedShort extends LessonEnding {
  const TopicStoppedShort({
    required this.studentName,
    required this.topicName,
    required this.examAndSubject,
    required this.footing,
    required this.dateLine,
    required this.unread,
  });

  final String? studentName;
  final String topicName;
  final String examAndSubject;
  final String footing;
  final String dateLine;
  final List<StudyLesson> unread;
}

final class DayFinished extends LessonEnding {
  const DayFinished();
}
