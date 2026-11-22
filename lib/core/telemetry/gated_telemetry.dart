import 'dart:async';

import 'package:pantas/core/telemetry/client_report.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

/// Wraps a `Telemetry` and lets nothing through until the student has said
/// yes.
///
/// The `consent` argument is deliberately nullable, and null means
/// **unanswered**, which is
/// treated as no. Section 2 of
/// `docs/superpowers/specs/2026-08-03-platform-foundations-design.md`: RA10173
/// makes that the safe reading, and consent that does nothing is worse than no
/// switch at all.
class GatedTelemetry implements Telemetry {
  const GatedTelemetry(this._inner, {required bool? consent})
      : _consent = consent;

  final Telemetry _inner;
  final bool? _consent;

  bool get isCollecting => _consent ?? false;

  /// Returns at once and never throws, whatever the SDK does.
  ///
  /// Every app caller reaches analytics through this gate, and callers log in
  /// the middle of real work: on Nov 22 2026 a property check that threw here
  /// stopped quiz answers from saving on prod. So a property that may not be
  /// sent is dropped (and reported by key, never by value), the SDK call runs
  /// on its own, and its failure is reported, not passed back.
  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    if (!isCollecting) return;
    final allowed = properties == null
        ? null
        : allowedProperties(properties, onDropped: _reportDropped);
    unawaited(_contain(() => _inner.log(event, properties: allowed)));
  }

  /// Never throws. The SDK part runs on its own, as in [log].
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    // The web app's speed and error reports are not usage sharing: they are on
    // for everyone and carry no identity (spec option A), so the web reporter
    // hears every error, cleaned, whatever the switch says. It is null on a
    // phone, where only the gate below applies.
    _report(error, stack);
    if (!isCollecting) return;
    unawaited(_contain(() => _inner.recordError(error, stack)));
  }

  static void _reportDropped(String key) => _report(
        ArgumentError.value(key, 'properties', 'analytics property dropped'),
        StackTrace.current,
      );

  static void _report(Object error, StackTrace stack) {
    try {
      ClientReporter.active?.recordError(error, stack);
    } on Object {
      // Reporting is best effort; it must not fail the caller either.
    }
  }

  static Future<void> _contain(Future<void> Function() call) async {
    try {
      await call();
    } on Object catch (error, stack) {
      _report(error, stack);
    }
  }

  /// Always forwarded, gate open or shut.
  ///
  /// Stopping collection has to reach the SDK. A gate that filtered this one
  /// too would leave the SDK collecting while the app merely declined to look,
  /// which is the difference between a promise and a pretense.
  @override
  Future<void> setEnabled({required bool enabled}) =>
      _inner.setEnabled(enabled: enabled);

  @override
  Future<void> setUserIdentifier(String identifier) async {
    if (!isCollecting) return;
    await _inner.setUserIdentifier(identifier);
  }
}
