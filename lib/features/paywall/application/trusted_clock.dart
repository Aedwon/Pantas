import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';

bool _warnedAboutIosClock = false;

Future<Duration?> readElapsedRealtime() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    if (!_warnedAboutIosClock) {
      debugPrint(
        'Trusted clock: continuous boot detection is unavailable on iOS.',
      );
      _warnedAboutIosClock = true;
    }
    return null;
  }
  try {
    final milliseconds = await const MethodChannel('pantas/trusted_clock')
        .invokeMethod<int>('elapsedRealtime');
    return milliseconds == null ? null : Duration(milliseconds: milliseconds);
  } on MissingPluginException {
    return null;
  }
}

class TrustedClock {
  TrustedClock({
    required EntitlementSnapshotRead readValue,
    required EntitlementSnapshotWrite writeValue,
    DateTime Function()? deviceNow,
    Future<Duration?> Function()? elapsedNow,
  })  : _readValue = readValue,
        _writeValue = writeValue,
        _deviceNow = deviceNow ?? DateTime.now,
        _elapsedNow = elapsedNow ?? readElapsedRealtime;

  static const storageKey = 'payment_trusted_clock_v1';
  final EntitlementSnapshotRead _readValue;
  final EntitlementSnapshotWrite _writeValue;
  final DateTime Function() _deviceNow;
  final Future<Duration?> Function() _elapsedNow;
  Future<void>? _started;
  Future<void> _writes = Future<void>.value();
  DateTime? _mark;
  DateTime? _trusted;
  DateTime? _bootWall;
  DateTime? _sessionWall;
  Duration? _lastElapsed;
  Duration? _trustedElapsed;
  Duration _rollback = Duration.zero;

  DateTime? get trustedTime => _trusted;
  Duration get rollbackTotal => _rollback;
  bool get windowConsumed => _rollback > const Duration(minutes: 10);
  bool get hadSetbackSinceCheck => _rollback > Duration.zero;

  DateTime get effectiveTime {
    final candidates = [
      _deviceNow().toUtc(),
      if (_mark != null) _mark!,
      if (_trusted != null) _trusted!,
      if (_trusted != null &&
          _trustedElapsed != null &&
          _lastElapsed != null &&
          _lastElapsed! >= _trustedElapsed!)
        _trusted!.add(_lastElapsed! - _trustedElapsed!),
    ];
    return candidates.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  Future<void> start() => _started ??= _loadAndStart();

  Future<void> _loadAndStart() async {
    final raw = await _readValue(storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        DateTime? date(String key) => json[key] is String
            ? DateTime.tryParse(json[key] as String)?.toUtc()
            : null;
        Duration? duration(String key) =>
            json[key] is int ? Duration(milliseconds: json[key] as int) : null;
        _mark = date('mark');
        _trusted = date('trusted');
        _bootWall = date('bootWall');
        _lastElapsed = duration('lastElapsed');
        _trustedElapsed = duration('trustedElapsed');
        _rollback = duration('rollback') ?? Duration.zero;
      } catch (_) {
        // Invalid records provide no trusted time or boot evidence.
      }
    }
    await _observe(startup: true);
  }

  Future<void> observe() async {
    await start();
    await _observe(startup: false);
  }

  Future<void> _observe({required bool startup}) async {
    final elapsed = await _elapsedNow();
    final wall = _deviceNow().toUtc();
    final sameBoot =
        elapsed != null && _lastElapsed != null && elapsed >= _lastElapsed!;
    final bootWall = elapsed == null ? null : wall.subtract(elapsed);
    if (elapsed != null && _lastElapsed != null && elapsed < _lastElapsed!) {
      _trustedElapsed = null;
    }
    if (startup) {
      if (sameBoot && _bootWall != null && bootWall != null) {
        final shift = _bootWall!.difference(bootWall);
        if (shift > const Duration(seconds: 2)) _rollback += shift;
      }
    } else if (_sessionWall != null && wall.isBefore(_sessionWall!)) {
      var shift = _sessionWall!.difference(wall);
      if (sameBoot && _bootWall != null && bootWall != null) {
        final bootShift = _bootWall!.difference(bootWall);
        if (bootShift > shift) shift = bootShift;
      }
      _rollback += shift;
    }
    _sessionWall = wall;
    if (elapsed != null) {
      _lastElapsed = elapsed;
      _bootWall = bootWall;
    }
    final effective = effectiveTime;
    if (_mark == null || effective.isAfter(_mark!)) _mark = effective;
    await _persist();
  }

  /// Caller supplies only a verified RevenueCat server requestDate.
  Future<bool> confirm(DateTime requestAt) async {
    await start();
    final at = requestAt.toUtc();
    if (_trusted != null && !at.isAfter(_trusted!)) return false;
    _trusted = at;
    _mark = at;
    _trustedElapsed = _lastElapsed;
    _rollback = Duration.zero;
    _sessionWall = _deviceNow().toUtc();
    _bootWall =
        _lastElapsed == null ? null : _sessionWall!.subtract(_lastElapsed!);
    await _persist();
    return true;
  }

  Future<void> _persist() {
    final raw = jsonEncode({
      'mark': _mark?.toIso8601String(),
      'trusted': _trusted?.toIso8601String(),
      'bootWall': _bootWall?.toIso8601String(),
      'lastElapsed': _lastElapsed?.inMilliseconds,
      'trustedElapsed': _trustedElapsed?.inMilliseconds,
      'rollback': _rollback.inMilliseconds,
    });
    final write = _writes.then((_) => _writeValue(storageKey, raw));
    _writes = write;
    return write;
  }
}
