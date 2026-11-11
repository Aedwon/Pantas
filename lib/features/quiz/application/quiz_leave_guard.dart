import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/route_leave_guard.dart';

/// The running quiz session's answer to browser Back (see [RouteLeaveGuard]).
/// The quiz page sets `running` while a session is on screen, so Back shows
/// the same leave dialog as Esc and the close button.
final quizLeaveGuardProvider = Provider<RouteLeaveGuard>(
  (ref) => RouteLeaveGuard(),
);
