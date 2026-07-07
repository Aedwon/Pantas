import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';

/// One lesson as a row on the map.
class StudyLesson {
  const StudyLesson({
    required this.id,
    required this.title,
    required this.estimatedMinutes,
    required this.isRead,
    required this.isBookmarked,
  });

  final LessonId id;
  final String title;
  final int estimatedMinutes;
  final bool isRead;
  final bool isBookmarked;
}

/// One topic row, and the lessons it reveals when it opens.
class StudyTopic {
  const StudyTopic({
    required this.id,
    required this.name,
    required this.lessons,
    required this.readCount,
    required this.hasBookmark,
  });

  final TopicId id;
  final String name;
  final List<StudyLesson> lessons;
  final int readCount;
  final bool hasBookmark;

  int get totalCount => lessons.length;

  /// A topic with no lessons is not finished, it is unauthored. Treating it as
  /// complete would put a board tick against content nobody has written.
  bool get isComplete => totalCount > 0 && readCount == totalCount;
}

/// One subject heading and its topics.
class StudySubject {
  const StudySubject({
    required this.id,
    required this.name,
    required this.topics,
  });

  final SubjectId id;
  final String name;
  final List<StudyTopic> topics;

  int get readCount =>
      topics.fold(0, (running, topic) => running + topic.readCount);

  int get totalCount =>
      topics.fold(0, (running, topic) => running + topic.totalCount);
}

/// The whole screen, computed.
class StudyMap {
  const StudyMap({
    required this.examShortName,
    required this.subjects,
    required this.readCount,
    required this.totalCount,
    required this.minutesLeftToRead,
  });

  final String examShortName;
  final List<StudySubject> subjects;
  final int readCount;
  final int totalCount;

  /// The sum of authored `estimatedMinutes` over unread lessons. This is a
  /// property of the material and never of the student: nothing records how
  /// long anyone read.
  final int minutesLeftToRead;

  /// Read lessons over total, rounded. Zero when the exam has no lessons,
  /// rather than a division by zero.
  int get coveredPercent =>
      totalCount == 0 ? 0 : (readCount / totalCount * 100).round();

  bool get isEmpty => totalCount == 0;
}
