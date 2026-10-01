import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/planning_window.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

/// Which topics come in which week if the student follows the plan. Topic
/// ids only: a count for a later week would be a projection, and the app
/// never prints one (spec, Part 1 Section 2).
abstract final class WeekPreviews {
  static List<WeekPreview> build({
    required DateTime today,
    required DateTime? reviewOnlyFrom,
    required List<TopicId> lessonTopicOrder,
    required List<RoadmapLesson> lessons,
    required Set<LessonId> scheduledToday,
    StudyDays studyDays = StudyDays.all,
  }) {
    if (reviewOnlyFrom == null) return const [];
    final byTopic = <TopicId, List<RoadmapLesson>>{};
    for (final lesson in lessons) {
      if (lesson.readAt != null || scheduledToday.contains(lesson.id)) {
        continue;
      }
      (byTopic[lesson.topicId] ??= []).add(lesson);
    }
    for (final list in byTopic.values) {
      list.sort((a, b) {
        final c = a.ordering.compareTo(b.ordering);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    }
    final queue = [
      for (final topicId in lessonTopicOrder) ...?byTopic[topicId],
    ];

    final weeks = <DateTime, List<TopicId>>{};
    var day = localDay(today);
    final stop = localDay(reviewOnlyFrom);
    var next = 0;
    while (next < queue.length) {
      day = DateTime(day.year, day.month, day.day + 1);
      if (!day.isBefore(stop)) break;
      if (!studyDays.isStudyDay(day)) continue;
      final daysLeft = studyDays.countInRange(day, stop);
      final perDay = PlanningWindows.perDay(queue.length - next, daysLeft);
      final weekStart =
          DateTime(day.year, day.month, day.day - (day.weekday - 1));
      final topics = weeks.putIfAbsent(weekStart, () => []);
      for (var i = 0; i < perDay && next < queue.length; i++, next++) {
        final topicId = queue[next].topicId;
        if (!topics.contains(topicId)) topics.add(topicId);
      }
    }
    return [
      for (final entry in weeks.entries)
        if (entry.value.isNotEmpty)
          WeekPreview(weekStart: entry.key, topicIds: entry.value),
    ];
  }
}
