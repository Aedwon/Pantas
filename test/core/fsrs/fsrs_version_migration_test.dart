import 'package:cse_cet_reviewer/core/fsrs/default_weights.dart';
import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Existing progress migration proof under FSRS-6', () {
    const scheduler = FsrsScheduler();

    test('representative 4.5 card advances cleanly on Good', () {
      final t0 = DateTime.utc(2026, 5, 1);
      final t1 = DateTime.utc(2026, 5, 6); // 5 days later
      final prev = ReviewState(
        questionId: 'q_legacy',
        questionVersion: 1,
        stage: ReviewStage.review,
        stability: 8.5,
        difficulty: 4.8,
        due: DateTime.utc(2026, 5, 8),
        lastReview: t0,
        reps: 3,
        lapses: 0,
        elapsedDays: 5.0,
        scheduledDays: 7.0,
      );

      final next = scheduler.next(prev: prev, rating: Rating.good, now: t1);

      expect(next.stability, greaterThan(prev.stability));
      expect(
        next.difficulty,
        inInclusiveRange(kFsrsMinDifficulty, kFsrsMaxDifficulty),
      );
      expect(next.reps, equals(4));
      expect(next.lapses, equals(0));
      expect(next.stage, equals(ReviewStage.review));
      expect(next.due.isAfter(t1), isTrue);
      expect(next.scheduledDays, greaterThanOrEqualTo(1.0));
    });

    test('representative 4.5 card transitions to relearning on Again', () {
      final t0 = DateTime.utc(2026, 5, 1);
      final t1 = DateTime.utc(2026, 5, 6);
      final prev = ReviewState(
        questionId: 'q_legacy',
        questionVersion: 1,
        stage: ReviewStage.review,
        stability: 8.5,
        difficulty: 4.8,
        due: DateTime.utc(2026, 5, 8),
        lastReview: t0,
        reps: 3,
        lapses: 0,
        elapsedDays: 5.0,
        scheduledDays: 7.0,
      );

      final next = scheduler.next(prev: prev, rating: Rating.again, now: t1);

      expect(next.stability, lessThan(prev.stability));
      expect(next.difficulty, greaterThan(prev.difficulty));
      expect(
        next.difficulty,
        inInclusiveRange(kFsrsMinDifficulty, kFsrsMaxDifficulty),
      );
      expect(next.reps, equals(4));
      expect(next.lapses, equals(1));
      expect(next.stage, equals(ReviewStage.relearning));
      expect(next.due.isAfter(t1), isTrue);
    });

    test('extreme boundary states stay bounded and produce no NaN or Inf', () {
      final t0 = DateTime.utc(2026, 5, 1);
      final t1 = DateTime.utc(2026, 5, 10);

      final extremeHigh = ReviewState(
        questionId: 'q_high',
        questionVersion: 1,
        stage: ReviewStage.review,
        stability: 300.0,
        difficulty: 1.0,
        due: DateTime.utc(2026, 8, 1),
        lastReview: t0,
        reps: 15,
        lapses: 0,
        elapsedDays: 9.0,
        scheduledDays: 300.0,
      );

      final extremeLow = ReviewState(
        questionId: 'q_low',
        questionVersion: 1,
        stage: ReviewStage.review,
        stability: 0.1,
        difficulty: 10.0,
        due: DateTime.utc(2026, 5, 2),
        lastReview: t0,
        reps: 1,
        lapses: 5,
        elapsedDays: 9.0,
        scheduledDays: 1.0,
      );

      for (final state in [extremeHigh, extremeLow]) {
        for (final rating in Rating.values) {
          final next = scheduler.next(prev: state, rating: rating, now: t1);
          expect(next.stability.isNaN, isFalse);
          expect(next.stability.isInfinite, isFalse);
          expect(next.difficulty.isNaN, isFalse);
          expect(next.difficulty.isInfinite, isFalse);
          expect(
            next.stability,
            inInclusiveRange(kFsrsMinStability, kFsrsMaxStability),
          );
          expect(
            next.difficulty,
            inInclusiveRange(kFsrsMinDifficulty, kFsrsMaxDifficulty),
          );
        }
      }
    });
  });
}
