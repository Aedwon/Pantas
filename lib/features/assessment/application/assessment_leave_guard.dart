import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the assessment route's `onExit` ask the open assessment whether the
/// student may leave.
///
/// Browser Back (and a typed address) changes the page without a pop, so the
/// assessment's own leave dialog never shows and the answers are lost. The
/// route's `onExit` runs for both, and asks here. The assessment page sets
/// [running] while it is on screen. Same shape as the mock's guard.
class AssessmentLeaveGuard {
  /// The page that is running an assessment. A newer page replaces an older
  /// one.
  Future<bool> Function()? running;

  /// Clears [running] only if it is still [allow].
  void detach(Future<bool> Function() allow) {
    if (running == allow) running = null;
  }

  /// True when nothing is running, or the page lets the student go.
  Future<bool> allowLeave() async => await (running?.call() ?? true);
}

final assessmentLeaveGuardProvider = Provider<AssessmentLeaveGuard>(
  (ref) => AssessmentLeaveGuard(),
);
