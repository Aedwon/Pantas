import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/fsrs/rating_heuristic.dart';

/// Bump this whenever the derivation below changes.
///
/// Every review log row records the version that produced its rating. A
/// parameter fit runs over one version's rows only: ratings from two different
/// heuristics do not mean the same thing, and mixing them silently would fit
/// the schedule to a contradiction.
const int kRatingHeuristicVersion = 1;

abstract final class RatingHeuristic {
  static Rating from({required bool isCorrect, required int responseMs}) {
    return FsrsRatingHeuristic.derive(
      isCorrect: isCorrect,
      responseMs: responseMs,
      currentIntervalDays: 0,
    );
  }
}
