import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

/// The user id every local write already uses. Mirrors `quiz_controller.dart`.
const todayUserId = 'local';

/// What the session panel shows today. One per condition of the day, in the
/// order the panel checks them.
sealed class SessionPanelState {
  const SessionPanelState();
}

/// Nothing has been assessed yet, so there is no basis for a session.
class SessionPanelNeedsAssessment extends SessionPanelState {
  const SessionPanelNeedsAssessment(this.questionCount);

  /// The length `AssessmentQuestionSelector` will actually produce. Never a
  /// constant: it is 21 with seven contributing topics and 18 with eighteen.
  final int questionCount;
}

/// A session was left part way through. It is still open and still counted.
class SessionPanelInProgress extends SessionPanelState {
  const SessionPanelInProgress({
    required this.position,
    required this.total,
    this.topicName,
  });

  /// The one-based question Resume will reopen.
  final int position;
  final int total;

  /// Null for sessions created before the topic was recorded, and for drills
  /// and inline lesson quizzes.
  final String? topicName;
}

/// Everything due, weak and new has been worked through for today.
class SessionPanelCaughtUp extends SessionPanelState {
  const SessionPanelCaughtUp({
    required this.answeredToday,
    required this.correctToday,
  });

  final int answeredToday;
  final int correctToday;
}

/// There is a session to start.
class SessionPanelAvailable extends SessionPanelState {
  const SessionPanelAvailable({
    required this.plan,
    this.prepared,
    this.averageMinutes,
  });

  final TodaySessionPlan plan;

  /// The immutable preparation shown by the panel and consumed by Start.
  /// Null is retained only for isolated presentation tests that construct the
  /// state directly; production panel state always supplies it.
  final PreparedTodaySession? prepared;

  /// The student's own average completed session, or null until seven have
  /// been finished. Never a projection of how long today will take.
  final int? averageMinutes;
}

/// The same prepared sitting the panel presents and Start consumes.
final todaySessionPlanProvider =
    FutureProvider.family<TodaySessionPlan, ExamId>((ref, examId) async {
  final prepared = await ref.watch(todayQuizPreparerProvider).prepare(
        QuizPreparationRequest(userId: quizLocalUserId, examId: examId),
      );
  return prepared.plan;
});

final sessionPanelProvider =
    FutureProvider.family<SessionPanelState, ExamId>((ref, examId) async {
  // Durable completion publishes this lightweight revision from application
  // wiring. Watching it keeps the panel coherent without making application
  // code import presentation providers.
  ref.watch(quizSessionPanelRevisionProvider);
  final sessions = ref.watch(quizSessionRepositoryProvider);

  final open = await sessions.activeFor(userId: todayUserId, examId: examId);
  if (open != null) {
    final topicId = open.topicId;
    final topic = topicId == null
        ? null
        : await ref.watch(contentRepositoryProvider).topicById(topicId);
    final questionIds =
        (jsonDecode(open.questionIdsJson) as List).cast<String>();
    final total = questionIds.length;
    final position = total == 0 ? 0 : (open.currentIndex + 1).clamp(1, total);
    return SessionPanelInProgress(
      position: position,
      total: total,
      topicName: topic?.name,
    );
  }

  final assessed =
      await ref.watch(assessmentRepositoryProvider).hasCompletedForExam(examId);
  if (!assessed) {
    final scopedTopics = await ref.watch(scopedTopicsProvider(examId).future);
    final questions = await AssessmentQuestionSelector(
      ref.watch(contentRepositoryProvider),
      ref.watch(reviewStateRepositoryProvider),
    ).select(examId, topics: scopedTopics);
    return SessionPanelNeedsAssessment(questions.length);
  }

  final prepared = await ref.watch(todayQuizPreparerProvider).prepare(
        QuizPreparationRequest(
          userId: quizLocalUserId,
          examId: examId,
        ),
      );
  final plan = prepared.plan;
  if (plan.isEmpty) {
    final tally = await ref.watch(attemptsRepositoryProvider).tallyForDay(
          examId: examId,
          day: ref.watch(nowProvider)(),
        );
    return SessionPanelCaughtUp(
      answeredToday: tally.answered,
      correctToday: tally.correct,
    );
  }

  return SessionPanelAvailable(
    plan: plan,
    prepared: prepared,
    averageMinutes: await sessions.averageCompletedMinutes(
      userId: todayUserId,
      examId: examId,
    ),
  );
});
