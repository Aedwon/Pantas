import 'package:pantas/core/content/exam_subject_groups.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/domain/lesson_credit.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

export 'package:pantas/features/lesson/domain/models/study_map.dart';

/// Turns the exam's tree and the read set into everything the map draws.
///
/// The exam's scoped tree decides which topics exist. CSE groups those topics
/// into its exam parts. A topic in [lessonsByTopic] that the tree does not list
/// contributes nothing to the figures.
StudyMap buildStudyMap({
  required Exam exam,
  required Map<SubjectId, List<Topic>> topicsBySubject,
  required Map<TopicId, List<Lesson>> lessonsByTopic,
  required Set<LessonId> readLessonIds,
  required Set<LessonId> bookmarkedLessonIds,
  List<Subject>? subjects,
}) {
  final credit = resolveLessonCredit<bool>(
    retiredReplacements: {
      for (final lessons in lessonsByTopic.values)
        for (final lesson in lessons)
          if (lesson.status == 'retired') lesson.id: lesson.replacedBy ?? [],
    },
    own: {for (final id in readLessonIds) id: true},
    compare: (a, b) => 0,
  );
  final subjectList = examSubjectGroups(
    examId: exam.id,
    subjects: subjects ?? exam.subjects,
    topics: [
      for (final subject in subjects ?? exam.subjects)
        ...topicsBySubject[subject.id] ?? const <Topic>[],
    ],
  );
  final studySubjects = <StudySubject>[];
  var readCount = 0;
  var totalCount = 0;
  var minutesLeft = 0;

  for (final subject in subjectList) {
    final topics = <StudyTopic>[];

    for (final topic in subject.topics) {
      final lessons = lessonsByTopic[topic.id] ?? const <Lesson>[];
      if (lessons.isEmpty) continue;
      var topicRead = 0;
      var hasBookmark = false;
      final rows = <StudyLesson>[];

      for (final lesson in lessons.where((l) => l.status != 'retired')) {
        final isRead = credit.containsKey(lesson.id);
        final isBookmarked = bookmarkedLessonIds.contains(lesson.id);
        if (isRead) {
          topicRead++;
        } else {
          minutesLeft += lesson.estimatedMinutes;
        }
        hasBookmark = hasBookmark || isBookmarked;

        rows.add(
          StudyLesson(
            id: lesson.id,
            title: lesson.title,
            estimatedMinutes: lesson.estimatedMinutes,
            isRead: isRead,
            isBookmarked: isBookmarked,
          ),
        );
      }

      readCount += topicRead;
      totalCount += rows.length;

      topics.add(
        StudyTopic(
          id: topic.id,
          name: topic.name,
          lessons: rows,
          readCount: topicRead,
          hasBookmark: hasBookmark,
        ),
      );
    }

    if (topics.isEmpty) continue;
    studySubjects.add(
      StudySubject(id: subject.id, name: subject.name, topics: topics),
    );
  }

  return StudyMap(
    examShortName: exam.shortName,
    subjects: studySubjects,
    readCount: readCount,
    totalCount: totalCount,
    minutesLeftToRead: minutesLeft,
  );
}
