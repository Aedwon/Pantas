import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReviewState round-trips JSON', () {
    final state = ReviewState(
      questionId: 'q_1',
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 12.5,
      difficulty: 4.1,
      due: DateTime.utc(2026, 5, 12),
      lastReview: DateTime.utc(2026, 5, 9),
      reps: 3,
      lapses: 0,
      elapsedDays: 3,
      scheduledDays: 7,
    );
    expect(ReviewState.fromJson(state.toJson()), equals(state));
  });

  test('seed() creates a "new"-stage state with sensible defaults', () {
    final now = DateTime.utc(2026, 5, 9);
    final seed = ReviewState.seed(
      questionId: 'q_1',
      questionVersion: 1,
      now: now,
    );
    expect(seed.stage, equals(ReviewStage.newCard));
    expect(seed.stability, equals(0));
    expect(seed.difficulty, equals(0));
    expect(seed.due, equals(now));
    expect(seed.reps, equals(0));
    expect(seed.lapses, equals(0));
  });
}
