import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question_outcome.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/count_today_backlog.dart';
import 'package:flutter_test/flutter_test.dart';

Question question(String id, {String topicId = 'topic_algebra'}) => Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: topicId,
      language: 'en',
      stem: 'stem $id',
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'a', isCorrect: true),
        Choice(id: 'c_b', label: 'B', text: 'b', isCorrect: false),
      ],
      explanation: 'because',
    );

ReviewState state(String questionId, DateTime due) => ReviewState(
      questionId: questionId,
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 3,
      difficulty: 5,
      due: due,
      lastReview: due.subtract(const Duration(days: 1)),
      reps: 3,
      lapses: 0,
      elapsedDays: 1,
      scheduledDays: 1,
    );

void main() {
  final now = DateTime.utc(2026, 8, 2, 9);

  test('a question with no state and cap room is fresh', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: const [],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {},
      capRemaining: 10,
      now: now,
    );

    expect(backlog.fresh.map((q) => q.id), equals(['q_1']));
    expect(backlog.due, isEmpty);
    expect(backlog.weakness, isEmpty);
  });

  test('no fresh questions once the cap is used up', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: const [],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {},
      capRemaining: 0,
      now: now,
    );

    expect(backlog.fresh, isEmpty);
  });

  test('a state due in the past is due, and never also weak', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: [state('q_1', DateTime.utc(2026, 8))],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {
        'q_1': QuestionOutcome(attempts: 10, correct: 1),
      },
      capRemaining: 10,
      now: now,
    );

    expect(backlog.due.map((q) => q.id), equals(['q_1']));
    expect(backlog.weakness, isEmpty);
    expect(backlog.fresh, isEmpty);
  });

  test('a seen, not-due question in a weak topic is weak', () {
    final questions = [question('q_1'), question('q_2')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: [
        state('q_1', DateTime.utc(2026, 8, 20)),
        state('q_2', DateTime.utc(2026, 8, 20)),
      ],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {
        'q_1': QuestionOutcome(attempts: 4, correct: 1),
        'q_2': QuestionOutcome(attempts: 4, correct: 1),
      },
      capRemaining: 10,
      now: now,
    );

    expect(backlog.weakness.map((q) => q.id), equals(['q_1', 'q_2']));
    expect(backlog.due, isEmpty);
  });

  test('a topic answered accurately has no weak questions', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: [state('q_1', DateTime.utc(2026, 8, 20))],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {
        'q_1': QuestionOutcome(attempts: 10, correct: 9),
      },
      capRemaining: 10,
      now: now,
    );

    expect(backlog.weakness, isEmpty);
  });

  test('a topic with too little history has no weak questions', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: [state('q_1', DateTime.utc(2026, 8, 20))],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {
        'q_1': QuestionOutcome(attempts: 4, correct: 0),
      },
      capRemaining: 10,
      now: now,
    );

    expect(backlog.weakness, isEmpty);
  });
}
