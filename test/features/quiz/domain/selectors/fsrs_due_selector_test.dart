import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/selectors/fsrs_due_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sorts overdue cards by due date then lapses', () {
    final now = DateTime.utc(2026, 5, 18);
    final questions = {
      'q1': _question('q1', 'topic_a'),
      'q2': _question('q2', 'topic_a'),
      'q3': _question('q3', 'topic_a'),
    };

    final selected = FsrsDueSelector.select(
      states: [
        _state('q1', due: now.subtract(const Duration(days: 1)), lapses: 1),
        _state('q2', due: now.subtract(const Duration(days: 2)), lapses: 0),
        _state('q3', due: now.subtract(const Duration(days: 1)), lapses: 3),
      ],
      questionsById: questions,
      now: now,
    );

    expect(selected.map((question) => question.id), equals(['q2', 'q3', 'q1']));
  });

  test('filters orphaned FSRS rows when question metadata is missing', () {
    final now = DateTime.utc(2026, 5, 18);

    final selected = FsrsDueSelector.select(
      states: [_state('missing', due: now.subtract(const Duration(days: 1)))],
      questionsById: const {},
      now: now,
    );

    expect(selected, isEmpty);
  });
}

Question _question(String id, String topicId) => Question(
      id: id,
      version: 1,
      examIds: const ['exam'],
      topicId: topicId,
      language: 'en',
      stem: id,
      choices: const [
        Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'Because.',
    );

ReviewState _state(
  String questionId, {
  required DateTime due,
  int lapses = 0,
}) =>
    ReviewState(
      questionId: questionId,
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 1,
      difficulty: 5,
      due: due,
      lastReview: due.subtract(const Duration(days: 1)),
      reps: 1,
      lapses: lapses,
      elapsedDays: 1,
      scheduledDays: 1,
    );
