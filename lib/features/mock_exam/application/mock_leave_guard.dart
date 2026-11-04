import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets a route's `onExit` ask the running mock whether the student may leave.
///
/// Browser Back (and a typed address) changes the page without a pop, so the
/// mock's own Back handling never runs. The route's `onExit` runs for both, and
/// asks here. The mock screen sets [running] while it is on screen.
class MockLeaveGuard {
  /// The screen that is running a mock. A newer screen replaces an older one.
  Future<bool> Function()? running;

  /// Clears [running] only if it is still [allow].
  void detach(Future<bool> Function() allow) {
    if (running == allow) running = null;
  }

  /// True when nothing is running, or the running mock lets the student go.
  Future<bool> allowLeave() async => await (running?.call() ?? true);
}

final mockLeaveGuardProvider = Provider<MockLeaveGuard>(
  (ref) => MockLeaveGuard(),
);
