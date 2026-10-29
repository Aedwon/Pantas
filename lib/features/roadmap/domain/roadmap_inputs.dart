import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';

@immutable
final class RoadmapTopic {
  const RoadmapTopic({
    required this.id,
    required this.authoredIndex,
    required this.name,
  });

  final TopicId id;
  final int authoredIndex;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is RoadmapTopic &&
      id == other.id &&
      authoredIndex == other.authoredIndex &&
      name == other.name;

  @override
  int get hashCode => Object.hash(id, authoredIndex, name);
}

@immutable
final class RoadmapLesson {
  const RoadmapLesson({
    required this.id,
    required this.topicId,
    required this.ordering,
    this.readAt,
  });

  final LessonId id;
  final TopicId topicId;
  final int ordering;
  final DateTime? readAt;

  @override
  bool operator ==(Object other) =>
      other is RoadmapLesson &&
      id == other.id &&
      topicId == other.topicId &&
      ordering == other.ordering &&
      readAt == other.readAt;

  @override
  int get hashCode => Object.hash(id, topicId, ordering, readAt);
}

@immutable
final class RoadmapQuestion {
  const RoadmapQuestion({
    required this.id,
    required this.topicId,
    this.lessonId,
    this.passageId,
  });

  final QuestionId id;
  final TopicId topicId;
  final LessonId? lessonId;
  final PassageId? passageId;

  @override
  bool operator ==(Object other) =>
      other is RoadmapQuestion &&
      id == other.id &&
      topicId == other.topicId &&
      lessonId == other.lessonId &&
      passageId == other.passageId;

  @override
  int get hashCode => Object.hash(id, topicId, lessonId, passageId);
}

@immutable
final class RoadmapReview {
  const RoadmapReview({
    required this.id,
    required this.due,
    required this.retrievability,
  });

  final QuestionId id;
  final DateTime due;
  final double retrievability;

  @override
  bool operator ==(Object other) =>
      other is RoadmapReview &&
      id == other.id &&
      due == other.due &&
      retrievability == other.retrievability;

  @override
  int get hashCode => Object.hash(id, due, retrievability);
}

@immutable
final class RoadmapTopicScore {
  const RoadmapTopicScore({
    required this.id,
    required this.correct,
    required this.answered,
  });

  final TopicId id;
  final int correct;
  final int answered;

  bool get isMeasured => answered >= 3;

  @override
  bool operator ==(Object other) =>
      other is RoadmapTopicScore &&
      id == other.id &&
      correct == other.correct &&
      answered == other.answered;

  @override
  int get hashCode => Object.hash(id, correct, answered);
}

@immutable
final class RoadmapMockFacts {
  const RoadmapMockFacts({
    required this.examHasMock,
    required this.proIsActive,
    this.lastSubmittedAt,
  });

  final bool examHasMock;
  final bool proIsActive;
  final DateTime? lastSubmittedAt;

  @override
  bool operator ==(Object other) =>
      other is RoadmapMockFacts &&
      examHasMock == other.examHasMock &&
      proIsActive == other.proIsActive &&
      lastSubmittedAt == other.lastSubmittedAt;

  @override
  int get hashCode => Object.hash(examHasMock, proIsActive, lastSubmittedAt);
}

@immutable
final class RoadmapInputs {
  RoadmapInputs({
    required this.today,
    required this.examId,
    required this.examDate,
    required List<RoadmapTopic> topics,
    required List<RoadmapLesson> lessons,
    required List<RoadmapQuestion> questions,
    required Set<QuestionId> seenQuestionIds,
    required List<RoadmapReview> dueReviews,
    required Map<TopicId, RoadmapTopicScore> scores,
    required List<int> answeredPerActiveDay,
    required this.mock,
    required this.assessmentCompleted,
    required this.contentRevision,
    LessonLinks lessonLinks = const {},
    List<QuestionHistory> history = const [],
    Map<QuestionId, double> recall = const {},
    Map<String, LessonId> gapTags = const {},
    this.anchoredReviewOnlyFrom,
    this.studyDays = StudyDays.all,
    this.treatTodayAsStudyDay = false,
  })  : topics = List.unmodifiable(topics),
        lessonLinks = Map.unmodifiable({
          for (final entry in lessonLinks.entries)
            entry.key: List<LessonLink>.unmodifiable(entry.value),
        }),
        history = List.unmodifiable(history),
        recall = Map.unmodifiable(recall),
        gapTags = Map.unmodifiable(gapTags),
        lessons = List.unmodifiable(lessons),
        questions = List.unmodifiable(questions),
        seenQuestionIds = Set.unmodifiable(seenQuestionIds),
        dueReviews = List.unmodifiable(dueReviews),
        scores = Map.unmodifiable(scores),
        answeredPerActiveDay = List.unmodifiable(answeredPerActiveDay);

  final DateTime today;
  final StudyDays studyDays;
  final bool treatTodayAsStudyDay;
  final ExamId examId;
  final ExamDate? examDate;
  final List<RoadmapTopic> topics;
  final LessonLinks lessonLinks;
  final List<QuestionHistory> history;
  final Map<QuestionId, double> recall;
  final Map<String, LessonId> gapTags;
  final List<RoadmapLesson> lessons;
  final List<RoadmapQuestion> questions;
  final Set<QuestionId> seenQuestionIds;
  final List<RoadmapReview> dueReviews;
  final Map<TopicId, RoadmapTopicScore> scores;
  final List<int> answeredPerActiveDay;
  final RoadmapMockFacts mock;
  final bool assessmentCompleted;
  final String contentRevision;

  /// The review-only start fixed by the first plan for this exam and exam
  /// date, carried from the stored days. Null for a first plan, or after the
  /// exam or its date changed.
  final DateTime? anchoredReviewOnlyFrom;

  static const _equality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      other is RoadmapInputs &&
      today == other.today &&
      studyDays == other.studyDays &&
      treatTodayAsStudyDay == other.treatTodayAsStudyDay &&
      examId == other.examId &&
      examDate == other.examDate &&
      _equality.equals(topics, other.topics) &&
      _equality.equals(lessonLinks, other.lessonLinks) &&
      _equality.equals(history, other.history) &&
      _equality.equals(recall, other.recall) &&
      _equality.equals(gapTags, other.gapTags) &&
      _equality.equals(lessons, other.lessons) &&
      _equality.equals(questions, other.questions) &&
      _equality.equals(seenQuestionIds, other.seenQuestionIds) &&
      _equality.equals(dueReviews, other.dueReviews) &&
      _equality.equals(scores, other.scores) &&
      _equality.equals(answeredPerActiveDay, other.answeredPerActiveDay) &&
      mock == other.mock &&
      assessmentCompleted == other.assessmentCompleted &&
      contentRevision == other.contentRevision &&
      anchoredReviewOnlyFrom == other.anchoredReviewOnlyFrom;

  @override
  int get hashCode => Object.hashAll([
        today,
        studyDays,
        treatTodayAsStudyDay,
        examId,
        examDate,
        _equality.hash(topics),
        _equality.hash(lessonLinks),
        _equality.hash(history),
        _equality.hash(recall),
        _equality.hash(gapTags),
        _equality.hash(lessons),
        _equality.hash(questions),
        _equality.hash(seenQuestionIds),
        _equality.hash(dueReviews),
        _equality.hash(scores),
        _equality.hash(answeredPerActiveDay),
        mock,
        assessmentCompleted,
        contentRevision,
      ]);
}
