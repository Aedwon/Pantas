import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';

/// Adapts the public server membership for existing Today presentation and
/// launchers. This digest is never persisted or passed to the local planner.
RoadmapToday serverToday(
  StudyRoadmap value, {
  required String examDate,
  StudyDays studyDays = StudyDays.all,
}) =>
    RoadmapToday(
      snapshot: DaySnapshot(
        plan: value.today,
        state: value.state,
        topicOrderHead: value.todayTopicOrder,
        digest: RoadmapDigest(
          examId: value.examId,
          examDate: examDate,
          scopeTopicIds: value.todayTopicOrder,
          contentRevision: value.revision,
          assessmentCompleted: value.state.name != 'needsAssessment',
          recordedMockCount: 0,
          studyDays: studyDays,
        ),
      ),
      remaining: value.remaining,
      originalDone: value.originalDone,
    );

List<WeekDayState> serverWeekStates(List<Map<String, Object?>> days) {
  if (days.length != 7) throw const FormatException('Invalid server week');
  return [
    for (final day in days)
      switch (day['state']) {
        'done' => WeekDayState.done,
        'partial' => WeekDayState.partial,
        'missed' => WeekDayState.missed,
        'rest' => WeekDayState.dayOff,
        'today' => WeekDayState.today,
        'unknown' => WeekDayState.plain,
        _ => throw const FormatException('Invalid observed day'),
      },
  ];
}
