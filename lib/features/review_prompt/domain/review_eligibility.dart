/// How long after seeing the paywall a student is left alone.
///
/// A rating bought at a moment of friction is a worse deal than it looks,
/// and money is the sharpest friction in the app. Nothing shows this
/// number to a student.
const reviewPaywallCoolOff = Duration(hours: 24);

/// What counts as having done well: four in five right.
///
/// This decides whether asking is honest. It is never printed.
const reviewGoodAccuracy = 0.8;

/// When it is right to ask a student for an app review.
abstract final class ReviewEligibility {
  /// Whether a finished run went well enough that the question is a real one.
  static bool finishedWell({required int correct, required int total}) {
    if (total <= 0) return false;
    return correct / total >= reviewGoodAccuracy;
  }

  /// Asked once, ever, and only after something went well.
  static bool shouldAsk({
    required bool hasAskedBefore,
    required bool justFinishedWell,
    required bool sawPaywallRecently,
  }) {
    if (hasAskedBefore || sawPaywallRecently || !justFinishedWell) {
      return false;
    }
    return true;
  }
}
