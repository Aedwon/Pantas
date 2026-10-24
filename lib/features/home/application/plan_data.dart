import 'package:intl/intl.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

String planWeekTitle(DateTime start) {
  final end = DateTime(start.year, start.month, start.day + 6);
  final first = DateFormat('MMM d', 'en_US').format(start);
  final last =
      DateFormat(start.month == end.month ? 'd' : 'MMM d', 'en_US').format(end);
  return '$first – $last';
}

String planStudyDaysLabel(Set<int> weekdays) {
  const names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final days = weekdays.toList()..sort();
  if (days.length > 2 && days.last - days.first == days.length - 1) {
    return 'You study ${names[days.first - 1]} to ${names[days.last - 1]}.';
  }
  final labels = [for (final d in days) names[d - 1]];
  final selected = labels.length == 1
      ? labels.single
      : '${labels.take(labels.length - 1).join(', ')} and ${labels.last}';
  return 'You study $selected.';
}

/// Legacy rows show only stored facts. Never replace a historic value with
/// today's settings or exam.
String? planHistoryText(RoadmapChange change, {required String examName}) =>
    switch (change.cause) {
      RoadmapChangeCause.examChanged => 'Your plan changed on '
          '${DateFormat('MMM d', 'en_US').format(change.occurredAt)}.',
      RoadmapChangeCause.examPassed =>
        'Your exam date passed. Your plan waits for a new date.',
      RoadmapChangeCause.missingExamDate =>
        'Your exam date was removed. Your plan is rebuilt when you set one.',
      RoadmapChangeCause.assessmentCompleted =>
        'Your plan was built from your assessment results.',
      RoadmapChangeCause.mockAnswersRecorded =>
        'Missed questions from your mock joined your reviews '
            'for the next days.',
      RoadmapChangeCause.backlogCapped =>
        'More reviews were due than one day holds. '
            'The rest wait for the next days.',
      RoadmapChangeCause.advanced when change.advancedCompleted == null =>
        "You added tomorrow's lessons to today.",
      RoadmapChangeCause.newDay || RoadmapChangeCause.prerequisiteCycle => null,
      _ => 'Your plan changed on '
          '${DateFormat('MMM d', 'en_US').format(change.occurredAt)}.',
    };

({int done, int total}) planChecklistProgress(DayPlan plan, DayPlan remaining) {
  final total = plan.lessonIds.length +
      (plan.reviewQuestionIds.isEmpty ? 0 : 1) +
      (plan.newQuestionIds.isEmpty ? 0 : 1);
  final left = remaining.lessonIds.length +
      (remaining.reviewQuestionIds.isEmpty ? 0 : 1) +
      (remaining.newQuestionIds.isEmpty ? 0 : 1);
  return (done: total - left, total: total);
}

CompletionFacts completedPlanFacts(
  DateTime date,
  Map<String, DateTime> reads,
  Iterable<Attempt> attempts,
) {
  final end = DateTime(date.year, date.month, date.day + 1);
  final seen = <String>{};
  final reviewed = <String>{};
  for (final attempt in attempts) {
    final finished = attempt.completedAt;
    if (finished == null || !finished.toLocal().isBefore(end)) continue;
    seen.addAll(attempt.items.map((i) => i.questionId));
    if (!finished.toLocal().isBefore(date)) {
      reviewed.addAll(attempt.items.map((i) => i.questionId));
    }
  }
  return CompletionFacts(
    readLessonIds: {
      for (final entry in reads.entries)
        if (entry.value.toLocal().isBefore(end)) entry.key,
    },
    seenQuestionIds: seen,
    reviewedTodayIds: reviewed,
  );
}

String? planWeekLabel(DateTime today, DateTime week) {
  final start =
      DateTime(today.year, today.month, today.day - today.weekday % 7);
  return switch (localDaysBetween(start, week)) {
    0 => 'This week',
    7 => 'Next week',
    _ => null
  };
}
