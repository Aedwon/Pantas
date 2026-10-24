import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/features/roadmap/domain/day_selection.dart';
import 'package:pantas/features/roadmap/domain/mock_day.dart';
import 'package:pantas/features/roadmap/domain/planning_window.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/topic_order.dart';
import 'package:pantas/features/roadmap/domain/week_preview.dart';

/// Builds the whole plan from what the student has done and when the exam
/// is. Pure: the same inputs always give the same plan.
abstract final class BuildRoadmap {
  static Roadmap call(RoadmapInputs inputs) {
    final today = localDay(inputs.today);
    final isStudyDay =
        inputs.treatTodayAsStudyDay || inputs.studyDays.isStudyDay(today);

    if (!inputs.assessmentCompleted) {
      return _empty(
        RoadmapState.needsAssessment,
        today,
        isRestDay: !isStudyDay,
      );
    }
    if (inputs.topics.isEmpty ||
        (inputs.lessons.isEmpty && inputs.questions.isEmpty)) {
      return _empty(RoadmapState.noContent, today, isRestDay: !isStudyDay);
    }

    final window = PlanningWindows.resolve(
      today: today,
      examDate: inputs.examDate,
      anchoredReviewOnlyFrom: inputs.anchoredReviewOnlyFrom,
      studyDays: inputs.studyDays,
      treatTodayAsStudyDay: inputs.treatTodayAsStudyDay,
    );
    final order = TopicOrder.compute(
      topics: inputs.topics,
      scores: inputs.scores,
      prerequisites: inputs.prerequisites,
      lessons: inputs.lessons,
    );

    final lessonsLeft =
        inputs.lessons.where((lesson) => lesson.readAt == null).length;
    final unseenLeft = inputs.questions
        .where((question) => !inputs.seenQuestionIds.contains(question.id))
        .length;

    // Reviews only: the exam is today or has passed, or there is no date to
    // pace against (spec 4.1). No new material is scheduled.
    final isExamDay = inputs.examDate?.day == today;
    final reviewsOnly = window.examDay == null ||
        window.daysLeft <= 0 ||
        window.state == RoadmapState.examPassedAwaitingAnswer;

    // Inside the review-only stretch with material left, coverage wins: the
    // rest is spread over the days before the exam (spec 4.2, "let them
    // cram").
    final days = window.workingDays > 0
        ? window.workingDays
        : window.studyDaysBeforeExam;
    final selection = DaySelector.select(
      lessonTopicOrder: order.order,
      rankedTopics: order.ranked,
      lessons: inputs.lessons,
      questions: inputs.questions,
      seenQuestionIds: inputs.seenQuestionIds,
      dueReviews: isStudyDay || isExamDay ? inputs.dueReviews : const [],
      answeredPerActiveDay: inputs.answeredPerActiveDay,
      lessonsToday: reviewsOnly || !isStudyDay
          ? 0
          : PlanningWindows.perDay(lessonsLeft, days),
      newToday: reviewsOnly || !isStudyDay
          ? 0
          : PlanningWindows.perDay(unseenLeft, days),
    );

    final examDay = window.examDay;
    final mockDay = MockDay.place(
      today: today,
      examDay: examDay,
      reviewOnlyFrom: window.reviewOnlyFrom,
      mock: inputs.mock,
      mockSubmittedInWindow: _submittedInWindow(inputs.mock, examDay),
      studyDays: inputs.studyDays,
    );

    final state = switch (window.state) {
      RoadmapState.planning when inputs.examDate == null =>
        RoadmapState.planning,
      RoadmapState.planning ||
      RoadmapState.reviewOnly when lessonsLeft == 0 && unseenLeft == 0 =>
        RoadmapState.allCovered,
      final other => other,
    };

    return Roadmap(
      state: state,
      today: DayPlan(
        day: today,
        lessonIds: selection.lessonIds,
        // The approved optional warm-up keeps the scheduler's actual order.
        reviewQuestionIds: isExamDay
            ? selection.reviewQuestionIds.take(10).toList()
            : selection.reviewQuestionIds,
        newQuestionIds: selection.newQuestionIds,
        isMockDay: isStudyDay && mockDay != null && mockDay == today,
        isRestDay: !isStudyDay,
        advancedIds: const {},
      ),
      examDay: examDay,
      reviewOnlyFrom: window.reviewOnlyFrom,
      mockDay: mockDay,
      weeksAhead: reviewsOnly
          ? const []
          : WeekPreviews.build(
              today: today,
              reviewOnlyFrom: window.reviewOnlyFrom,
              lessonTopicOrder: order.order,
              lessons: inputs.lessons,
              scheduledToday: selection.lessonIds.toSet(),
              studyDays: inputs.studyDays,
            ),
      topicOrder: order.order,
      changes: const [],
      backlogCapped: selection.backlogCapped,
      cycleDetected: order.cycleDetected,
    );
  }

  static bool _submittedInWindow(RoadmapMockFacts mock, DateTime? examDay) {
    final submitted = mock.lastSubmittedAt;
    if (submitted == null || examDay == null) return false;
    final day = localDay(submitted);
    final start = DateTime(examDay.year, examDay.month, examDay.day - 6);
    return !day.isBefore(start) && day.isBefore(examDay);
  }

  static Roadmap _empty(
    RoadmapState state,
    DateTime today, {
    required bool isRestDay,
  }) =>
      Roadmap(
        state: state,
        today: DayPlan(
          day: today,
          lessonIds: const <LessonId>[],
          reviewQuestionIds: const <QuestionId>[],
          newQuestionIds: const <QuestionId>[],
          isMockDay: false,
          isRestDay: isRestDay,
          advancedIds: const {},
        ),
        examDay: null,
        reviewOnlyFrom: null,
        mockDay: null,
        weeksAhead: const [],
        topicOrder: const [],
        changes: const [],
      );
}
