import 'dart:math' as math;

import 'package:cse_cet_reviewer/core/fsrs/default_weights.dart';
import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';

class FsrsScheduler {
  const FsrsScheduler({
    this.weights = kFsrsDefaultWeights,
    this.targetRetention = kFsrsTargetRetention,
  });

  final List<double> weights;
  final double targetRetention;

  ReviewState next({
    required ReviewState prev,
    required Rating rating,
    required DateTime now,
  }) {
    if (prev.stage == ReviewStage.newCard) {
      return _scheduleNew(prev: prev, rating: rating, now: now);
    }
    throw UnimplementedError('non-new-card path implemented in Task 4');
  }

  // ----- new-card path -----

  ReviewState _scheduleNew({
    required ReviewState prev,
    required Rating rating,
    required DateTime now,
  }) {
    final s0 = _clampStability(weights[rating.grade - 1]);
    final d0 = _initialDifficulty(rating);
    final newStage = (rating == Rating.good || rating == Rating.easy)
        ? ReviewStage.review
        : ReviewStage.learning;
    final interval = _nextInterval(s0);
    return ReviewState(
      questionId: prev.questionId,
      questionVersion: prev.questionVersion,
      stage: newStage,
      stability: s0,
      difficulty: d0,
      due: now.add(Duration(milliseconds: (interval * 86400 * 1000).round())),
      lastReview: now,
      reps: prev.reps + 1,
      lapses: prev.lapses,
      elapsedDays: 0,
      scheduledDays: interval,
    );
  }

  // ----- helpers -----

  double _initialDifficulty(Rating r) =>
      _clampDifficulty(weights[4] - (r.grade - 3) * weights[5]);

  double _retrievability(double elapsedDays, double stability) => math
      .pow(1 + kFsrsFactor * elapsedDays / stability, kFsrsDecay)
      .toDouble();

  double _meanRevertedDifficulty(double d) =>
      weights[7] * weights[4] + (1 - weights[7]) * d;

  double _nextInterval(double stability) {
    final raw = stability *
        (math.pow(targetRetention, 1 / kFsrsDecay).toDouble() - 1) /
        kFsrsFactor;
    return raw.clamp(1 / 1440, kFsrsMaxStability);
  }

  double _clampDifficulty(double d) =>
      d.clamp(kFsrsMinDifficulty, kFsrsMaxDifficulty);

  double _clampStability(double s) =>
      s.clamp(kFsrsMinStability, kFsrsMaxStability);
}
