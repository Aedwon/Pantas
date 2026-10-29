import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_queue.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/week_preview.dart';

void main() {
  final today = DateTime(2026, 9, 30);
  final stop = DateTime(2026, 10, 5);
  final lessons = [
    for (var i = 0; i < 10; i++)
      RoadmapLesson(id: 'l$i', topicId: 't', ordering: i),
  ];
  List<String> planned(DateTime date, {StudyDays studyDays = StudyDays.all}) =>
      WeekPreviews.plannedLessonsForDay(
        today: today,
        date: date,
        reviewOnlyFrom: stop,
        lessonTopicOrder: ['t'],
        lessons: lessons,
        scheduledToday: {'l0'},
        studyDays: studyDays,
      );
  test('future lesson membership uses the existing pacing queue', () {
    expect(planned(DateTime(2026, 10)), ['l1', 'l2', 'l3']);
    expect(planned(DateTime(2026, 10, 2)), ['l4', 'l5']);
    expect(planned(DateTime(2026, 10, 3)), ['l6', 'l7']);
    expect(planned(DateTime(2026, 10, 4)), ['l8', 'l9']);
  });
  test('past, today, stop date and rest weekdays have no future lesson plan',
      () {
    for (final date in [DateTime(2026, 9, 29), today, stop]) {
      expect(planned(date), isEmpty);
    }
    expect(
      planned(
        DateTime(2026, 10),
        studyDays: StudyDays(const [DateTime.friday]),
      ),
      isEmpty,
    );
    expect(
      planned(
        DateTime(2026, 10, 2),
        studyDays: StudyDays(const [DateTime.friday]),
      ),
      [for (var i = 1; i < 10; i++) 'l$i'],
    );
  });
  test('future weeks run Sunday to Saturday and agree with the daily query',
      () {
    final weeks = WeekPreviews.build(
      today: today,
      reviewOnlyFrom: stop,
      lessonTopicOrder: ['t'],
      lessons: lessons,
      scheduledToday: {'l0'},
    );
    expect(
      weeks.map((w) => w.weekStart),
      [DateTime(2026, 9, 27), DateTime(2026, 10, 4)],
    );
    expect(weeks.every((w) => w.weekStart.weekday == DateTime.sunday), isTrue);
    expect(weeks.every((w) => w.topicIds.single == 't'), isTrue);
  });
  test('future day rebuilds the prerequisite queue used by the week', () {
    const linkedLessons = [
      RoadmapLesson(id: 'a', topicId: 't', ordering: 0),
      RoadmapLesson(id: 'b', topicId: 'u', ordering: 0),
      RoadmapLesson(id: 'c', topicId: 'u', ordering: 1),
    ];
    const links = {
      'a': [LessonLink(lessonId: 'c', strength: LinkStrength.required)],
    };
    final queue = LessonQueue.build(
      lessonTopicOrder: ['t', 'u'],
      lessons: linkedLessons,
      graph: LessonGraph.build(links, linkedLessons.map((l) => l.id)),
    );
    final date = DateTime(2026, 10);
    final ids = WeekPreviews.plannedLessonsForDay(
      today: today,
      date: date,
      reviewOnlyFrom: stop,
      lessonTopicOrder: ['t', 'u'],
      lessons: linkedLessons,
      scheduledToday: {},
      lessonLinks: links,
    );
    expect(ids, ['c']);
    expect(
      ids,
      WeekPreviews.plannedLessonsForDay(
        today: today,
        date: date,
        reviewOnlyFrom: stop,
        lessonTopicOrder: ['t', 'u'],
        lessons: linkedLessons,
        scheduledToday: {},
        lessonQueue: queue,
      ),
    );
    final weeks = WeekPreviews.build(
      today: today,
      reviewOnlyFrom: stop,
      lessonTopicOrder: ['t', 'u'],
      lessons: linkedLessons,
      scheduledToday: {},
      lessonQueue: queue,
    );
    expect(weeks.first.topicIds, ['u', 't']);
  });
  test('missing review boundary does not invent future lessons', () {
    expect(
      WeekPreviews.plannedLessonsForDay(
        today: today,
        date: DateTime(2026, 10),
        reviewOnlyFrom: null,
        lessonTopicOrder: ['t'],
        lessons: lessons,
        scheduledToday: {'l0'},
      ),
      isEmpty,
    );
  });
}
