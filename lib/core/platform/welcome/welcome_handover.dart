/// The plain HTML Welcome screen in `web/index.html` (B7a). It shows on a first
/// visit while the app downloads. The app tells it when to leave.
abstract interface class WelcomeHandover {
  /// True when this visit opened with the HTML Welcome screen. Onboarding then
  /// starts at the age step, because the learner already saw Welcome.
  bool get shownThisVisit;

  /// The app has drawn something real. [holdForTap] true keeps the screen until
  /// the learner taps Get Started (onboarding is underneath). False removes it
  /// at once, for a learner who is already set up.
  void appReady({required bool holdForTap});

  /// Runs [callback] once the HTML screen has left, or at once when it is not
  /// up. The app uses it to change step the moment the learner taps Get
  /// Started, so the first step slides in like every later one (7W-2).
  void whenScreenLeft(void Function() callback);
}

/// Every platform except the web page that carries the HTML screen.
class NoWelcomeHandover implements WelcomeHandover {
  const NoWelcomeHandover();

  @override
  bool get shownThisVisit => false;

  @override
  void appReady({required bool holdForTap}) {}

  @override
  void whenScreenLeft(void Function() callback) => callback();
}
