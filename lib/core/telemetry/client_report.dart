import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/telemetry/client_report_env_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/telemetry/client_report_env_web.dart'
    as env;
import 'package:pantas/core/telemetry/perf_timeline.dart';

/// Where a finished report goes. Tests replace it.
// ignore: one_member_abstracts
abstract interface class ClientReportSender {
  Future<void> send(Map<String, Object?> payload);
}

/// Sends a report to the `reportClientTelemetry` callable. It needs the App
/// Check token the other callables use, and an account that is signed in or
/// anonymous. The report itself names no account.
class FirebaseClientReportSender implements ClientReportSender {
  const FirebaseClientReportSender();

  static const _name = 'reportClientTelemetry';

  @override
  Future<void> send(Map<String, Object?> payload) async {
    await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
        .httpsCallable(_name, options: callableOptionsFor(_name))
        .call<Object?>(payload);
  }
}

/// What the browser says about itself when a report is built.
@immutable
class ClientReportContext {
  const ClientReportContext({
    required this.build,
    required this.visit,
    required this.browser,
    required this.mobile,
    required this.viewportWidth,
  });

  final String build;

  /// `first`, `return` or `after_deploy`.
  final String visit;

  /// One of the families [browserFamily] returns.
  final String browser;
  final bool mobile;
  final int viewportWidth;
}

/// One error as the report carries it. [msg] and [stack] must already be
/// cleaned of anything personal before they get here.
@immutable
class ClientError {
  const ClientError({
    required this.type,
    required this.msg,
    required this.stack,
  });

  final String type;
  final String msg;
  final List<String> stack;

  /// Two errors with the same type and top stack line are one problem.
  String get fingerprint => '$type|${stack.isEmpty ? '' : stack.first}';
}

/// `chrome`, `safari`, `firefox`, `edge`, `samsung` or `other`.
String browserFamily(String userAgent) {
  final agent = userAgent.toLowerCase();
  if (agent.contains('edg/') ||
      agent.contains('edga/') ||
      agent.contains('edgios/')) {
    return 'edge';
  }
  if (agent.contains('samsungbrowser')) return 'samsung';
  if (agent.contains('firefox') || agent.contains('fxios')) return 'firefox';
  if (agent.contains('chrome') || agent.contains('crios')) return 'chrome';
  if (agent.contains('safari')) return 'safari';
  return 'other';
}

/// True for a phone or tablet browser.
bool isMobileAgent(String userAgent) =>
    RegExp('Mobi|Android|iPhone|iPad', caseSensitive: false)
        .hasMatch(userAgent);

/// `phone` under 600 px, `tablet` under 1024 px, otherwise `wide`.
String viewportClass(int width) => width < 600
    ? 'phone'
    : width < 1024
        ? 'tablet'
        : 'wide';

/// Sends the speed and error report for a web page: how long startup steps
/// took, the browser family and the cleaned errors, and nothing about who the
/// student is (spec T2). It never blocks a screen and never throws.
///
/// Cadence: one report once the splash has gone and the first screen has
/// settled, then at most one a minute while there is new data, and one as the
/// page is hidden. A failed report is tried once more and then dropped.
class ClientReporter {
  ClientReporter({
    required ClientReportSender sender,
    required ClientReportContext Function() context,
    DateTime Function()? now,
    List<PerfEntry> Function()? timings,
  })  : _sender = sender,
        _context = context,
        _now = now ?? DateTime.now,
        _timings = timings ?? PerfTimeline.entries;

  /// The reporter running on this page, if any. Null outside the web.
  static ClientReporter? active;

  static const _version = 1;
  static const _minGap = Duration(seconds: 60);
  static const _fallback = Duration(seconds: 20);
  static const _maxTimings = 40;
  static const _maxErrorsPerReport = 10;
  static const _maxDistinctErrors = 20;
  static const _maxCount = 1000;
  static const _maxType = 60;
  static const _maxMsg = 300;
  static const _maxFrames = 8;
  static const _maxFrame = 200;
  static const _maxBuild = 40;

  final ClientReportSender _sender;
  final ClientReportContext Function() _context;
  final DateTime Function() _now;
  final List<PerfEntry> Function() _timings;

  final Map<String, int> _sentTimings = {};
  final Map<String, _Seen> _errors = {};
  Timer? _ticker;
  Timer? _fallbackTimer;
  DateTime? _lastAttempt;
  bool _splashGone = false;
  bool _screenReady = false;
  bool _opened = false;
  bool _inFlight = false;
  bool _failedOnce = false;

  /// Starts a reporter for this web page and wires it to the splash, the first
  /// screen and the page being hidden. Returns null where there is nothing to
  /// report to: a native build, a local emulator run, or no Firebase.
  static ClientReporter? startForWeb({ClientReportSender? sender}) {
    try {
      if (!env.supported || localEmulators || Firebase.apps.isEmpty) {
        return null;
      }
      final reporter = ClientReporter(
        sender: sender ?? const FirebaseClientReportSender(),
        context: () => ClientReportContext(
          build: env.buildVersion(),
          visit: env.visitKind(),
          browser: browserFamily(env.userAgent()),
          mobile: isMobileAgent(env.userAgent()),
          viewportWidth: env.viewportWidth(),
        ),
      ).._start();
      active = reporter;
      return reporter;
    } on Object {
      return null;
    }
  }

  void _start() {
    afterSplashGone(splashGone);
    firstScreenListener = firstScreenSettled;
    env.onPageHidden(pageHidden);
    _ticker = Timer.periodic(_minGap, (_) => tick());
    // A page whose first screen never settles still reports what it has.
    _fallbackTimer = Timer(_fallback, () {
      _splashGone = true;
      _screenReady = true;
      _open();
    });
  }

  void dispose() {
    _ticker?.cancel();
    _fallbackTimer?.cancel();
    if (identical(active, this)) active = null;
    if (firstScreenListener == firstScreenSettled) firstScreenListener = null;
  }

  /// The HTML splash has left the page, or there never was one.
  void splashGone() {
    _splashGone = true;
    _open();
  }

  /// The first screen has settled.
  void firstScreenSettled() {
    _screenReady = true;
    _open();
  }

  /// Keeps an error for the next report. Repeats of the same problem count up;
  /// at most 20 different ones are kept for the session.
  void addError(ClientError error) {
    try {
      final key = error.fingerprint;
      final seen = _errors[key];
      if (seen != null) {
        seen.count++;
      } else if (_errors.length < _maxDistinctErrors) {
        _errors[key] = _Seen(error);
      }
    } on Object {
      // Reporting a problem must never cause one.
    }
  }

  /// The once-a-minute check. Sends only when something is new.
  void tick() {
    try {
      final last = _lastAttempt;
      if (!_opened || last == null || _now().difference(last) < _minGap) {
        return;
      }
      _sendIfNew();
    } on Object {
      // See addError.
    }
  }

  /// The page is being hidden, which may be the last chance. New data goes at
  /// once, whatever the one-a-minute gap says.
  void pageHidden() {
    try {
      _sendIfNew();
    } on Object {
      // See addError.
    }
  }

  void _open() {
    try {
      if (_opened || !_splashGone || !_screenReady) return;
      _opened = true;
      _fallbackTimer?.cancel();
      _sendIfNew();
    } on Object {
      // See addError.
    }
  }

  void _sendIfNew() {
    if (_inFlight) return;
    final report = _build();
    if (report == null) return;
    _inFlight = true;
    _lastAttempt = _now();
    unawaited(_deliver(report));
  }

  Future<void> _deliver(_Report report) async {
    try {
      await _sender.send(report.payload);
      _commit(report);
      _failedOnce = false;
    } on Object {
      if (_failedOnce) {
        // The retry failed too. Drop it rather than keep trying.
        _commit(report);
        _failedOnce = false;
      } else {
        _failedOnce = true;
      }
    } finally {
      _inFlight = false;
    }
  }

  void _commit(_Report report) {
    for (final entry in report.timings) {
      final key = _timingKey(entry);
      _sentTimings[key] = (_sentTimings[key] ?? 0) + 1;
    }
    for (final seen in report.errors) {
      seen.sentCount = seen.count;
    }
  }

  /// The next report, or null when nothing is new.
  _Report? _build() {
    final pending = <PerfEntry>[];
    final occurrence = <String, int>{};
    for (final entry in _timings()) {
      final key = _timingKey(entry);
      final index = occurrence[key] ?? 0;
      occurrence[key] = index + 1;
      if (index >= (_sentTimings[key] ?? 0)) pending.add(entry);
    }
    final timings = pending.take(_maxTimings).toList();
    final errors = _errors.values
        .where((seen) => seen.count > seen.sentCount)
        .take(_maxErrorsPerReport)
        .toList();
    if (timings.isEmpty && errors.isEmpty) return null;

    final context = _context();
    return _Report(
      timings: timings,
      errors: errors,
      payload: {
        'v': _version,
        'build': _cleanBuild(context.build),
        'visit': context.visit,
        'browser': context.browser,
        'mobile': context.mobile,
        'viewport': viewportClass(context.viewportWidth),
        'timings': [
          for (final entry in timings) {'n': entry.name, 'ms': entry.ms},
        ],
        'errors': [
          for (final seen in errors)
            {
              'type': _cut(seen.error.type, _maxType),
              'msg': _cut(seen.error.msg, _maxMsg),
              'stack': [
                for (final frame in seen.error.stack.take(_maxFrames))
                  _cut(frame, _maxFrame),
              ],
              'count': (seen.count - seen.sentCount).clamp(1, _maxCount),
            },
        ],
      },
    );
  }

  static String _timingKey(PerfEntry entry) => '${entry.name}=${entry.ms}';

  static String _cut(String text, int max) =>
      text.length <= max ? text : text.substring(0, max);

  static String _cleanBuild(String build) {
    final clean = build.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    return clean.isEmpty ? 'unknown' : _cut(clean, _maxBuild);
  }
}

class _Seen {
  _Seen(this.error);

  final ClientError error;
  int count = 1;
  int sentCount = 0;
}

class _Report {
  const _Report({
    required this.timings,
    required this.errors,
    required this.payload,
  });

  final List<PerfEntry> timings;
  final List<_Seen> errors;
  final Map<String, Object?> payload;
}
