import 'dart:math' as math;

import 'package:pantas/core/fsrs/default_weights.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/review_state.dart';

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
    final double newStability;
    if (elapsedDays < 1.0) {
      // Same-day review formula: S * exp(w[17] * (G - 3 + w[18])) * S^(-w[19])
      newStability = _clampStability(
        prev.stability *
            math.exp(weights[17] * (rating.grade - 3 + weights[18])) *
            math.pow(prev.stability, -weights[19]).toDouble(),
      );
    } else {
      final r = _retrievability(elapsedDays, prev.stability);
      final hardPenalty = rating == Rating.hard ? weights[15] : 1.0;
      final easyBonus = rating == Rating.easy ? weights[16] : 1.0;
      final factor = math.exp(weights[8]) *
          (11.0 - prev.difficulty) *
          math.pow(prev.stability, -weights[9]) *
          (math.exp((1.0 - r) * weights[10]) - 1.0) *
          hardPenalty *
          easyBonus;
      newStability = _clampStability(prev.stability * (1.0 + factor));
    }

    final newDifficulty = _nextDifficulty(prev.difficulty, rating);
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
    final elapsedDays = now.difference(prev.lastReview).inSeconds / 86400.0;
    final r = _retrievability(elapsedDays, prev.stability);

    final lapseStability = weights[11] *
        math.pow(prev.difficulty, -weights[12]).toDouble() *
        (math.pow(prev.stability + 1.0, weights[13]).toDouble() - 1.0) *
        math.exp((1.0 - r) * weights[14]);

    final shortTermCap = prev.stability * math.exp(weights[17] * weights[18]);
    final newStability =
        _clampStability(math.min(lapseStability, shortTermCap));

    final newDifficulty = _nextDifficulty(prev.difficulty, Rating.again);
    final interval = _nextInterval(newStability);

    return prev.copyWith(
      stage: ReviewStage.relearning,
      stability: newStability,
      difficulty: newDifficulty,
      due: now.add(Duration(milliseconds: (interval * 86400 * 1000).round())),
      lastReview: now,
      reps: prev.reps + 1,
      lapses: prev.lapses + 1,
      elapsedDays: elapsedDays,
      scheduledDays: interval,
    );
  }

  // ----- helpers -----

  double _initialDifficulty(Rating r) => _clampDifficulty(
        weights[4] - math.exp(weights[5] * (r.grade - 1)) + 1.0,
      );

  double _retrievability(double elapsedDays, double stability) {
    final decay = fsrsDecay(weights[20]);
    final factor = fsrsFactor(weights[20]);
    return math.pow(1.0 + factor * elapsedDays / stability, decay).toDouble();
  }

  double _nextDifficulty(double d, Rating r) {
    final delta = -(weights[6] * (r.grade - 3));
    final dampedDelta = delta * (10.0 - d) / 9.0;
    final updatedD = d + dampedDelta;
    final d0Easy = _initialDifficulty(Rating.easy);
    final meanReverted = weights[7] * d0Easy + (1.0 - weights[7]) * updatedD;
    return _clampDifficulty(meanReverted);
  }

  double _nextInterval(double stability) {
    final decay = fsrsDecay(weights[20]);
    final factor = fsrsFactor(weights[20]);
    final raw = (stability / factor) *
        (math.pow(targetRetention, 1.0 / decay).toDouble() - 1.0);
    // The literal stays a double: as an int, math.max returns num and the
    // return type breaks. dart fix offers exactly that change, so the ignore
    // is here to stop it being applied again.
    // ignore: prefer_int_literals
    final double atLeastOneDay = math.max(1.0, raw.roundToDouble());
    return atLeastOneDay.clamp(1.0, kFsrsMaxStability);
  }

  double _clampDifficulty(double d) =>
      d.clamp(kFsrsMinDifficulty, kFsrsMaxDifficulty);

  double _clampStability(double s) =>
      s.clamp(kFsrsMinStability, kFsrsMaxStability);
}
