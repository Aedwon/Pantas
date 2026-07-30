import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/question_outcome.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/features/quiz/domain/selectors/fsrs_due_selector.dart';
import 'package:pantas/features/quiz/domain/selectors/new_card_selector.dart';
import 'package:pantas/features/quiz/domain/selectors/weakness_selector.dart';

/// One topic's questions split three ways. The lists never overlap.
class TopicBacklog {
  const TopicBacklog({
    required this.due,
    required this.weakness,
    required this.fresh,
  });

  static const empty = TopicBacklog(due: [], weakness: [], fresh: []);

  final List<Question> due;
  final List<Question> weakness;

  /// Named `fresh` because `new` is reserved.
  final List<Question> fresh;

  int get total => due.length + weakness.length + fresh.length;
}

/// Splits a topic into what is due, what is weak and what has never been seen.
///
/// The three lists are kept disjoint on purpose. A due question inside a weak
/// topic would otherwise be counted in both, and the session panel's
/// composition line would not add up to the length of the session it
/// describes.
abstract final class CountTodayBacklog {
  static TopicBacklog forTopic({
    required TopicId topicId,
    required List<Question> questions,
    required List<ReviewState> states,
    required Map<QuestionId, Question> questionsById,
    required Map<QuestionId, QuestionOutcome> outcomes,
    required int capRemaining,
    required DateTime now,
  }) {
    final due = FsrsDueSelector.select(
      states: states,
      questionsById: questionsById,
      now: now,
      topicId: topicId,
    );
    final dueIds = {for (final question in due) question.id};
    final seenIds = {for (final state in states) state.questionId};

    var attempts = 0;
    var correct = 0;
    for (final question in questions) {
      final outcome = outcomes[question.id];
      if (outcome == null) continue;
      attempts += outcome.attempts;
      correct += outcome.correct;
    }
    // A topic nobody has answered is not weak, it is unknown. Reading it as
    // 100% accurate keeps it out of the weakness bucket without a special case.
    final accuracy = attempts == 0 ? 1.0 : correct / attempts;

    final weakness = WeaknessSelector.select([
      for (final question in questions)
        if (seenIds.contains(question.id) && !dueIds.contains(question.id))
          WeaknessCandidate(
            question: question,
            topicId: topicId,
            rollingAccuracy: accuracy,
            attemptCount: attempts,
          ),
    ]);

    final fresh = NewCardSelector.select(
      questions: questions,
      seenQuestionIds: seenIds,
      capRemaining: capRemaining,
      limit: capRemaining,
      topicId: topicId,
    );

    return TopicBacklog(due: due, weakness: weakness, fresh: fresh);
  }
}
