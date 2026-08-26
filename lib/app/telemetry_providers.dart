import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/telemetry/crash_reporting.dart';
import 'package:pantas/core/telemetry/gated_telemetry.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/app/telemetry_consent_controller.dart';

/// The SDK seam. Overridden in `bootstrap` with `FirebaseTelemetry`, and left
/// as [DisabledTelemetry] in tests and anywhere Firebase is not initialized.
final telemetrySinkProvider = Provider<Telemetry>(
  (ref) => const DisabledTelemetry(),
);

/// The consent controller, wired to the active SDK sink.
final telemetryConsentControllerProvider =
    StateNotifierProvider<TelemetryConsentController, bool>((ref) {
  final sink = ref.watch(telemetrySinkProvider);
  return TelemetryConsentController(sink);
});

/// The effective runtime consent state, managed by [TelemetryConsentController].
/// Starts false until consent is confirmed and applied via the SDK.
final effectiveTelemetryConsentProvider = Provider<bool>((ref) {
  return ref.watch(telemetryConsentControllerProvider);
});

/// The app's telemetry, gated on the effective runtime consent state.
///
/// Resolves to a closed gate until consent is loaded, applied to the SDK,
/// and confirmed active.
final telemetryProvider = Provider<Telemetry>((ref) {
  final consent = ref.watch(effectiveTelemetryConsentProvider);
  return GatedTelemetry(ref.watch(telemetrySinkProvider), consent: consent);
});

/// Absorbs CrashReporter into telemetry, updating user identifier when auth
/// changes.
final crashReporterProvider = Provider<CrashReporter>((ref) {
  final telemetry = ref.watch(telemetryProvider);
  final reporter = CrashReporter(telemetry);
  ref.listen(authStateProvider, (previous, next) {
    next.whenData(reporter.applyAuthState);
  });
  return reporter;
});
