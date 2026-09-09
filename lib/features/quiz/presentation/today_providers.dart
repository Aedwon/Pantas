import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/question_selection_row.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/quiz/domain/models/topic_queue_row.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_queue.dart';
import 'package:pantas/features/quiz/domain/use_cases/count_today_backlog.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

/// The user id every local write already uses. Mirrors `quiz_controller.dart`.
const todayUserId = 'local';

/// How far back the weakness reading looks.
const weaknessWindow = Duration(days: 30);

/// Everything the panel and the queue read, gathered once so the two never
/// disagree about the state of the day.
class TodayInputs {
  const TodayInputs({
    required this.topics,
    required this.questionsByTopic,
    required this.backlogByTopic,
    required this.now,
  });

  final List<TopicQueueInput> topics;
  final Map<TopicId, List<Question>> questionsByTopic;
  final Map<TopicId, TopicBacklog> backlogByTopic;
  final DateTime now;

  List<Question> get allQuestions =>
      [for (final questions in questionsByTopic.values) ...questions];
}

Question _selectionQuestion(QuestionSelectionRow row, ExamId examId) {
  return Question(
    id: row.id,
    version: row.version,
    examIds: [examId],
    topicId: row.topicId,
    language: '',
    stem: '',
    choices: const [],
    explanation: '',
    lessonId: row.lessonId,
    passageId: row.passageId,
    figureSpecJson: row.hasFigure ? '{}' : null,
  );
}

final todayInputsProvider =
    FutureProvider.family<TodayInputs, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final now = ref.watch(nowProvider)();

  final topics = await ref.watch(scopedTopicsProvider(examId).future);
  final questionsByTopic = <TopicId, List<Question>>{};
  for (final topic in topics) {
    final rows = await content.selectionRowsByTopic(topic.id);
    questionsByTopic[topic.id] = [
      for (final row in rows) _selectionQuestion(row, examId),
    ];
  }
  final questionsById = <QuestionId, Question>{
    for (final questions in questionsByTopic.values)
      for (final question in questions) question.id: question,
  };

  final states = await ref.watch(reviewStateRepositoryProvider).allStates();
  final outcomes = await ref.watch(attemptsRepositoryProvider).questionOutcomes(
        examId: examId,
        now: now,
      );

  final preferences = await ref.watch(quizPreferencesRepositoryProvider).read();
  final introduced =
      await ref.watch(newCardIntroRepositoryProvider).countForDay(
            userId: todayUserId,
            examId: examId,
            day: now,
          );
  final capRemaining =
      (preferences.newCardCap - introduced).clamp(0, preferences.newCardCap);

  var sharedCapRemaining = capRemaining;
  final backlogByTopic = <TopicId, TopicBacklog>{};
  for (final topic in topics) {
    final backlog = CountTodayBacklog.forTopic(
      topicId: topic.id,
      questions: questionsByTopic[topic.id] ?? const [],
      states: states,
      questionsById: questionsById,
      outcomes: outcomes,
      capRemaining: sharedCapRemaining,
      now: now,
    );
    backlogByTopic[topic.id] = backlog;
    sharedCapRemaining =
        (sharedCapRemaining - backlog.fresh.length).clamp(0, capRemaining);
  }

  return TodayInputs(
    topics: [
      for (final topic in topics)
        TopicQueueInput(topicId: topic.id, topicName: topic.name),
    ],
    questionsByTopic: questionsByTopic,
    backlogByTopic: backlogByTopic,
    now: now,
  );
});

/// Every topic in the exam with its backlog, largest first, the largest marked
/// recommended. The recommended row is the topic today's session is named
/// after.
final todayTopicQueueProvider =
    FutureProvider.family<List<TopicQueueRow>, ExamId>((ref, examId) async {
  final inputs = await ref.watch(todayInputsProvider(examId).future);
  return BuildTodayQueue.call(
    topics: inputs.topics,
    dueCounts: {
      for (final entry in inputs.backlogByTopic.entries)
        entry.key: entry.value.due.length,
    },
    weaknessCounts: {
      for (final entry in inputs.backlogByTopic.entries)
        entry.key: entry.value.weakness.length,
    },
    newCounts: {
      for (final entry in inputs.backlogByTopic.entries)
        entry.key: entry.value.fresh.length,
    },
  );
});

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
    required this.answered,
    required this.total,
    this.topicName,
  });

  final int answered;
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
  const SessionPanelAvailable({required this.plan, this.averageMinutes});

  final TodaySessionPlan plan;

  /// The student's own average completed session, or null until seven have
  /// been finished. Never a projection of how long today will take.
  final int? averageMinutes;
}

/// The plan the Start button will create, built from the recommended topic.
final todaySessionPlanProvider =
    FutureProvider.family<TodaySessionPlan, ExamId>((ref, examId) async {
  final inputs = await ref.watch(todayInputsProvider(examId).future);
  final queue = await ref.watch(todayTopicQueueProvider(examId).future);
  if (queue.isEmpty) return TodaySessionPlan.empty;

  final named = queue.first;
  if (named.totalCount == 0) return TodaySessionPlan.empty;

  final preferences = await ref.watch(quizPreferencesRepositoryProvider).read();
  final due = <Question>[];
  final weakness = <Question>[];
  final fresh = <Question>[];
  for (final backlog in inputs.backlogByTopic.values) {
    due.addAll(backlog.due);
    weakness.addAll(backlog.weakness);
    fresh.addAll(backlog.fresh);
  }

  final selectionPlan = BuildTodayPlan.call(
    due: due,
    weakness: weakness,
    fresh: fresh,
    allQuestions: inputs.allQuestions,
    preferences: preferences,
    topicId: named.topicId,
    topicName: named.topicName,
  );
  if (selectionPlan.isEmpty) return selectionPlan;

  final hydrated =
      await ref.watch(contentRepositoryProvider).hydrateSelectedQuestions(
    [for (final question in selectionPlan.questions) question.id],
  );
  final hydratedIds = {for (final question in hydrated) question.id};
  final dueIds = {for (final question in due) question.id};
  final weaknessIds = {for (final question in weakness) question.id};
  final freshIds = {for (final question in fresh) question.id};
  return TodaySessionPlan(
    questions: hydrated,
    dueCount: hydratedIds.where(dueIds.contains).length,
    weaknessCount: hydratedIds.where(weaknessIds.contains).length,
    freshCount: hydratedIds.where(freshIds.contains).length,
    topicId: selectionPlan.topicId,
    topicName: selectionPlan.topicName,
  );
});

final sessionPanelProvider =
    FutureProvider.family<SessionPanelState, ExamId>((ref, examId) async {
  final sessions = ref.watch(quizSessionRepositoryProvider);

  final open = await sessions.activeFor(userId: todayUserId, examId: examId);
  if (open != null) {
    final topicId = open.topicId;
    final topic = topicId == null
        ? null
        : await ref.watch(contentRepositoryProvider).topicById(topicId);
    final questionIds =
        (jsonDecode(open.questionIdsJson) as List).cast<String>();
    return SessionPanelInProgress(
      answered: open.currentIndex,
      total: questionIds.length,
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

  final plan = await ref.watch(todaySessionPlanProvider(examId).future);
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
    averageMinutes: await sessions.averageCompletedMinutes(
      userId: todayUserId,
      examId: examId,
    ),
  );
});
