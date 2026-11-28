import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/use_cases/decide_ending.dart';

void main() {
  StudyLesson makeLesson({
    required String id,
    required String title,
    int estimatedMinutes = 10,
    bool isRead = true,
  }) {
    return StudyLesson(
      id: id,
      title: title,
      isRead: isRead,
      isBookmarked: false,
    );
  }

  StudyTopic topicWith({
    required int read,
    required int total,
    String name = 'Arithmetic & Number Sense',
    int lessonMinutes = 10,
  }) {
    final lessons = List.generate(
      total,
      (i) => makeLesson(
        id: 'l${i + 1}',
        title: 'Lesson ${i + 1}',
        estimatedMinutes: lessonMinutes,
        isRead: i < read,
      ),
    );
    return StudyTopic(
      id: 't1',
      name: name,
      lessons: lessons,
      readCount: read,
      hasBookmark: false,
    );
  }

  const mathematics = StudySubject(
    id: 'math',
    name: 'Mathematics',
    topics: [],
  );

  final geometry = topicWith(
    read: 0,
    total: 8,
    name: 'Geometry',
    lessonMinutes:
        12, // 8 * 12 = 96 mins = 1h 36m -> about an hour and thirty-six
  );

  test('every lesson read is a finished topic', () {
    final ending = decideEnding(
      topic: topicWith(read: 9, total: 9),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: geometry,
    );

    expect(ending, isA<TopicFinished>());
    expect((ending as TopicFinished).footing, '9 lessons, all read');
  });

  test('one unread lesson is singular', () {
    final ending = decideEnding(
      topic: topicWith(read: 0, total: 1),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: null,
      today: DateTime(2026, 7, 27),
      nextTopic: null,
    ) as TopicStoppedShort;
    expect(ending.footing, '0 of 1 lesson read');
  });

  test('one lesson is singular', () {
    final ending = decideEnding(
      topic: topicWith(read: 1, total: 1),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: geometry,
    );

    expect((ending as TopicFinished).footing, '1 lesson, all read');
  });

  test('lessons left behind is a topic stopped short', () {
    final ending = decideEnding(
      topic: topicWith(read: 6, total: 9),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: geometry,
    );

    expect(ending, isA<TopicStoppedShort>());
    expect((ending as TopicStoppedShort).footing, '6 of 9 lessons read');
    expect(ending.unread, hasLength(3));
  });

  test('the plate carries the name, the topic, the exam and the subject', () {
    final ending = decideEnding(
      topic: topicWith(read: 9, total: 9),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: geometry,
    ) as TopicFinished;

    expect(ending.studentName, 'Aedwon');
    expect(ending.topicName, 'Arithmetic & Number Sense');
    expect(ending.examAndSubject, 'UPCAT: Mathematics');
  });

  test('a skipped name leaves the line absent rather than empty', () {
    final ending = decideEnding(
      topic: topicWith(read: 9, total: 9),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: null,
      today: DateTime(2026, 7, 27),
      nextTopic: geometry,
    ) as TopicFinished;

    expect(ending.studentName, isNull);
  });

  test('the date is written out, not a machine format', () {
    final ending = decideEnding(
      topic: topicWith(read: 9, total: 9),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: geometry,
    ) as TopicFinished;

    expect(ending.dateLine, 'Jul 27, 2026');
  });

  test('no next topic is allowed, and says so', () {
    final ending = decideEnding(
      topic: topicWith(read: 9, total: 9),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: null,
    ) as TopicFinished;

    expect(ending.next, isNull);
  });
}
