import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/route_leave_guard.dart';

/// The running mock's answer to browser Back (see [RouteLeaveGuard]). The mock
/// screen sets `running` while it is on screen.
class MockLeaveGuard extends RouteLeaveGuard {}

final mockLeaveGuardProvider = Provider<MockLeaveGuard>(
  (ref) => MockLeaveGuard(),
);
