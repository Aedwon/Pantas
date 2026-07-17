/// Policy governing when it is appropriate to prompt the student for an app review.
abstract final class ReviewEligibility {
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
