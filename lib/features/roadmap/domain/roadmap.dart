import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';

enum RoadmapState {
  needsAssessment,
  noContent,
  examPassedAwaitingAnswer,
  monthStartedAwaitingDay,
  planning,
  reviewOnly,
  allCovered,
}

@immutable
final class DayPlan {
  DayPlan({
    required this.day,
    required List<LessonId> lessonIds,
    required List<QuestionId> reviewQuestionIds,
    required List<QuestionId> newQuestionIds,
    required this.isMockDay,
    required Set<String> advancedIds,
  })  : lessonIds = List.unmodifiable(lessonIds),
        reviewQuestionIds = List.unmodifiable(reviewQuestionIds),
        newQuestionIds = List.unmodifiable(newQuestionIds),
        advancedIds = Set.unmodifiable(advancedIds);

  final DateTime day;
  final List<LessonId> lessonIds;
  final List<QuestionId> reviewQuestionIds;
  final List<QuestionId> newQuestionIds;
  final bool isMockDay;
  final Set<String> advancedIds;

  int get questionCount => reviewQuestionIds.length + newQuestionIds.length;

  static const _equality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      other is DayPlan &&
      day == other.day &&
      _equality.equals(lessonIds, other.lessonIds) &&
      _equality.equals(reviewQuestionIds, other.reviewQuestionIds) &&
      _equality.equals(newQuestionIds, other.newQuestionIds) &&
      isMockDay == other.isMockDay &&
      _equality.equals(advancedIds, other.advancedIds);

  @override
  int get hashCode => Object.hash(
        day,
        _equality.hash(lessonIds),
        _equality.hash(reviewQuestionIds),
        _equality.hash(newQuestionIds),
        isMockDay,
        _equality.hash(advancedIds),
      );
}

@immutable
final class WeekPreview {
  WeekPreview({required this.weekStart, required List<TopicId> topicIds})
      : topicIds = List.unmodifiable(topicIds);

  final DateTime weekStart;
  final List<TopicId> topicIds;

  static const _equality = ListEquality<TopicId>();

  @override
  bool operator ==(Object other) =>
      other is WeekPreview &&
      weekStart == other.weekStart &&
      _equality.equals(topicIds, other.topicIds);

  @override
  int get hashCode => Object.hash(weekStart, _equality.hash(topicIds));
}

enum RoadmapChangeCause {
  newDay,
  missedWork,
  advanced,
  examDateChanged,
  examChanged,
  scopeChanged,
  contentChanged,
  orderChanged,
  backlogCapped,
  assessmentCompleted,
  examPassed,
  prerequisiteCycle,
  missingExamDate,
  mockAnswersRecorded,
}

@immutable
final class RoadmapDayCounts {
  const RoadmapDayCounts({
    required this.lessons,
    required this.newQuestions,
    required this.reviews,
  });

  factory RoadmapDayCounts.fromJson(Map<String, Object?> json) =>
      RoadmapDayCounts(
        lessons: json['lessons']! as int,
        newQuestions: json['new']! as int,
        reviews: json['reviews']! as int,
      );

  final int lessons;
  final int newQuestions;
  final int reviews;

  Map<String, Object?> toJson() =>
      {'lessons': lessons, 'new': newQuestions, 'reviews': reviews};

  @override
  bool operator ==(Object other) =>
      other is RoadmapDayCounts &&
      lessons == other.lessons &&
      newQuestions == other.newQuestions &&
      reviews == other.reviews;

  @override
  int get hashCode => Object.hash(lessons, newQuestions, reviews);
}

@immutable
final class RoadmapChange {
  RoadmapChange({
    required this.cause,
    required this.occurredAt,
    required List<TopicId> firstTopicsBefore,
    required List<TopicId> firstTopicsAfter,
    this.before,
    this.after,
    this.advancedCompleted,
  })  : firstTopicsBefore = List.unmodifiable(firstTopicsBefore),
        firstTopicsAfter = List.unmodifiable(firstTopicsAfter);

  final RoadmapChangeCause cause;
  final DateTime occurredAt;
  final RoadmapDayCounts? before;
  final RoadmapDayCounts? after;
  final List<TopicId> firstTopicsBefore;
  final List<TopicId> firstTopicsAfter;
  final int? advancedCompleted;

  static const _equality = ListEquality<TopicId>();

  @override
  bool operator ==(Object other) =>
      other is RoadmapChange &&
      cause == other.cause &&
      occurredAt == other.occurredAt &&
      before == other.before &&
      after == other.after &&
      _equality.equals(firstTopicsBefore, other.firstTopicsBefore) &&
      _equality.equals(firstTopicsAfter, other.firstTopicsAfter) &&
      advancedCompleted == other.advancedCompleted;

  @override
  int get hashCode => Object.hash(
        cause,
        occurredAt,
        before,
        after,
        _equality.hash(firstTopicsBefore),
        _equality.hash(firstTopicsAfter),
        advancedCompleted,
      );
}

@immutable
final class Roadmap {
  Roadmap({
    required this.state,
    required this.today,
    required this.examDay,
    required this.reviewOnlyFrom,
    required this.mockDay,
    required List<WeekPreview> weeksAhead,
    required List<TopicId> topicOrder,
    required List<RoadmapChange> changes,
    this.backlogCapped = false,
    this.cycleDetected = false,
  })  : weeksAhead = List.unmodifiable(weeksAhead),
        topicOrder = List.unmodifiable(topicOrder),
        changes = List.unmodifiable(changes);

  final RoadmapState state;
  final DayPlan today;
  final DateTime? examDay;
  final DateTime? reviewOnlyFrom;
  final DateTime? mockDay;
  final List<WeekPreview> weeksAhead;
  final List<TopicId> topicOrder;
  final List<RoadmapChange> changes;

  /// More reviews were due than today holds; the rest wait (spec 4.6).
  final bool backlogCapped;

  /// The prerequisite map has a loop; the order skipped it (spec 4.3).
  final bool cycleDetected;

  static const _equality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      other is Roadmap &&
      backlogCapped == other.backlogCapped &&
      cycleDetected == other.cycleDetected &&
      state == other.state &&
      today == other.today &&
      examDay == other.examDay &&
      reviewOnlyFrom == other.reviewOnlyFrom &&
      mockDay == other.mockDay &&
      _equality.equals(weeksAhead, other.weeksAhead) &&
      _equality.equals(topicOrder, other.topicOrder) &&
      _equality.equals(changes, other.changes);

  @override
  int get hashCode => Object.hash(
        state,
        today,
        examDay,
        reviewOnlyFrom,
        mockDay,
        _equality.hash(weeksAhead),
        _equality.hash(topicOrder),
        _equality.hash(changes),
      );
}
