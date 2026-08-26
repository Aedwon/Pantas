import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

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

  /// The SDK sink when Firebase is running, and the disabled one when it is
  /// not.
  ///
  /// There is no Firebase project yet, so `bootstrapFirebase` initializes
  /// nothing and touching either singleton throws `[core/no-app]`. Building
  /// this unconditionally killed the app on launch, at the splash, before a
  /// single screen drew.
  static Telemetry instancesIfAvailable() {
    if (Firebase.apps.isEmpty) return const DisabledTelemetry();
    return FirebaseTelemetry.instances();
  }

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
    final sanitized = SanitizedTelemetryException(error.runtimeType.toString());
    await _crashlytics.recordError(sanitized, stack);
  }

  /// Drives runtime consent at the SDK level.
  ///
  /// Analytics collection is enabled or disabled dynamically.
  /// Crashlytics automatic collection stays permanently disabled; turning
  /// consent on sends pending unsent reports, and turning consent off purges
  /// unsent reports.
  @override
  Future<void> setEnabled({required bool enabled}) async {
    Object? firstError;
    StackTrace? firstStack;

    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (error, stack) {
      firstError = error;
      firstStack = stack;
    }

    try {
      if (enabled) {
        await _crashlytics.sendUnsentReports();
      } else {
        await _crashlytics.deleteUnsentReports();
      }
    } catch (error, stack) {
      firstError ??= error;
      firstStack ??= stack;
    }

    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStack ?? StackTrace.current);
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    Object? firstError;
    StackTrace? firstStack;

    try {
      await _crashlytics.setUserIdentifier(identifier);
    } catch (error, stack) {
      firstError = error;
      firstStack = stack;
    }

    try {
      await _analytics.setUserId(id: identifier.isEmpty ? null : identifier);
    } catch (error, stack) {
      firstError ??= error;
      firstStack ??= stack;
    }

    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStack ?? StackTrace.current);
    }
  }
}

/// A sanitized exception wrapper that sends only the stable error category /
/// type and avoids leaking message content, free text, scores, or identifiers.
class SanitizedTelemetryException implements Exception {
  const SanitizedTelemetryException(this.errorType);

  final String errorType;

  @override
  String toString() => errorType;
}
