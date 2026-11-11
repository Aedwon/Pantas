import 'package:collection/collection.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

/// Why the plan changed (spec 4.9). Every entry carries only counts that
/// were real when it was written, and none states a verdict about the
/// student: a change is described, never judged.
abstract final class RoadmapDiff {
  /// The changes from [prior] to a freshly built [next].
  ///
  /// [priorCompletion] is what the student had done on [prior]'s day; it is
  /// read when a new day starts, to tell finished work from unfinished work.
  static List<RoadmapChange> between({
    required DaySnapshot? prior,
    required CompletionFacts? priorCompletion,
    required DaySnapshot next,
    required bool backlogCapped,
    required bool cycleDetected,
    required bool examPassed,
    required bool examDateMissing,
    required DateTime occurredAt,
  }) {
    final after = DaySnapshots.originalCounts(next.plan);
    final headAfter = next.topicOrderHead;
    final headBefore = prior?.topicOrderHead ?? const <TopicId>[];
    final before =
        prior == null ? null : DaySnapshots.originalCounts(prior.plan);

    RoadmapChange change(
      RoadmapChangeCause cause, {
      RoadmapDayCounts? from,
      int? advancedCompleted,
    }) =>
        RoadmapChange(
          cause: cause,
          occurredAt: occurredAt,
          before: from,
          after: after,
          firstTopicsBefore: headBefore,
          firstTopicsAfter: headAfter,
          advancedCompleted: advancedCompleted,
        );

    final changes = <RoadmapChange>[];
    final newDay = prior == null || prior.day != next.day;
    if (newDay) changes.add(change(RoadmapChangeCause.newDay, from: before));

    if (prior != null && newDay && priorCompletion != null) {
      final left = DaySnapshots.originalLeftCounts(prior, priorCompletion);
      if (!prior.plan.isRestDay &&
          left.lessons + left.newQuestions + left.reviews > 0) {
        changes.add(change(RoadmapChangeCause.missedWork, from: left));
      }
      if (prior.plan.advancedIds.isNotEmpty) {
        changes.add(
          change(
            RoadmapChangeCause.advanced,
            from: before,
            advancedCompleted:
                DaySnapshots.advancedCompleted(prior, priorCompletion),
          ),
        );
      }
    }

    final digestCauses = prior == null
        ? const <RoadmapChangeCause>[]
        : prior.digest.causesTo(next.digest);
    for (final cause in digestCauses) {
      changes.add(change(cause, from: before));
    }

    if (prior != null &&
        digestCauses.isEmpty &&
        !const ListEquality<TopicId>().equals(headBefore, headAfter)) {
      changes.add(change(RoadmapChangeCause.orderChanged, from: before));
    }

    if (backlogCapped) changes.add(change(RoadmapChangeCause.backlogCapped));
    if (cycleDetected) {
      changes.add(change(RoadmapChangeCause.prerequisiteCycle));
    }
    if (examPassed) changes.add(change(RoadmapChangeCause.examPassed));
    if (examDateMissing) {
      changes.add(change(RoadmapChangeCause.missingExamDate));
    }
    return changes;
  }

  /// The entry written when the student chooses to advance.
  static RoadmapChange advanced({
    required DaySnapshot before,
    required DaySnapshot after,
    required DateTime occurredAt,
  }) =>
      RoadmapChange(
        cause: RoadmapChangeCause.advanced,
        occurredAt: occurredAt,
        before: _allCounts(before.plan),
        after: _allCounts(after.plan),
        firstTopicsBefore: before.topicOrderHead,
        firstTopicsAfter: after.topicOrderHead,
      );

  static RoadmapDayCounts _allCounts(DayPlan plan) => RoadmapDayCounts(
        lessons: plan.lessonIds.length,
        newQuestions: plan.newQuestionIds.length,
        reviews: plan.reviewQuestionIds.length,
      );
}
