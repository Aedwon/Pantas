import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/telemetry/screen_ids.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

/// Logs the screen the student is on, once per change.
///
/// It goes through the `Telemetry` seam it is given, so the consent gate
/// applies: with the switch off, nothing is recorded. The name comes from
/// [screenIdFor], never from the address. Opening the same screen twice in a
/// row (two lessons, a reload of the same page) counts once.
///
/// [onScreen] gets the same screen name at the same moments, but outside the
/// consent gate: it is the hook for the screen counts in the speed and error
/// report, which have their own switch and their own flag. It is told nothing
/// but the name.
class ScreenViewTracker {
  ScreenViewTracker(this._telemetry, {this.onScreen});

  /// Read at the moment of each event, so a consent change takes effect at
  /// once.
  final Telemetry Function() _telemetry;

  /// Told each new screen name. Null when nothing listens.
  final void Function(String screen)? onScreen;
  String? _last;

  void locationChanged(String location) {
    try {
      if (location.isEmpty) return;
      final screen = screenIdFor(location);
      if (screen == startupScreenId || screen == _last) return;
      _last = screen;
      try {
        onScreen?.call(screen);
      } on Object {
        // A failing listener must not stop the usage log below.
      }
      _telemetry()
          .log(TelemetryEvent.screenViewed, properties: {'screen': screen})
          // Analytics must never cause a problem for the screen.
          .ignore();
    } on Object {
      // See above.
    }
  }
}

/// Starts logging every screen change of [router]. Returns the function that
/// stops it. The first screen is logged at once if the router already has one.
VoidCallback attachScreenViewTracker(
  GoRouter router,
  Telemetry Function() telemetry, {
  void Function(String screen)? onScreen,
}) {
  final tracker = ScreenViewTracker(telemetry, onScreen: onScreen);
  void check() {
    try {
      // The top page, pushed ones included. The address bar's location would
      // miss a page that was pushed rather than gone to.
      final top = router.routerDelegate.currentConfiguration.lastOrNull;
      if (top != null) tracker.locationChanged(top.matchedLocation);
    } on Object {
      // The router has no page yet.
    }
  }

  router.routerDelegate.addListener(check);
  check();
  return () => router.routerDelegate.removeListener(check);
}
