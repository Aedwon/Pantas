import 'package:collection/collection.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/passage_set_filler.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/selectors/recency_filter.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

abstract final class SittingPlanner {
  /// The next sitting's question ids from today's remaining work, in order.
  static List<QuestionId> next({
    required DayPlan remaining,
    required Set<LessonId> knownLessonIds,
    required Set<LessonId> readLessonIds,
    required Map<QuestionId, RoadmapQuestion> questionsById,
    required int sessionLength,
    required QuizOrdering ordering,
    required TopicId vocabularyTopicId,
    required List<TopicId> rankedTopics,
  }) {
    final size = sessionLength == QuizPreferences.allDueSessionLength
        ? remaining.questionCount
        : sessionLength;
    if (size <= 0) return [];

    final todayLessons = remaining.lessonIds.toSet();
    final available = <RoadmapQuestion>[];
    final rest = <RoadmapQuestion>[];
    final heldBack = <RoadmapQuestion>[];
    // A question withdrawn since the day was planned has no metadata; it is
    // skipped rather than failing the whole sitting.
    for (final id in remaining.newQuestionIds) {
      final question = questionsById[id];
      if (question == null) continue;
      final lessonId = question.lessonId;
      if (lessonId == null ||
          !knownLessonIds.contains(lessonId) ||
          readLessonIds.contains(lessonId)) {
        available.add(question);
      } else if (todayLessons.contains(lessonId)) {
        heldBack.add(question);
      } else {
        rest.add(question);
      }
    }
    final candidates = [
      for (final id in remaining.reviewQuestionIds)
        if (questionsById[id] case final question?) question,
      ...available,
      ...rest,
      ...heldBack,
    ];
    final sets = <PassageId, List<RoadmapQuestion>>{};
    for (final question in candidates) {
      final passageId = question.passageId;
      if (passageId != null && passageId.isNotEmpty) {
        sets.putIfAbsent(passageId, () => []).add(question);
      }
    }

    final drawn = <RoadmapQuestion>[];
    final used = <QuestionId>{};
    final visitedPassages = <PassageId>{};
    for (final question in candidates) {
      if (drawn.length >= size) break;
      if (used.contains(question.id)) continue;
      final passageId = question.passageId;
      final hasPassage = passageId != null && passageId.isNotEmpty;
      if (hasPassage && !visitedPassages.add(passageId)) continue;

      // Fill one draw unit at a time so the filler cannot put a later set
      // before an earlier review or free-standing question.
      final filled = PassageSetFiller.fillGeneric<RoadmapQuestion>(
        size: size - drawn.length,
        freeStanding: hasPassage ? const [] : [question],
        setsByPassageId: hasPassage ? {passageId: sets[passageId]!} : const {},
      );
      drawn.addAll(filled);
      used.addAll(filled.map((question) => question.id));
    }

    // The existing reordering helpers accept Question. These temporary
    // values carry only metadata; no content is read or hydrated here.
    final questions = drawn.map(_metadataQuestion).toList();
    final ranks = {
      for (var i = 0; i < rankedTopics.length; i++) rankedTopics[i]: i,
    };
    int rank(TopicId id) => ranks[id] ?? rankedTopics.length;

    final List<Question> arranged;
    switch (ordering) {
      case QuizOrdering.blocked:
        mergeSort<Question>(
          questions,
          compare: (a, b) => rank(a.topicId).compareTo(rank(b.topicId)),
        );
        arranged = questions;
      case QuizOrdering.interleavedTail:
        final counts = <TopicId, int>{};
        for (final question in questions) {
          counts.update(
            question.topicId,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }
        final topics = counts.keys.toList();
        mergeSort<TopicId>(
          topics,
          compare: (a, b) {
            final countOrder = counts[b]!.compareTo(counts[a]!);
            return countOrder != 0 ? countOrder : rank(a).compareTo(rank(b));
          },
        );
        final firstTopic = topics.firstOrNull;
        arranged = [
          ...questions.where((question) => question.topicId == firstTopic),
          ...RecencyFilter.noConsecutiveSameTopic(
            questions
                .where((question) => question.topicId != firstTopic)
                .toList(),
          ),
        ];
      case QuizOrdering.fullyMixed:
        arranged = RecencyFilter.noConsecutiveSameTopic(questions);
    }

    final grouped = groupPassageSets(arranged);
    final vocabulary = grouped
        .where((question) => question.topicId == vocabularyTopicId)
        .toList();
    final result = <QuestionId>[];
    var vocabularyEmitted = false;
    for (final question in grouped) {
      if (question.topicId != vocabularyTopicId) {
        result.add(question.id);
      } else if (!vocabularyEmitted) {
        result.addAll(vocabulary.map((question) => question.id));
        vocabularyEmitted = true;
      }
    }
    return result;
  }
}

Question _metadataQuestion(RoadmapQuestion question) => Question(
      id: question.id,
      version: 0,
      examIds: const [],
      topicId: question.topicId,
      language: '',
      stem: '',
      choices: const [],
      explanation: '',
      lessonId: question.lessonId,
      passageId: question.passageId,
    );
