import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:flutter_test/flutter_test.dart';

Lesson lesson(String id, {int minutes = 10, int ordering = 0}) => Lesson(
      id: id,
      topicId: 't1',
      title: 'Lesson $id',
      summary: 'Summary',
      bodyJson: const [],
      estimatedMinutes: minutes,
      ordering: ordering,
    );

void main() {
  const exam = Exam(
    id: 'e1',
    code: 'UPCAT',
    name: 'University of the Philippines College Admission Test',
    shortName: 'UPCAT',
    language: 'en',
    isActive: true,
    subjects: [
      Subject(id: 's1', examId: 'e1', name: 'Mathematics', ordering: 1),
      Subject(id: 's2', examId: 'e1', name: 'Science', ordering: 2),
    ],
  );

  const algebra =
      Topic(id: 't1', subjectId: 's1', name: 'Algebra', ordering: 1);
  const geometry =
      Topic(id: 't2', subjectId: 's1', name: 'Geometry', ordering: 2);
  const chemistry =
      Topic(id: 't3', subjectId: 's2', name: 'Chemistry', ordering: 1);

  final topicsBySubject = {
    's1': [algebra, geometry],
    's2': [chemistry],
  };

  final lessonsByTopic = {
    't1': [lesson('l1'), lesson('l2', minutes: 20)],
    't2': [lesson('l3', minutes: 30)],
    't3': [lesson('l4', minutes: 15)],
  };

  StudyMap build({
    Set<String> read = const {},
    Set<String> bookmarked = const {},
  }) =>
      buildStudyMap(
        exam: exam,
        topicsBySubject: topicsBySubject,
        lessonsByTopic: lessonsByTopic,
        readLessonIds: read,
        bookmarkedLessonIds: bookmarked,
      );

  test('an untouched exam is zero per cent covered', () {
    final map = build();

    expect(map.readCount, 0);
    expect(map.totalCount, 4);
    expect(map.coveredPercent, 0);
  });

  test('covered is read over total, rounded', () {
    final map = build(read: {'l1'});

    // 1 of 4 is 25 exactly; 1 of 3 would be 33.
    expect(map.coveredPercent, 25);
  });

  test('minutes left counts only what is unread', () {
    final map = build(read: {'l1', 'l4'});

    // 20 + 30 remain of 75.
    expect(map.minutesLeftToRead, 50);
  });

  test('a finished exam has nothing left to read', () {
    final map = build(read: {'l1', 'l2', 'l3', 'l4'});

    expect(map.coveredPercent, 100);
    expect(map.minutesLeftToRead, 0);
  });

  test('subjects and topics keep their authored order', () {
    final map = build();

    expect(
      map.subjects.map((s) => s.name).toList(),
      ['Mathematics', 'Science'],
    );
    expect(
      map.subjects.first.topics.map((t) => t.name).toList(),
      ['Algebra', 'Geometry'],
    );
  });

  test('a topic reports its own read fraction and completion', () {
    final map = build(read: {'l1', 'l2'});
    final algebraOut = map.subjects.first.topics.first;

    expect(algebraOut.readCount, 2);
    expect(algebraOut.totalCount, 2);
    expect(algebraOut.isComplete, isTrue);
    expect(map.subjects.first.topics.last.isComplete, isFalse);
  });

  test('a topic with no lessons is never complete', () {
    final map = buildStudyMap(
      exam: exam,
      topicsBySubject: {
        's1': [algebra],
        's2': const [],
      },
      lessonsByTopic: const {'t1': []},
      readLessonIds: const {},
      bookmarkedLessonIds: const {},
    );

    expect(map.subjects.first.topics.single.isComplete, isFalse);
    expect(map.totalCount, 0);
    expect(map.coveredPercent, 0);
  });

  test('a subject reports its own read fraction', () {
    final map = build(read: {'l1'});

    expect(map.subjects.first.readCount, 1);
    expect(map.subjects.first.totalCount, 3);
  });

  test('a topic knows whether it holds a bookmark', () {
    final map = build(bookmarked: {'l3'});

    expect(map.subjects.first.topics.first.hasBookmark, isFalse);
    expect(map.subjects.first.topics.last.hasBookmark, isTrue);
  });

  test('a lesson carries what its row draws', () {
    final map = build(read: {'l1'}, bookmarked: {'l2'});
    final lessons = map.subjects.first.topics.first.lessons;

    expect(lessons.first.title, 'Lesson l1');
    expect(lessons.first.isRead, isTrue);
    expect(lessons.first.estimatedMinutes, 10);
    expect(lessons.last.isRead, isFalse);
    expect(lessons.last.isBookmarked, isTrue);
  });

  test('a topic the exam does not list contributes nothing', () {
    final map = buildStudyMap(
      exam: exam,
      topicsBySubject: topicsBySubject,
      lessonsByTopic: {
        ...lessonsByTopic,
        't9': [lesson('l9', minutes: 99)],
      },
      readLessonIds: const {},
      bookmarkedLessonIds: const {},
    );

    expect(map.totalCount, 4);
    expect(map.minutesLeftToRead, 75);
  });
}
