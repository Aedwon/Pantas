import 'dart:math' as math;

import 'package:cse_cet_reviewer/features/study_plan/domain/pace_curve.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/plan_prefs.dart';

enum DailySizingMode {
  study,
  reviewOnly,
}

class DailySizingInput {
  const DailySizingInput({
    required this.intensity,
    required this.paceStatus,
    required this.totalQuestions,
    required this.daysRemaining,
    required this.actualMastery,
    required this.targetMastery,
  });

  final StudyPlanIntensity intensity;
  final PaceStatus paceStatus;
  final int totalQuestions;
  final int daysRemaining;
  final double actualMastery;
  final double targetMastery;
}

class DailySizing {
  const DailySizing({
    required this.mode,
    required this.activeDayQuestionCount,
    required this.reviewTargetCount,
    required this.restDaysPerWeek,
  });

  final DailySizingMode mode;
  final int activeDayQuestionCount;
  final int reviewTargetCount;
  final int restDaysPerWeek;
}

class DailySizer {
  const DailySizer({
    this.floor = 5,
    this.reviewOnlyTarget = 12,
  });

  final int floor;
  final int reviewOnlyTarget;

  DailySizing size(DailySizingInput input) {
    final restDays = _restDays(input.intensity);
    if (input.actualMastery >= input.targetMastery) {
      return DailySizing(
        mode: DailySizingMode.reviewOnly,
        activeDayQuestionCount: 0,
        reviewTargetCount: reviewOnlyTarget,
        restDaysPerWeek: restDays,
      );
    }

    final safeDaysRemaining = math.max(1, input.daysRemaining);
    final baseline = input.totalQuestions / safeDaysRemaining;
    final multiplier = _intensityMultiplier(input.intensity) *
        switch (input.paceStatus) {
          PaceStatus.behind => 1.25,
          PaceStatus.onPace => 1,
          PaceStatus.ahead => 0.85,
        };
    final activeDaysPerWeek = math.max(1, 7 - restDays);
    final activeDayLoad = baseline * 7 / activeDaysPerWeek * multiplier;
    final capped = math.min(activeDayLoad, baseline * 1.5);
    final questionCount = math.max(floor, capped.ceil());

    return DailySizing(
      mode: DailySizingMode.study,
      activeDayQuestionCount: questionCount,
      reviewTargetCount: math.max(1, (questionCount * 0.6).round()),
      restDaysPerWeek: restDays,
    );
  }

  static int _restDays(StudyPlanIntensity intensity) {
    return switch (intensity) {
      StudyPlanIntensity.light => 2,
      StudyPlanIntensity.standard => 1,
      StudyPlanIntensity.intense => 0,
    };
  }

  static double _intensityMultiplier(StudyPlanIntensity intensity) {
    return switch (intensity) {
      StudyPlanIntensity.light => 0.7,
      StudyPlanIntensity.standard => 1,
      StudyPlanIntensity.intense => 1.4,
    };
  }
}
