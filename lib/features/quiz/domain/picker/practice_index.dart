import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';

/// One lesson inside a topic, as the picker lists it.
class PracticeLessonEntry {
  const PracticeLessonEntry({
    required this.id,
    required this.title,
    required this.isRead,
    required this.questionCount,
  });

  final LessonId id;
  final String title;

  /// Drives the only annotation on this screen. Read lessons carry nothing:
  /// most lessons end up read, so marking those marks almost everything.
  final bool isRead;

  /// How many questions carry this lesson's id. Zero everywhere until the
  /// tagging pass runs.
  final int questionCount;
}

/// One topic row.
class PracticeTopicEntry {
  const PracticeTopicEntry({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.lessons,
  });

  final TopicId id;
  final String name;

  /// Never shown. A count of 248 is inventory, not a decision, and the spec
  /// leaves the row's meta slot empty. The footer needs it to know when a pool
  /// held fewer than was asked for.
  final int questionCount;

  final List<PracticeLessonEntry> lessons;

  /// Dimmed and unselectable when false, with "no questions yet" in the meta
  /// slot. Not hidden: its lessons exist and a student who has read them will
  /// come looking.
  bool get hasQuestions => questionCount > 0;

  /// False where no question in the topic carries a lesson id, which is
  /// everywhere until the tagging pass runs. The caret is absent rather than
  /// opening onto rows that would start an empty session.
  bool get canUnfold => lessons.any((lesson) => lesson.questionCount > 0);
}

class PracticeSubjectEntry {
  const PracticeSubjectEntry({
    required this.id,
    required this.name,
    required this.topics,
  });

  final SubjectId id;
  final String name;
  final List<PracticeTopicEntry> topics;
}

class PracticeIndex {
  const PracticeIndex(this.subjects);

  static const empty = PracticeIndex([]);

  final List<PracticeSubjectEntry> subjects;

  bool get isEmpty => subjects.isEmpty;

  Iterable<PracticeTopicEntry> get allTopics =>
      subjects.expand((subject) => subject.topics);
}
