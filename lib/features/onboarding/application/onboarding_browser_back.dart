import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the router tell the open onboarding page that the browser's Back (or
/// Forward) tried to leave it.
///
/// Every onboarding step lives at one address, so a browser Back lands on the
/// page before onboarding. The router sends that address straight back to
/// onboarding, and the student saw nothing happen. The router calls
/// [requested] when it does that, and the page goes back one step, the same as
/// its own Back button.
class OnboardingBrowserBack {
  /// The onboarding page that is on screen. A newer page replaces an older one.
  VoidCallback? handler;

  /// Clears [handler] only if it is still [attached].
  void detach(VoidCallback attached) {
    if (handler == attached) handler = null;
  }

  /// The browser asked to leave onboarding. Does nothing when no page is open.
  void requested() => handler?.call();
}

final onboardingBrowserBackProvider = Provider<OnboardingBrowserBack>(
  (ref) => OnboardingBrowserBack(),
);
