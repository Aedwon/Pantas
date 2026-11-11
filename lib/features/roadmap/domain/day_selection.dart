import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';
import 'package:pantas/features/roadmap/domain/lesson_queue.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

final class DaySelection {
  DaySelection({
    required List<LessonId> lessonIds,
    required List<QuestionId> newQuestionIds,
    required List<QuestionId> reviewQuestionIds,
    required this.backlogCapped,
    required this.dueCount,
    this.reasons = const {},
  })  : lessonIds = List.unmodifiable(lessonIds),
        newQuestionIds = List.unmodifiable(newQuestionIds),
        reviewQuestionIds = List.unmodifiable(reviewQuestionIds);

  final List<LessonId> lessonIds;
  final List<QuestionId> newQuestionIds;
  final List<QuestionId> reviewQuestionIds;
  final bool backlogCapped;
  final int dueCount;
  final Map<String, PlanReason> reasons;
}

abstract final class DaySelector {
  static DaySelection select({
    required List<TopicId> lessonTopicOrder,
    required List<TopicId> rankedTopics,
    required List<RoadmapLesson> lessons,
    required List<RoadmapQuestion> questions,
    required Set<QuestionId> seenQuestionIds,
    required List<RoadmapReview> dueReviews,
    required List<int> answeredPerActiveDay,
    required int lessonsToday,
    required int newToday,
    LessonQueue? lessonQueue,
    Map<LessonId, LessonId> followUps = const {},
    List<QuestionHistory> history = const [],
    Map<QuestionId, double> recall = const {},
    Map<TopicId, RoadmapTopicScore> scores = const {},
    bool includeDetours = true,
  }) {
    final lessonsById = {for (final lesson in lessons) lesson.id: lesson};
    final lessonsByTopic = <TopicId, List<RoadmapLesson>>{};
    for (final lesson in lessons) {
      (lessonsByTopic[lesson.topicId] ??= []).add(lesson);
    }
    for (final topicLessons in lessonsByTopic.values) {
      topicLessons.sort((a, b) {
        final comparison = a.ordering.compareTo(b.ordering);
        return comparison != 0 ? comparison : a.id.compareTo(b.id);
      });
    }
    final queue = lessonQueue ??
        LessonQueue.build(
          lessonTopicOrder: lessonTopicOrder,
          lessons: lessons,
        );
    final followUpLessons = queue.lessons.where(
      (lesson) => followUps.containsKey(lesson.id),
    );
    final todayLessons = [
      ...followUpLessons,
      ...queue.lessons.where((lesson) => !followUps.containsKey(lesson.id)),
    ]
        .where((lesson) => !queue.withheld.contains(lesson.id))
        .take(lessonsToday)
        .map((lesson) => lesson.id)
        .toList();
    final reasons = <String, PlanReason>{};
    for (final id in todayLessons) {
      final followUp = followUps[id];
      final dependent = followUp ?? queue.prerequisiteFor[id];
      final score = scores[lessonsById[id]!.topicId];
      reasons[id] = PlanReason(
        kind: followUp != null
            ? PlanReasonKind.followUp
            : dependent != null
                ? PlanReasonKind.prerequisite
                : score != null &&
                        score.isMeasured &&
                        score.correct / score.answered < 0.70
                    ? PlanReasonKind.weakTopic
                    : PlanReasonKind.nextUp,
        forLessonId: dependent,
      );
    }
    final histories = {for (final row in history) row.id: row};
    final detours = <RoadmapQuestion>[];
    if (includeDetours) {
      final practiceFor = <LessonId, LessonId>{
        for (final entry in followUps.entries)
          if (lessonsById[entry.key]?.readAt != null) entry.key: entry.value,
        for (final entry in queue.weakFor.entries)
          entry.key: followUps[entry.key] ?? entry.value,
      };
      for (final entry in practiceFor.entries.take(2)) {
        final practice =
            questions.where((q) => q.lessonId == entry.key).toList()
              ..sort((a, b) {
                final recallOrder =
                    (recall[a.id] ?? 1).compareTo(recall[b.id] ?? 1);
                if (recallOrder != 0) return recallOrder;
                final wrongA = histories[a.id]?.lastWrongChoiceId != null;
                final wrongB = histories[b.id]?.lastWrongChoiceId != null;
                if (wrongA != wrongB) return wrongA ? -1 : 1;
                final unseenA = !seenQuestionIds.contains(a.id);
                final unseenB = !seenQuestionIds.contains(b.id);
                if (unseenA != unseenB) return unseenA ? -1 : 1;
                return a.id.compareTo(b.id);
              });
        for (final question in practice.take(5)) {
          detours.add(question);
          reasons[question.id] = PlanReason(
            kind: followUps.containsKey(entry.key)
                ? PlanReasonKind.followUp
                : PlanReasonKind.prerequisite,
            forLessonId: entry.value,
          );
        }
      }
    }
    final detourIds = detours.map((q) => q.id).toSet();

    final unseen = questions
        .where((question) => !seenQuestionIds.contains(question.id))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final questionsByLesson = <LessonId, List<RoadmapQuestion>>{};
    final questionsWithoutLesson = <TopicId, List<RoadmapQuestion>>{};
    final questionsByPassage = <PassageId, List<RoadmapQuestion>>{};
    for (final question in unseen) {
      final lessonId = question.lessonId;
      if (lessonId == null) {
        (questionsWithoutLesson[question.topicId] ??= []).add(question);
      } else {
        (questionsByLesson[lessonId] ??= []).add(question);
      }
      final passageId = question.passageId;
      if (passageId != null) {
        (questionsByPassage[passageId] ??= []).add(question);
      }
    }

    final readQuestions = unseen
        .where((question) => lessonsById[question.lessonId]?.readAt != null)
        .toList()
      ..sort((a, b) {
        final comparison = lessonsById[a.lessonId]!
            .readAt!
            .compareTo(lessonsById[b.lessonId]!.readAt!);
        return comparison != 0 ? comparison : a.id.compareTo(b.id);
      });

    Iterable<RoadmapQuestion> originalCandidates() sync* {
      yield* readQuestions;
      for (final lessonId in todayLessons) {
        yield* questionsByLesson[lessonId] ?? <RoadmapQuestion>[];
      }
      for (final topicId in rankedTopics) {
        for (final lesson in lessonsByTopic[topicId] ?? <RoadmapLesson>[]) {
          yield* questionsByLesson[lesson.id] ?? <RoadmapQuestion>[];
        }
        yield* questionsWithoutLesson[topicId] ?? <RoadmapQuestion>[];
      }
      // Anything no walk above reached: a lesson that is unknown, out of
      // scope, or in a topic missing from the ranking. Coverage promises
      // every scoped question is seen in time, so none may be skipped.
      final rankIndex = {
        for (var i = 0; i < rankedTopics.length; i++) rankedTopics[i]: i,
      };
      int rankOf(TopicId topicId) => rankIndex[topicId] ?? rankedTopics.length;
      yield* List<RoadmapQuestion>.of(unseen)
        ..sort((a, b) {
          final comparison = rankOf(a.topicId).compareTo(rankOf(b.topicId));
          return comparison != 0 ? comparison : a.id.compareTo(b.id);
        });
    }

    Iterable<RoadmapQuestion> candidates() sync* {
      yield* originalCandidates().where(
        (q) => !queue.withheld.contains(q.lessonId),
      );
      yield* originalCandidates().where(
        (q) => queue.withheld.contains(q.lessonId),
      );
    }

    final newQuestions = <QuestionId>[];
    final selected = <QuestionId>{...detourIds};
    for (final question in candidates()) {
      if (newQuestions.length >= newToday) break;
      if (!selected.add(question.id)) continue;
      newQuestions.add(question.id);
      final passageId = question.passageId;
      if (passageId != null) {
        // Finish this passage even if its remainder exceeds today's quota.
        for (final sibling in questionsByPassage[passageId]!) {
          if (selected.add(sibling.id)) newQuestions.add(sibling.id);
        }
      }
    }

    final reviews = dueReviews.where((r) => !detourIds.contains(r.id)).toList()
      ..sort((a, b) {
        final comparison = b.retrievability.compareTo(a.retrievability);
        if (comparison != 0) return comparison;
        final dueComparison = a.due.compareTo(b.due);
        return dueComparison != 0 ? dueComparison : a.id.compareTo(b.id);
      });
    final reviewCapacity = capacity(answeredPerActiveDay);
    final backlogCapped =
        reviewCapacity != null && reviews.length > reviewCapacity;
    return DaySelection(
      lessonIds: todayLessons,
      newQuestionIds: [
        for (final q in detours)
          if (!seenQuestionIds.contains(q.id)) q.id,
        ...newQuestions,
      ],
      reviewQuestionIds: [
        for (final q in detours)
          if (seenQuestionIds.contains(q.id)) q.id,
        ...reviews
            .take(backlogCapped ? reviewCapacity : reviews.length)
            .map((review) => review.id),
      ],
      reasons: Map.unmodifiable(reasons),
      backlogCapped: backlogCapped,
      dueCount: dueReviews.length,
    );
  }

  static int? capacity(List<int> answeredPerActiveDay) {
    if (answeredPerActiveDay.isEmpty) return null;
    final sorted = List<int>.of(answeredPerActiveDay)..sort();
    final median = sorted[(sorted.length - 1) ~/ 2];
    return median < 1 ? 1 : median;
  }
}
