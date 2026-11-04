import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/route_leave_guard.dart';

/// The open figure viewer's answer to browser Back (see [RouteLeaveGuard]).
///
/// The viewer sits on top of its page, not at an address of its own, so
/// browser Back would leave the page and take the viewer with it. The page's
/// route asks here first. The viewer sets `running` while it is open, closes
/// itself when asked, and says the page stays. Esc, the close button and Back
/// then do the same thing.
final figureViewerBackProvider = Provider<RouteLeaveGuard>(
  (ref) => RouteLeaveGuard(),
);

/// The guard of the surrounding provider scope, or null when there is none (a
/// bare widget test), in which case Back has nothing to ask.
RouteLeaveGuard? figureViewerBackIn(BuildContext context) => context
    .getInheritedWidgetOfExactType<UncontrolledProviderScope>()
    ?.container
    .read(figureViewerBackProvider);
