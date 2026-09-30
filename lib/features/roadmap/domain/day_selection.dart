import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

final class DaySelection {
  DaySelection({
    required List<LessonId> lessonIds,
    required List<QuestionId> newQuestionIds,
    required List<QuestionId> reviewQuestionIds,
    required this.backlogCapped,
    required this.dueCount,
  })  : lessonIds = List.unmodifiable(lessonIds),
        newQuestionIds = List.unmodifiable(newQuestionIds),
        reviewQuestionIds = List.unmodifiable(reviewQuestionIds);

  final List<LessonId> lessonIds;
  final List<QuestionId> newQuestionIds;
  final List<QuestionId> reviewQuestionIds;
  final bool backlogCapped;
  final int dueCount;
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
    final todayLessons = <LessonId>[];
    for (final topicId in lessonTopicOrder) {
      for (final lesson in lessonsByTopic[topicId] ?? <RoadmapLesson>[]) {
        if (todayLessons.length >= lessonsToday) break;
        if (lesson.readAt == null) todayLessons.add(lesson.id);
      }
      if (todayLessons.length >= lessonsToday) break;
    }

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

    Iterable<RoadmapQuestion> candidates() sync* {
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
    }

    final newQuestions = <QuestionId>[];
    final selected = <QuestionId>{};
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

    final reviews = List<RoadmapReview>.of(dueReviews)
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
      newQuestionIds: newQuestions,
      reviewQuestionIds: reviews
          .take(backlogCapped ? reviewCapacity : reviews.length)
          .map((review) => review.id)
          .toList(),
      backlogCapped: backlogCapped,
      dueCount: reviews.length,
    );
  }

  static int? capacity(List<int> answeredPerActiveDay) {
    if (answeredPerActiveDay.isEmpty) return null;
    final sorted = List<int>.of(answeredPerActiveDay)..sort();
    final median = sorted[(sorted.length - 1) ~/ 2];
    return median < 1 ? 1 : median;
  }
}
