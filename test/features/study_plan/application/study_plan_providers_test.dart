import 'package:cse_cet_reviewer/features/study_plan/application/study_plan_providers.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/plan_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer container({
    PlanPrefs prefs = const PlanPrefs(),
    StudyPlanExam? exam =
        const StudyPlanExam(id: 'cse', name: 'Civil Service Exam'),
    StudyPlanSignals signals = const StudyPlanSignals(
      startMastery: 0.30,
      actualMastery: 0.40,
      targetMastery: 0.75,
      totalQuestions: 200,
      dueReviewCount: 12,
      recommendedTopicId: 'probability',
      recommendedTopicName: 'Probability',
      recommendedLessonId: 'lesson-probability',
    ),
  }) {
    final container = ProviderContainer(
      overrides: [
        studyPlanTodayProvider.overrideWithValue(DateTime(2026, 5, 21)),
        planPrefsProvider.overrideWith((_) async => prefs),
        studyPlanExamProvider.overrideWith((_) async => exam),
        studyPlanSignalsProvider.overrideWith((_) async => signals),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('studyPlanViewProvider computes a plan for the active exam', () async {
    final view = await container(
      prefs: PlanPrefs(examDate: DateTime(2026, 8, 21)),
    ).read(studyPlanViewProvider.future);

    expect(view, isA<StudyPlanReady>());
    expect((view as StudyPlanReady).view.examId, 'cse');
  });

  test(
      'studyPlanViewProvider emits selection-needed state without an active exam',
      () async {
    final state =
        await container(exam: null).read(studyPlanViewProvider.future);

    expect(state, isA<StudyPlanNeedsExamSelection>());
  });

  test('changing intensity invalidates and recomputes the plan', () async {
    final standard = await container(
      prefs: PlanPrefs(examDate: DateTime(2026, 8, 21)),
      signals: const StudyPlanSignals(
        startMastery: 0.30,
        actualMastery: 0.40,
        targetMastery: 0.75,
        totalQuestions: 900,
        dueReviewCount: 12,
        recommendedTopicId: 'probability',
        recommendedTopicName: 'Probability',
      ),
    ).read(studyPlanViewProvider.future) as StudyPlanReady;
    final intense = await container(
      prefs: PlanPrefs(
        examDate: DateTime(2026, 8, 21),
        intensity: StudyPlanIntensity.intense,
      ),
      signals: const StudyPlanSignals(
        startMastery: 0.30,
        actualMastery: 0.40,
        targetMastery: 0.75,
        totalQuestions: 900,
        dueReviewCount: 12,
        recommendedTopicId: 'probability',
        recommendedTopicName: 'Probability',
      ),
    ).read(studyPlanViewProvider.future) as StudyPlanReady;

    expect(
      intense.view.upcoming.first.estimatedQuestionCount,
      greaterThan(standard.view.upcoming.first.estimatedQuestionCount),
    );
  });

  test('provider overrides can inject fake mastery and content volume',
      () async {
    final ready = await container(
      prefs: PlanPrefs(examDate: DateTime(2026, 8, 21)),
      signals: const StudyPlanSignals(
        startMastery: 0.75,
        actualMastery: 0.80,
        targetMastery: 0.75,
        totalQuestions: 10,
        dueReviewCount: 3,
        recommendedTopicId: 'logic',
        recommendedTopicName: 'Logic',
      ),
    ).read(studyPlanViewProvider.future) as StudyPlanReady;

    expect(ready.view.today.drillTopicId, isNull);
  });
}
