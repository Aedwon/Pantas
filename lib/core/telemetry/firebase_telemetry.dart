import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// The only file in `lib/` permitted to import an analytics or crash package.
///
/// Both were in `pubspec.yaml` and imported by nothing until 3 August, so no
/// crash was ever reported and no event was ever recorded. The switch in
/// Settings governs whether this class is used at all: see
/// `telemetry_providers.dart`.
class FirebaseTelemetry implements Telemetry {
  const FirebaseTelemetry({
    required FirebaseAnalytics analytics,
    required FirebaseCrashlytics crashlytics,
  })  : _analytics = analytics,
        _crashlytics = crashlytics;

  /// Builds from the SDK singletons.
  ///
  /// Exists so `bootstrap` does not have to import either package, which is
  /// what keeps this file the only importer of both.
  FirebaseTelemetry.instances()
      : _analytics = FirebaseAnalytics.instance,
        _crashlytics = FirebaseCrashlytics.instance;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    if (properties != null) assertPropertiesAllowed(properties);
    await _analytics.logEvent(name: event.name, parameters: properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    await _crashlytics.recordError(error, stack);
  }

  /// Stops collection at the SDK rather than filtering afterward.
  ///
  /// Turning the switch off must stop data leaving the device, not merely stop
  /// this class calling in. Anything else makes the About page's promise false.
  @override
  Future<void> setEnabled({required bool enabled}) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
    await _analytics.setUserId(id: identifier.isEmpty ? null : identifier);
  }
}
