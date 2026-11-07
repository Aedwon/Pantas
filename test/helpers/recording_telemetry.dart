import 'package:pantas/core/telemetry/telemetry.dart';

/// A telemetry sink that remembers what reached it, so a test can check which
/// events went out and with which parameters.
class RecordingTelemetry implements Telemetry {
  final logged = <(TelemetryEvent, Map<String, Object>?)>[];

  /// The event names in the order they were logged.
  List<TelemetryEvent> get events => [for (final entry in logged) entry.$1];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async =>
      logged.add((event, properties));

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}
