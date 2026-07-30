import 'package:pantas/features/study_plan/domain/daily_sizer.dart';
import 'package:pantas/features/study_plan/domain/pace_curve.dart';
import 'package:pantas/features/study_plan/domain/plan_prefs.dart';

enum TodayPlanMode {
  study,
  reviewOnly,
}

class ComputePlanInput {
  const ComputePlanInput({
    required this.today,
    required this.examId,
    required this.examName,
    required this.prefs,
    required this.startMastery,
    required this.actualMastery,
    required this.targetMastery,
    required this.totalQuestions,
    required this.dueReviewCount,
    required this.recommendedTopicId,
    required this.recommendedTopicName,
    required this.recommendedLessonId,
    this.hasMockWithinTwoWeeks = false,
  });

  final DateTime today;
  final String examId;
  final String examName;
  final PlanPrefs prefs;
  final double? startMastery;
  final double actualMastery;
  final double targetMastery;
  final int totalQuestions;
  final int dueReviewCount;
  final String? recommendedTopicId;
  final String? recommendedTopicName;
  final String? recommendedLessonId;
  final bool hasMockWithinTwoWeeks;
}

class PlanView {
  const PlanView({
    required this.examId,
    required this.examName,
    required this.weeksToExam,
    required this.paceStatus,
    required this.today,
    required this.upcoming,
    required this.usedFallbackMastery,
    this.nearestMock,
    this.warning,
  });

  final String examId;
  final String examName;
  final int weeksToExam;
  final PaceStatus paceStatus;
  final TodayPlan today;
  final List<UpcomingPlanDay> upcoming;
  final MockWeekPreview? nearestMock;
  final bool usedFallbackMastery;
  final String? warning;
}

class TodayPlan {
  const TodayPlan({
    required this.mode,
    required this.headline,
    required this.why,
    required this.reviewCount,
    required this.lessonId,
    required this.drillTopicId,
    required this.drillTopicName,
    required this.ctaPath,
  });

  final TodayPlanMode mode;
  final String headline;
  final String why;
  final int reviewCount;
  final String? lessonId;
  final String? drillTopicId;
  final String? drillTopicName;
  final String ctaPath;
}

class UpcomingPlanDay {
  const UpcomingPlanDay({
    required this.date,
    required this.focusLabel,
    required this.estimatedQuestionCount,
    required this.isRestDay,
  });

  final DateTime date;
  final String focusLabel;
  final int estimatedQuestionCount;
  final bool isRestDay;
}

class MockWeekPreview {
  const MockWeekPreview({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class ComputePlanView {
  const ComputePlanView({this.sizer = const DailySizer()});

  final DailySizer sizer;

  PlanView call(ComputePlanInput input) {
    final startMastery = input.startMastery ?? 0.30;
    final examDate =
        input.prefs.examDate ?? input.today.add(const Duration(days: 84));
    final daysRemaining =
        _dateOnly(examDate).difference(_dateOnly(input.today)).inDays;
    final curve = PaceCurve(
      planStart: input.today,
      examDate: examDate,
      startMastery: startMastery,
      targetMastery: input.targetMastery,
    );
    final pace =
        curve.status(actualMastery: input.actualMastery, on: input.today);
    final sizing = sizer.size(
      DailySizingInput(
        intensity: input.prefs.intensity,
        paceStatus: pace,
        totalQuestions: input.totalQuestions,
        daysRemaining: daysRemaining,
        actualMastery: input.actualMastery,
        targetMastery: input.targetMastery,
      ),
    );
    final reviewOnly = sizing.mode == DailySizingMode.reviewOnly;
    final topicName = input.recommendedTopicName ?? 'your weakest topic';
    final topicId = reviewOnly ? null : input.recommendedTopicId;
    final today = TodayPlan(
      mode: reviewOnly ? TodayPlanMode.reviewOnly : TodayPlanMode.study,
      headline: reviewOnly
          ? "You've hit your target across all topics"
          : 'Focus on $topicName today',
      why: input.startMastery == null
          ? 'Take a quick diagnostic so we can tune your plan.'
          : _whyFor(pace, topicName),
      reviewCount: reviewOnly ? sizing.reviewTargetCount : input.dueReviewCount,
      lessonId: reviewOnly ? null : input.recommendedLessonId,
      drillTopicId: topicId,
      drillTopicName: reviewOnly ? null : topicName,
      ctaPath: topicId == null
          ? '/quiz/today/${input.examId}'
          : '/quiz/today/${input.examId}?topicId=$topicId',
    );

    return PlanView(
      examId: input.examId,
      examName: input.examName,
      weeksToExam: (daysRemaining / 7).ceil().clamp(0, 999),
      paceStatus: pace,
      today: today,
      upcoming: [
        for (var i = 1; i <= 3; i++)
          UpcomingPlanDay(
            date: _dateOnly(input.today).add(Duration(days: i)),
            focusLabel: i == 3 ? 'Rest day · recharge' : topicName,
            estimatedQuestionCount: i == 3 ? 0 : sizing.activeDayQuestionCount,
            isRestDay: i == 3,
          ),
      ],
      nearestMock: input.hasMockWithinTwoWeeks
          ? const MockWeekPreview(
              title: 'Mock week is close',
              description: 'Keep this week steady so the mock feels familiar.',
            )
          : null,
      usedFallbackMastery: input.startMastery == null,
      warning: daysRemaining < 7
          ? 'This plan is compressed because the exam date is close.'
          : null,
    );
  }

  static String _whyFor(PaceStatus pace, String topicName) {
    return switch (pace) {
      PaceStatus.behind =>
        "You've drifted a bit; $topicName is the best recovery focus.",
      PaceStatus.onPace => 'On track. Keep the rhythm with $topicName.',
      PaceStatus.ahead => 'Ahead of pace. Keep $topicName fresh today.',
    };
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
