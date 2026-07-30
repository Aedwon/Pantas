import 'package:pantas/features/study_plan/domain/compute_plan_view.dart';
import 'package:pantas/features/study_plan/domain/plan_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudyPlanExam {
  const StudyPlanExam({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class StudyPlanSignals {
  const StudyPlanSignals({
    required this.startMastery,
    required this.actualMastery,
    required this.targetMastery,
    required this.totalQuestions,
    required this.dueReviewCount,
    this.recommendedTopicId,
    this.recommendedTopicName,
    this.recommendedLessonId,
    this.hasMockWithinTwoWeeks = false,
  });

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

sealed class StudyPlanState {
  const StudyPlanState();
}

class StudyPlanReady extends StudyPlanState {
  const StudyPlanReady(this.view);

  final PlanView view;
}

class StudyPlanNeedsExamSelection extends StudyPlanState {
  const StudyPlanNeedsExamSelection();
}

final studyPlanTodayProvider = Provider<DateTime>((ref) => DateTime.now());

final planPrefsProvider = FutureProvider<PlanPrefs>(
  (ref) => const PlanPrefs(),
);

final studyPlanExamProvider = FutureProvider<StudyPlanExam?>(
  (ref) => throw UnimplementedError('Override studyPlanExamProvider'),
);

final studyPlanSignalsProvider = FutureProvider<StudyPlanSignals>(
  (ref) => throw UnimplementedError('Override studyPlanSignalsProvider'),
);

final studyPlanViewProvider = FutureProvider<StudyPlanState>((ref) async {
  final exam = await ref.watch(studyPlanExamProvider.future);
  if (exam == null) return const StudyPlanNeedsExamSelection();

  final prefs = await ref.watch(planPrefsProvider.future);
  final signals = await ref.watch(studyPlanSignalsProvider.future);
  final today = ref.watch(studyPlanTodayProvider);

  return StudyPlanReady(
    const ComputePlanView().call(
      ComputePlanInput(
        today: today,
        examId: exam.id,
        examName: exam.name,
        prefs: prefs,
        startMastery: signals.startMastery,
        actualMastery: signals.actualMastery,
        targetMastery: signals.targetMastery,
        totalQuestions: signals.totalQuestions,
        dueReviewCount: signals.dueReviewCount,
        recommendedTopicId: signals.recommendedTopicId,
        recommendedTopicName: signals.recommendedTopicName,
        recommendedLessonId: signals.recommendedLessonId,
        hasMockWithinTwoWeeks: signals.hasMockWithinTwoWeeks,
      ),
    ),
  );
});
