import 'package:cse_cet_reviewer/features/study_plan/domain/compute_plan_view.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/plan_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ComputePlanInput input({
    DateTime? examDate,
    double? startMastery = 0.30,
    double actualMastery = 0.40,
    double targetMastery = 0.75,
    int totalQuestions = 200,
    int dueReviewCount = 14,
    bool hasMockWithinTwoWeeks = false,
  }) {
    return ComputePlanInput(
      today: DateTime(2026, 5, 21),
      examId: 'cse',
      examName: 'Civil Service Exam',
      prefs: PlanPrefs(
        examDate: examDate ?? DateTime(2026, 8, 21),
        examDateIsProvisional: false,
      ),
      startMastery: startMastery,
      actualMastery: actualMastery,
      targetMastery: targetMastery,
      totalQuestions: totalQuestions,
      dueReviewCount: dueReviewCount,
      recommendedTopicId: 'probability',
      recommendedTopicName: 'Probability',
      recommendedLessonId: 'lesson-probability',
      hasMockWithinTwoWeeks: hasMockWithinTwoWeeks,
    );
  }

  test(
      'today action includes review count lesson recommendation drill recommendation and CTA target',
      () {
    final view = ComputePlanView().call(input());

    expect(view.today.reviewCount, 14);
    expect(view.today.lessonId, 'lesson-probability');
    expect(view.today.drillTopicId, 'probability');
    expect(view.today.ctaPath, '/quiz/today/cse?topicId=probability');
  });

  test('upcoming contains exactly three future days by default', () {
    final view = ComputePlanView().call(input());

    expect(view.upcoming, hasLength(3));
    expect(view.upcoming.first.date, DateTime(2026, 5, 22));
  });

  test('nearest mock appears when a mock week is within two weeks', () {
    final view = ComputePlanView().call(input(hasMockWithinTwoWeeks: true));

    expect(view.nearestMock, isNotNull);
    expect(view.nearestMock!.title, 'Mock week is close');
  });

  test(
      'missing diagnostic uses start mastery fallback and diagnostic prompt copy',
      () {
    final view = ComputePlanView().call(input(startMastery: null));

    expect(view.usedFallbackMastery, isTrue);
    expect(view.today.why, contains('diagnostic'));
  });

  test('exam date too close produces compressed-plan warning', () {
    final view = ComputePlanView().call(input(examDate: DateTime(2026, 5, 25)));

    expect(view.warning, contains('compressed'));
  });

  test('all topics at target shifts today to FSRS review mode', () {
    final view = ComputePlanView().call(
      input(actualMastery: 0.80, targetMastery: 0.75),
    );

    expect(view.today.mode, TodayPlanMode.reviewOnly);
    expect(view.today.drillTopicId, isNull);
  });

  test('coach copy never uses scolding phrases', () {
    final view = ComputePlanView().call(input());
    const banned = ['lazy', 'failed', 'behind again', 'punishment'];

    for (final phrase in banned) {
      expect(view.today.headline.toLowerCase(), isNot(contains(phrase)));
      expect(view.today.why.toLowerCase(), isNot(contains(phrase)));
    }
  });
}
