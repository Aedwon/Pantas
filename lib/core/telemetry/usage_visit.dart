import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantas/core/platform/account_access.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/telemetry/client_report_env_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/telemetry/client_report_env_web.dart'
    as env;
import 'package:pantas/core/telemetry/screen_ids.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

/// Where a visit record goes. Tests replace it.
// ignore: one_member_abstracts
abstract interface class UsageVisitSender {
  Future<void> send(Map<String, Object?> payload);
}

/// Sends a record to the `reportUsageVisit` callable. The record names no
/// account: the server logs it without the caller's identity.
class FirebaseUsageVisitSender implements UsageVisitSender {
  const FirebaseUsageVisitSender();

  static const _name = 'reportUsageVisit';

  @override
  Future<void> send(Map<String, Object?> payload) async {
    await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
        .httpsCallable(_name, options: callableOptionsFor(_name))
        .callForAccount<Object?>(payload);
  }
}

/// 16 random hex characters. Made once when the app starts and kept only in
/// memory, so it tells two visits apart and nothing else.
String generateVisitId([Random? random]) {
  final source = random ?? Random.secure();
  return List.generate(
    16,
    (_) => source.nextInt(16).toRadixString(16),
  ).join();
}

/// A readable copy of the screen views, for people who chose "Help improve
/// Pantas by sharing usage data".
///
/// It wraps the analytics sink, so it sits behind the consent gate: the gate
/// lets a screen view through only while the student's choice is yes, and
/// this class sees nothing otherwise. Each screen view goes on to the inner
/// sink unchanged. It is also kept, with the milliseconds since the visit
/// began, and sent to the `reportUsageVisit` callable when the page is hidden
/// and after every 20 screens. The record holds a visit id made at start, a
/// screen name from the closed set and a time. It holds no account id and no
/// free text.
///
/// Switching collection off (or on) drops what has not been sent, so nothing
/// gathered under one choice goes out under another. A failed send is tried
/// once more at the next send, then dropped. Nothing here throws.
class UsageVisitTelemetry implements Telemetry {
  UsageVisitTelemetry({
    required Telemetry inner,
    required UsageVisitSender sender,
    required String Function() build,
    DateTime Function()? now,
    String? visitId,
    void Function(void Function()) listenPageHidden = env.onPageHidden,
  })  : _inner = inner,
        _sender = sender,
        _build = build,
        _now = now ?? DateTime.now,
        _visitId = visitId ?? generateVisitId() {
    _started = _now();
    listenPageHidden(_pageHidden);
  }

  /// Wraps [inner] on a web page with live Firebase. Everywhere else (a phone
  /// build, a local emulator run, no Firebase) it returns [inner] unchanged,
  /// so only the analytics event is sent there.
  static Telemetry wrapForWeb(Telemetry inner, {UsageVisitSender? sender}) {
    try {
      if (!env.supported || localEmulators || Firebase.apps.isEmpty) {
        return inner;
      }
      return UsageVisitTelemetry(
        inner: inner,
        sender: sender ?? const FirebaseUsageVisitSender(),
        build: env.buildVersion,
      );
    } on Object {
      return inner;
    }
  }

  static const _version = 1;
  static const _flushAt = 20;
  static const _maxScreens = 100;
  static const _maxMs = 7 * 24 * 60 * 60 * 1000;
  static const _maxBuild = 40;

  final Telemetry _inner;
  final UsageVisitSender _sender;
  final String Function() _build;
  final DateTime Function() _now;
  final String _visitId;
  late final DateTime _started;

  final List<Map<String, Object>> _pending = [];

  // Screens handed to a send that has not finished, and screens whose send
  // failed once. Compared by identity, so equal-looking screens stay apart.
  final Set<Map<String, Object>> _handed = HashSet.identity();
  final Set<Map<String, Object>> _retried = HashSet.identity();
  bool _enabled = false;
  int _active = 0;
  int _epoch = 0;

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    if (event == TelemetryEvent.screenViewed) _record(properties?['screen']);
    await _inner.log(event, properties: properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) =>
      _inner.recordError(error, stack);

  @override
  Future<void> setEnabled({required bool enabled}) async {
    // Everything before the first await runs at once, so what was gathered
    // under the old choice is gone before anything else can run.
    _enabled = enabled;
    _dropAll();
    await _inner.setEnabled(enabled: enabled);
  }

  /// Opting out clears the identifier before it switches collection off, so
  /// an empty identifier is the first signal the buffer gets. Drop it now, at
  /// once, so a page hide in the gap cannot send screens recorded while the
  /// switch was on. Recording itself stays as it was: a sign-out also clears
  /// the identifier, and the consent gate already blocks new screens.
  @override
  Future<void> setUserIdentifier(String identifier) {
    if (identifier.isEmpty) _dropAll();
    return _inner.setUserIdentifier(identifier);
  }

  void _dropAll() {
    _epoch++;
    _pending.clear();
    _handed.clear();
    _retried.clear();
  }

  void _record(Object? screen) {
    try {
      if (!_enabled ||
          screen is! String ||
          !trackedScreenIds.contains(screen) ||
          _pending.length >= _maxScreens) {
        return;
      }
      final elapsed = _now().difference(_started).inMilliseconds;
      _pending.add({'s': screen, 't': elapsed.clamp(0, _maxMs)});
      if (_pending.length >= _flushAt) _send();
    } on Object {
      // Recording usage must never cause a problem.
    }
  }

  void _pageHidden() {
    try {
      // The page may close now: send what is waiting even if a send is out.
      // Screens already handed to a send are not sent again.
      _send(force: true);
    } on Object {
      // See _record.
    }
  }

  void _send({bool force = false}) {
    if ((_active > 0 && !force) || !_enabled) return;
    final batch = [
      for (final item in _pending)
        if (!_handed.contains(item)) item,
    ].take(_maxScreens).toList();
    if (batch.isEmpty) return;
    _handed.addAll(batch);
    _active++;
    unawaited(_deliver(batch, _epoch));
  }

  Future<void> _deliver(List<Map<String, Object>> batch, int epoch) async {
    var done = false;
    try {
      await _sender.send({
        'v': _version,
        'build': _cleanBuild(_build()),
        'visit_id': _visitId,
        'screens': [
          for (final screen in batch) {...screen},
        ],
      });
      done = true;
    } on Object {
      // A batch that already failed once is dropped; others get one retry.
      done = batch.any(_retried.contains);
    } finally {
      _active--;
    }
    // A choice change meanwhile already emptied everything.
    if (epoch != _epoch) return;
    _handed.removeAll(batch);
    if (done) {
      _pending.removeWhere(batch.contains);
      _retried.removeAll(batch);
      if (_pending.length >= _flushAt) _send();
    } else {
      _retried.addAll(batch);
    }
  }

  static String _cleanBuild(String build) {
    final clean = build.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    if (clean.isEmpty) return 'unknown';
    return clean.length <= _maxBuild ? clean : clean.substring(0, _maxBuild);
  }
}
