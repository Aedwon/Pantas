import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/review_state.dart';

void main() {
  // These expectations were computed outside Dart, from the FSRS-6 formulas
  // as they appear in the reference implementation's source, and not from this
  // scheduler. That is the whole point: a test written from the code under
  // test agrees with a wrong formula perfectly well.
  //
  // Inputs throughout: stability 10, difficulty 5, elapsed 10 days, so
  // retrievability is exactly 0.9.
  test('stability matches values computed outside this codebase', () {
    const s = FsrsScheduler();
    final now = DateTime.utc(2026, 8, 9);
    ReviewState prev(double stability, double difficulty, double elapsed) =>
        ReviewState(
          questionId: 'q',
          questionVersion: 1,
          stage: ReviewStage.review,
          stability: stability,
          difficulty: difficulty,
          due: now.subtract(const Duration(days: 1)),
          lastReview: now.subtract(Duration(days: elapsed.round())),
          reps: 3,
          lapses: 0,
          elapsedDays: elapsed,
          scheduledDays: 10,
        );

    final good = s.next(prev: prev(10, 5, 10), rating: Rating.good, now: now);
    final easy = s.next(prev: prev(10, 5, 10), rating: Rating.easy, now: now);
    final again = s.next(prev: prev(10, 5, 10), rating: Rating.again, now: now);

    expect(good.stability, closeTo(32.026729, 0.0001));
    expect(easy.stability, closeTo(51.253862, 0.0001));
    expect(again.stability, closeTo(1.391987, 0.0001));
  });
}
