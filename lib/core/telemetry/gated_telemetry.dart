import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';

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

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    if (!isCollecting) return;
    await _inner.log(event, properties: properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    if (!isCollecting) return;
    await _inner.recordError(error, stack);
  }

  /// Always forwarded, gate open or shut.
  ///
  /// Stopping collection has to reach the SDK. A gate that filtered this one
  /// too would leave the SDK collecting while the app merely declined to look,
  /// which is the difference between a promise and a pretense.
  @override
  Future<void> setEnabled({required bool enabled}) =>
      _inner.setEnabled(enabled: enabled);
}
