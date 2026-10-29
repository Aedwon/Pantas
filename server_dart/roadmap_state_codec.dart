import 'package:pantas/features/roadmap/domain/build_roadmap.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/planning_window.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_diff.dart';
import 'package:pantas/features/roadmap/domain/week_preview.dart';

import 'roadmap_codec.dart';

typedef Json = Map<String, Object?>;
Json _map(Object? value) => (value! as Map).cast<String, Object?>();
CompletionFacts _completion(Object? value) {
  final j = _map(value);
  Set<String> ids(String key) => (j[key]! as List).cast<String>().toSet();
  return CompletionFacts(
    readLessonIds: ids('readLessonIds'),
    seenQuestionIds: ids('seenQuestionIds'),
    reviewedTodayIds: ids('reviewedTodayIds'),
  );
}

Json planToJson(DayPlan p) => {
      'day': dayString(p.day),
      'lessonIds': p.lessonIds,
      'reviewQuestionIds': p.reviewQuestionIds,
      'newQuestionIds': p.newQuestionIds,
      'isMockDay': p.isMockDay,
      'isRestDay': p.isRestDay,
      'advancedIds': p.advancedIds.toList()..sort(),
      if (p.reasons.isNotEmpty) 'reasons': reasonsToJson(p.reasons),
    };
Json changeToJson(RoadmapChange c) => {
      'cause': c.cause.name,
      'occurredAt': stampString(c.occurredAt),
      'before': c.before?.toJson(),
      'after': c.after?.toJson(),
      'firstTopicsBefore': c.firstTopicsBefore,
      'firstTopicsAfter': c.firstTopicsAfter,
      'advancedCompleted': c.advancedCompleted,
    };
Json roadmapStateFromJson(Json j) {
  if (j['operation'] == 'snapshotView') {
    final snapshot = DaySnapshot.fromJson(_map(j['snapshot']));
    final facts = _completion(j['completion']);
    return {
      'today': planToJson(snapshot.plan),
      'remaining': planToJson(DaySnapshots.remaining(snapshot, facts)),
      'originalDone': DaySnapshots.originalDone(snapshot, facts),
    };
  }
  final rawInputs = _map(j['inputs']);
  final inputs = inputsFromJson(rawInputs);
  final roadmap = BuildRoadmap.call(inputs);
  final completion = _completion(j['completion']);
  final prior =
      j['snapshot'] == null ? null : DaySnapshot.fromJson(_map(j['snapshot']));
  if (j['operation'] == 'future') {
    final date = DateTime.parse(j['date']! as String);
    final ids = WeekPreviews.plannedLessonsForDay(
      today: inputs.today,
      date: date,
      reviewOnlyFrom: roadmap.reviewOnlyFrom,
      lessonTopicOrder: roadmap.topicOrder,
      lessons: inputs.lessons,
      lessonLinks: inputs.lessonLinks,
      scheduledToday: (j['scheduledToday']! as List).cast<String>().toSet(),
      studyDays: inputs.studyDays,
    );
    return {
      'plan': planToJson(
        DayPlan(
          day: date,
          lessonIds: ids,
          reviewQuestionIds: const [],
          newQuestionIds: const [],
          isMockDay: roadmap.mockDay == date,
          isRestDay: !inputs.studyDays.isStudyDay(date),
          advancedIds: const {},
        ),
      ),
    };
  }
  final digest = RoadmapDigest.parse(j['digest']! as String);
  final same =
      prior != null && prior.day == inputs.today && prior.digest == digest;
  var snapshot = same
      ? prior
      : DaySnapshot(
          plan: roadmap.today,
          digest: digest,
          topicOrderHead: roadmap.topicOrder,
          reviewOnlyFrom: roadmap.reviewOnlyFrom,
          state: roadmap.state,
        );
  final changes = same
      ? <RoadmapChange>[]
      : RoadmapDiff.between(
          prior: prior,
          priorCompletion: prior == null || prior.day == inputs.today
              ? null
              : _completion(j['priorCompletion']),
          next: snapshot,
          backlogCapped: roadmap.backlogCapped,
          cycleDetected: roadmap.cycleDetected,
          examPassed: roadmap.state == RoadmapState.examPassedAwaitingAnswer,
          examDateMissing: digest.examDate.isEmpty,
          occurredAt: DateTime.parse(j['now']! as String),
        );
  DaySnapshot? advanced() {
    if (!DaySnapshots.originalDone(snapshot, completion)) return null;
    final day = snapshot.day;
    final examDay = PlanningWindows.resolve(
      today: day,
      examDate: inputs.examDate,
      anchoredReviewOnlyFrom: snapshot.reviewOnlyFrom,
      studyDays: inputs.studyDays,
    ).examDay;
    final target = examDay == null
        ? DateTime(day.year, day.month, day.day + 1)
        : inputs.studyDays.nextAfter(day, before: examDay);
    final next = BuildRoadmap.call(
      inputsFromJson({
        ...rawInputs,
        'today': dayString(target ?? day),
        'treatTodayAsStudyDay': target == null,
      }),
    );
    var reviews = const <String>[];
    if (snapshot.plan.isRestDay &&
        !snapshot.plan.reviewQuestionIds
            .any(snapshot.plan.advancedIds.contains)) {
      reviews = BuildRoadmap.call(
        inputsFromJson({
          ...rawInputs,
          'treatTodayAsStudyDay': true,
        }),
      ).today.reviewQuestionIds;
    }
    final candidate =
        DaySnapshots.advance(snapshot, next.today, reviews: reviews);
    return candidate.plan.advancedIds.length == snapshot.plan.advancedIds.length
        ? null
        : candidate;
  }

  final candidate = advanced();
  if (j['operation'] == 'advance' && candidate != null) {
    changes.add(
      RoadmapDiff.advanced(
        before: snapshot,
        after: candidate,
        occurredAt: DateTime.parse(j['now']! as String),
      ),
    );
    snapshot = candidate;
  }
  final remaining = DaySnapshots.remaining(snapshot, completion);
  return {
    'snapshot': snapshot.toJson(),
    'today': planToJson(snapshot.plan),
    'remaining': planToJson(remaining),
    'originalDone': DaySnapshots.originalDone(snapshot, completion),
    'canAdvance':
        j['operation'] == 'advance' ? advanced() != null : candidate != null,
    'roadmap': roadmapToJson(roadmap),
    'changes': [
      for (final change in changes)
        if (change.cause != RoadmapChangeCause.newDay &&
            change.cause != RoadmapChangeCause.prerequisiteCycle)
          changeToJson(change),
    ],
  };
}
