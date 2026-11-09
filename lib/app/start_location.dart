import 'package:flutter/foundation.dart';

String? _start;
var _captured = false;
var _taken = false;

/// Records the page address before routing rewrites it, so a reload or an
/// address opened directly keeps the student on that page. Native builds
/// have no address and always start at Home.
///
/// Only the first call counts. A startup retry calls this again, but by then
/// the startup screen has rewritten the address to the root.
void rememberStartLocation(Uri url, {bool isWeb = kIsWeb}) {
  if (_captured) return;
  _captured = true;
  _start = startLocationFor(url, isWeb: isWeb);
}

@visibleForTesting
void forgetStartLocation() {
  _start = null;
  _captured = false;
  _taken = false;
}

/// Where the first router starts. Looking does not use it up.
String get initialRouterLocation => _start ?? '/home';

/// Where a router being built starts. The address is for the first router
/// only: error recovery rebuilds the router, and sending the student back to
/// an old payment return or the page that just failed would repeat the
/// problem. Later routers start at Home. The guardian link stays, so recovery
/// on the guardian page stays there.
String takeInitialRouterLocation() {
  final start = initialRouterLocation;
  final keeps = Uri.parse(start).path == '/guardian';
  if (_taken && !keeps) return '/home';
  _taken = true;
  return start;
}

/// The router's first location for a page opened at [url].
///
/// An address is honored as typed, path and query, with the fragment dropped.
/// A few addresses are not honored, because opening them cold would start
/// something or land on a screen that cannot stand alone. These are start
/// rules only: moving to the same routes inside the app is unchanged.
///
/// Segments are decoded and compared in lower case, with empty ones removed,
/// so a trailing slash, odd case or percent-encoding cannot slip past a rule.
String startLocationFor(Uri url, {bool isWeb = kIsWeb}) {
  if (!isWeb) return '/home';
  // A leading double slash reads as another host, not as a path.
  if (url.path.startsWith('//')) return '/home';
  final segments = [
    for (final segment in url.pathSegments)
      if (segment.isNotEmpty) segment,
  ];
  if (segments.isEmpty) return '/home';
  // An encoded slash hides a path inside one segment. Check it as typed
  // first, then as the path it would spell.
  final flat = [
    for (final segment in segments)
      for (final part in segment.split('/'))
        if (part.isNotEmpty) part,
  ];
  final mapped = _notHonored(segments, url) ??
      (flat.length == segments.length ? null : _notHonored(flat, url));
  if (mapped != null) return mapped;
  return url.hasQuery ? '${url.path}?${url.query}' : url.path;
}

/// The location to start at instead of the address made of [segments], or
/// null when the address is honored.
String? _notHonored(List<String> segments, Uri url) {
  final path = [for (final segment in segments) segment.toLowerCase()];
  final first = path.first;
  final second = path.length > 1 ? path[1] : '';
  final third = path.length > 2 ? path[2] : '';
  switch (first) {
    // Nothing links to the ending screen, and it shows for any topic.
    case 'study' when second == 'ending':
      return '/study';
    case 'quiz':
      switch (second) {
        // Each load creates a session and can close a paused one. The Quiz
        // tab offers to resume.
        case 'quick' || 'retake' || 'inline':
          return '/quiz';
        // The run page needs the session its picker prepared.
        case 'practice' when path.length == 4 && path[3] == 'run':
          return Uri(pathSegments: ['', 'quiz', 'practice', segments[2]]).path;
        // Opening it would start a real mock. The Quiz tab offers to resume
        // an open one.
        case 'mock' when third == 'start':
          return '/quiz';
        // Setup is chosen for one exam, so it cannot open without one.
        case 'mock' when third == 'setup':
          return (url.queryParameters['examId'] ?? '').isEmpty ? '/quiz' : null;
      }
    case 'settings':
      switch (second) {
        // An upgrade is only meaningful from the picker that starts it.
        case 'exam' when third == 'upgrade':
          return '/settings/exam/change';
        // A destructive screen is never a place to land cold. The age re-check
        // reports back to the Account page that opened it.
        case 'account' when third == 'delete' || third == 'adult-check':
          return '/settings/account';
        // Developer tools are not a place to land.
        case '_debug' || '_gallery':
          return '/settings';
      }
    // The custom track steps carry state from the step before.
    case 'onboarding' when second == 'custom':
      return '/onboarding';
    // Opening an assessment cold would restart it. Its results are safe.
    case 'assessment' when path.length == 2:
      return '/home';
    // The contact form follows the waiting page.
    case 'guardian' when second == 'contact':
      return '/guardian/waiting';
    // Nothing links to the reveal.
    case 'wrapped':
      return '/home';
  }
  return null;
}
