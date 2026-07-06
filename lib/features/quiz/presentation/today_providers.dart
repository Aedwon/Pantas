import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/topic_queue_row.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_queue.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/count_today_backlog.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final todayInputsProvider =
    FutureProvider.family<TodayInputs, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final now = ref.watch(nowProvider)();

  final topics = await content.topicsByExam(examId);
  final questionsByTopic = <TopicId, List<Question>>{};
  for (final topic in topics) {
    questionsByTopic[topic.id] = await content.questionsByTopic(topic.id);
  }
  final questionsById = <QuestionId, Question>{
    for (final questions in questionsByTopic.values)
      for (final question in questions) question.id: question,
  };

  final states = await ref.watch(reviewStateRepositoryProvider).allStates();
  final outcomes = await ref.watch(attemptsRepositoryProvider).questionOutcomes(
        examId: examId,
        now: now,
        window: weaknessWindow,
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

  return TodayInputs(
    topics: [
      for (final topic in topics)
        TopicQueueInput(topicId: topic.id, topicName: topic.name),
    ],
    questionsByTopic: questionsByTopic,
    backlogByTopic: {
      for (final topic in topics)
        topic.id: CountTodayBacklog.forTopic(
          topicId: topic.id,
          questions: questionsByTopic[topic.id] ?? const [],
          states: states,
          questionsById: questionsById,
          outcomes: outcomes,
          capRemaining: capRemaining,
          now: now,
        ),
    },
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
