/// The seam in front of the store's own review popup.
///
/// The popup is the platform's, not ours. It can decline to appear and we
/// never find out whether a student rated anything, which is why the
/// "asked once, ever" record is kept on our side.
abstract interface class AppReviewGateway {
  /// Whether this device can show the store's popup at all.
  Future<bool> isAvailable();

  /// Asks the platform to show it. Returns when the request is made.
  Future<void> requestReview();
}

/// The default everywhere the store is not reachable: tests, and any build
/// without the platform plugin behind it.
class UnavailableReviewGateway implements AppReviewGateway {
  const UnavailableReviewGateway();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> requestReview() async {}
}
