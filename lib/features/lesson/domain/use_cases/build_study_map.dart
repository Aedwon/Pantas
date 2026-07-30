import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

export 'package:pantas/features/lesson/domain/models/study_map.dart';

/// Turns the exam's tree and the read set into everything the map draws.
///
/// The exam is the authority on which subjects exist and which topics belong
/// to them: a topic in [lessonsByTopic] that no subject lists is ignored
/// rather than counted, so a stale row in the database cannot move a figure.
StudyMap buildStudyMap({
  required Exam exam,
  required Map<SubjectId, List<Topic>> topicsBySubject,
  required Map<TopicId, List<Lesson>> lessonsByTopic,
  required Set<LessonId> readLessonIds,
  required Set<LessonId> bookmarkedLessonIds,
  List<Subject>? subjects,
}) {
  final subjectList = subjects ?? exam.subjects;
  final studySubjects = <StudySubject>[];
  var readCount = 0;
  var totalCount = 0;
  var minutesLeft = 0;

  for (final subject in subjectList) {
    final topics = <StudyTopic>[];

    for (final topic in topicsBySubject[subject.id] ?? const <Topic>[]) {
      final lessons = lessonsByTopic[topic.id] ?? const <Lesson>[];
      var topicRead = 0;
      var hasBookmark = false;
      final rows = <StudyLesson>[];

      for (final lesson in lessons) {
        final isRead = readLessonIds.contains(lesson.id);
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
