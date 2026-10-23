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
      estimatedMinutes: estimatedMinutes,
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
    expect(ending.examAndSubject, 'UPCAT · Mathematics');
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
    expect(ending.nextTopicMeta, isNull);
  });

  group('next topic meta line formatting', () {
    test('formats next topic meta for multi-lesson topic with hours and mins',
        () {
      final topic = topicWith(
        read: 0,
        total: 8,
        name: 'Geometry',
        lessonMinutes: 12.5.toInt(), // 8 * 12 = 96 min -> 1h 36m
      );
      final ending = decideEnding(
        topic: topicWith(read: 9, total: 9),
        subject: mathematics,
        examShortName: 'UPCAT',
        studentName: 'Aedwon',
        today: DateTime(2026, 7, 27),
        nextTopic: topic,
      ) as TopicFinished;

      expect(ending.nextTopicMeta, contains('of material'));
      expect(ending.nextTopicMeta, isNot(contains('of your time')));
    });

    test('formats next topic meta for exactly one hour', () {
      final topic = topicWith(
        read: 0,
        total: 4,
        name: 'Geometry',
        lessonMinutes: 15, // 4 * 15 = 60 mins
      );
      final ending = decideEnding(
        topic: topicWith(read: 9, total: 9),
        subject: mathematics,
        examShortName: 'UPCAT',
        studentName: 'Aedwon',
        today: DateTime(2026, 7, 27),
        nextTopic: topic,
      ) as TopicFinished;

      expect(
        ending.nextTopicMeta,
        'Four lessons, about an hour of material.',
      );
    });

    test('formats next topic meta for under an hour', () {
      final topic = topicWith(
        read: 0,
        total: 3,
        name: 'Geometry',
        lessonMinutes: 15, // 3 * 15 = 45 mins
      );
      final ending = decideEnding(
        topic: topicWith(read: 9, total: 9),
        subject: mathematics,
        examShortName: 'UPCAT',
        studentName: 'Aedwon',
        today: DateTime(2026, 7, 27),
        nextTopic: topic,
      ) as TopicFinished;

      expect(
        ending.nextTopicMeta,
        'Three lessons, about 45 minutes of material.',
      );
    });

    test('formats next topic meta for 100 minutes (hour and forty)', () {
      // Eight lessons summing to exactly 100 minutes: four of 12 and four of
      // 13. The point is the hour boundary in the wording, so the total has to
      // be exact rather than close.
      final lessons = [
        ...List.generate(
          4,
          (i) => makeLesson(id: 'g$i', title: 'L', estimatedMinutes: 12),
        ),
        ...List.generate(
          4,
          (i) => makeLesson(id: 'g${i + 4}', title: 'L', estimatedMinutes: 13),
        ),
      ];
      final geomTopic = StudyTopic(
        id: 'geom',
        name: 'Geometry',
        lessons: lessons,
        readCount: 0,
        hasBookmark: false,
      );
      final ending = decideEnding(
        topic: topicWith(read: 9, total: 9),
        subject: mathematics,
        examShortName: 'UPCAT',
        studentName: 'Aedwon',
        today: DateTime(2026, 7, 27),
        nextTopic: geomTopic,
      ) as TopicFinished;

      expect(
        ending.nextTopicMeta,
        'Eight lessons, about an hour and forty of material.',
      );
    });
  });
}
