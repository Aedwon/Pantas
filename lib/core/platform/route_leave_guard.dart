/// Lets a route's `onExit` ask the screen that is running a session whether
/// the student may leave.
///
/// Browser Back (and a typed address) changes the page without a pop, so the
/// screen's own Back handling never runs. The route's `onExit` runs for both,
/// and asks here. The screen sets [running] while it is on screen. The mock and
/// the quiz session share this; give each its own provider.
class RouteLeaveGuard {
  /// The screen that is running a session. A newer screen replaces an older
  /// one.
  Future<bool> Function()? running;

  /// Clears [running] only if it is still [allow].
  void detach(Future<bool> Function() allow) {
    if (running == allow) running = null;
  }

  /// True when nothing is running, or the running screen lets the student go.
  Future<bool> allowLeave() async => await (running?.call() ?? true);
}
