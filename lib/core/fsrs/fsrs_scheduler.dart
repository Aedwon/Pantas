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
    if (rating == Rating.again) {
      return _scheduleLapse(prev: prev, now: now);
    }
    return _scheduleSuccess(prev: prev, rating: rating, now: now);
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

  // ----- review paths -----

  ReviewState _scheduleSuccess({
    required ReviewState prev,
    required Rating rating,
    required DateTime now,
  }) {
    final elapsedDays = now.difference(prev.lastReview).inSeconds / 86400.0;
    final r = _retrievability(elapsedDays, prev.stability);

    final hardPenalty = rating == Rating.hard ? weights[15] : 1.0;
    final easyBonus = rating == Rating.easy ? weights[16] : 1.0;

    final factor = math.exp(weights[8]) *
        (11 - prev.difficulty) *
        math.pow(prev.stability, -weights[9]) *
        (math.exp(weights[10] * (1 - r)) - 1) *
        hardPenalty *
        easyBonus;

    final newStability = _clampStability(prev.stability * (1 + factor));
    final newDifficulty = _clampDifficulty(
      _meanRevertedDifficulty(
        prev.difficulty - weights[6] * (rating.grade - 3),
      ),
    );
    final interval = _nextInterval(newStability);

    return prev.copyWith(
      stage: ReviewStage.review,
      stability: newStability,
      difficulty: newDifficulty,
      due: now.add(Duration(milliseconds: (interval * 86400 * 1000).round())),
      lastReview: now,
      reps: prev.reps + 1,
      elapsedDays: elapsedDays,
      scheduledDays: interval,
    );
  }

  ReviewState _scheduleLapse({
    required ReviewState prev,
    required DateTime now,
  }) {
    throw UnimplementedError('lapse path implemented in Task 5');
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
