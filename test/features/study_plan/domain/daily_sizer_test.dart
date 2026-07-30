import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/study_plan/domain/daily_sizer.dart';
import 'package:pantas/features/study_plan/domain/pace_curve.dart';
import 'package:pantas/features/study_plan/domain/plan_prefs.dart';

void main() {
  DailySizingInput input({
    StudyPlanIntensity intensity = StudyPlanIntensity.standard,
    PaceStatus paceStatus = PaceStatus.onPace,
    int totalQuestions = 140,
    int daysRemaining = 14,
    double actualMastery = 0.35,
    double targetMastery = 0.75,
  }) {
    return DailySizingInput(
      intensity: intensity,
      paceStatus: paceStatus,
      totalQuestions: totalQuestions,
      daysRemaining: daysRemaining,
      actualMastery: actualMastery,
      targetMastery: targetMastery,
    );
  }

  test('standard intensity uses one rest day per week', () {
    final sizing = const DailySizer().size(input());
    expect(sizing.restDaysPerWeek, 1);
  });

  test('light intensity uses two rest days per week', () {
    final sizing =
        const DailySizer().size(input(intensity: StudyPlanIntensity.light));
    expect(sizing.restDaysPerWeek, 2);
  });

  test('intense intensity uses no rest days', () {
    final sizing =
        const DailySizer().size(input(intensity: StudyPlanIntensity.intense));
    expect(sizing.restDaysPerWeek, 0);
  });

  test('per day count respects floor on active days', () {
    final sizing = const DailySizer().size(input(totalQuestions: 3));
    expect(sizing.activeDayQuestionCount, 5);
  });

  test('per day count respects one point five times baseline cap', () {
    final sizing = const DailySizer().size(
      input(
        paceStatus: PaceStatus.behind,
      ),
    );
    expect(sizing.activeDayQuestionCount, lessThanOrEqualTo(15));
  });

  test('behind pace increases active day load without exceeding cap', () {
    final onPace = const DailySizer().size(input());
    final behind =
        const DailySizer().size(input(paceStatus: PaceStatus.behind));

    expect(
      behind.activeDayQuestionCount,
      greaterThan(onPace.activeDayQuestionCount),
    );
    expect(behind.activeDayQuestionCount, lessThanOrEqualTo(15));
  });

  test('all topics at target produces review only sizing', () {
    final sizing = const DailySizer().size(
      input(
        actualMastery: 0.80,
      ),
    );

    expect(sizing.mode, DailySizingMode.reviewOnly);
    expect(sizing.activeDayQuestionCount, 0);
    expect(sizing.reviewTargetCount, greaterThan(0));
  });
}
