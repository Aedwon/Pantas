import 'package:cse_cet_reviewer/core/fsrs/rating.dart';

abstract final class FsrsRatingHeuristic {
  static const int slowThresholdMs = 25000;
  static const int easyThresholdMs = 8000;
  static const double matureIntervalDays = 21;

  static Rating derive({
    required bool isCorrect,
    required int responseMs,
    required double currentIntervalDays,
    int? medianResponseMs,
  }) {
    if (!isCorrect) return Rating.again;

    final medianSlowThreshold =
        medianResponseMs == null ? slowThresholdMs : medianResponseMs * 2;
    final slowThreshold = medianSlowThreshold > slowThresholdMs
        ? medianSlowThreshold
        : slowThresholdMs;

    if (responseMs > slowThreshold) return Rating.hard;
    if (responseMs < easyThresholdMs &&
        currentIntervalDays >= matureIntervalDays) {
      return Rating.easy;
    }
    return Rating.good;
  }
}
