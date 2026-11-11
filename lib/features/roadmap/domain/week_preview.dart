import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_queue.dart';
import 'package:pantas/features/roadmap/domain/planning_window.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

/// Future day and week views share this exact authored lesson queue and pacing.
/// Reading a planned lesson early removes it from subsequent future plans.
abstract final class WeekPreviews {
  static List<WeekPreview> build({
    required DateTime today,
    required DateTime? reviewOnlyFrom,
    required List<TopicId> lessonTopicOrder,
    required List<RoadmapLesson> lessons,
    required Set<LessonId> scheduledToday,
    StudyDays studyDays = StudyDays.all,
    LessonQueue? lessonQueue,
  }) {
    final byId = {for (final lesson in lessons) lesson.id: lesson};
    final weeks = <DateTime, List<TopicId>>{};
    for (final entry in _plannedDays(
      today: today,
      reviewOnlyFrom: reviewOnlyFrom,
      lessonTopicOrder: lessonTopicOrder,
      lessons: lessons,
      scheduledToday: scheduledToday,
      studyDays: studyDays,
      lessonQueue: lessonQueue,
    )) {
      final day = entry.key;
      final start = DateTime(day.year, day.month, day.day - day.weekday % 7);
      final topics = weeks.putIfAbsent(start, () => []);
      for (final id in entry.value) {
        final topic = byId[id]!.topicId;
        if (!topics.contains(topic)) topics.add(topic);
      }
    }
    return [
      for (final entry in weeks.entries)
        WeekPreview(weekStart: entry.key, topicIds: entry.value),
    ];
  }

  static List<LessonId> plannedLessonsForDay({
    required DateTime today,
    required DateTime date,
    required DateTime? reviewOnlyFrom,
    required List<TopicId> lessonTopicOrder,
    required List<RoadmapLesson> lessons,
    required Set<LessonId> scheduledToday,
    StudyDays studyDays = StudyDays.all,
    LessonQueue? lessonQueue,
    LessonLinks lessonLinks = const {},
  }) {
    final target = localDay(date);
    if (!target.isAfter(localDay(today))) return const [];
    for (final entry in _plannedDays(
      today: today,
      reviewOnlyFrom: reviewOnlyFrom,
      lessonTopicOrder: lessonTopicOrder,
      lessons: lessons,
      scheduledToday: scheduledToday,
      studyDays: studyDays,
      lessonQueue: lessonQueue ??
          LessonQueue.build(
            lessonTopicOrder: lessonTopicOrder,
            lessons: lessons,
            graph: LessonGraph.build(lessonLinks, lessons.map((l) => l.id)),
          ),
    )) {
      if (entry.key == target) return entry.value;
      if (entry.key.isAfter(target)) break;
    }
    return const [];
  }

  static Iterable<MapEntry<DateTime, List<LessonId>>> _plannedDays({
    required DateTime today,
    required DateTime? reviewOnlyFrom,
    required List<TopicId> lessonTopicOrder,
    required List<RoadmapLesson> lessons,
    required Set<LessonId> scheduledToday,
    required StudyDays studyDays,
    LessonQueue? lessonQueue,
  }) sync* {
    if (reviewOnlyFrom == null) return;
    final shared = lessonQueue ??
        LessonQueue.build(
          lessonTopicOrder: lessonTopicOrder,
          lessons: lessons,
        );
    final queue = shared.lessons
        .where((lesson) => !scheduledToday.contains(lesson.id))
        .toList();
    var day = localDay(today);
    final stop = localDay(reviewOnlyFrom);
    var next = 0;
    if (queue.isEmpty) return;
    // The remaining calendar is unchanged while this preview is built.
    var daysLeft = studyDays.countInRange(
      DateTime(day.year, day.month, day.day + 1),
      stop,
    );
    while (next < queue.length) {
      day = DateTime(day.year, day.month, day.day + 1);
      if (!day.isBefore(stop)) break;
      if (!studyDays.isStudyDay(day)) continue;
      final perDay = PlanningWindows.perDay(queue.length - next, daysLeft);
      final ids = <LessonId>[];
      for (var i = 0; i < perDay && next < queue.length; i++, next++) {
        ids.add(queue[next].id);
      }
      daysLeft--;
      yield MapEntry(day, List.unmodifiable(ids));
    }
  }
}
