import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/telemetry/crash_reporting.dart';
import 'package:pantas/core/telemetry/gated_telemetry.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// The app's telemetry, gated on the student's answer.
///
/// This lives in `lib/app/` and not in `lib/core/telemetry/` because it reads
/// a setting, and `core/` may not import `features/`. `GatedTelemetry` itself
/// is pure and stays in core.
///
/// Resolves to a closed gate until settings load, so the window before the
/// first read collects nothing rather than defaulting to collecting.
final telemetryProvider = Provider<Telemetry>((ref) {
  final settings = ref.watch(userSettingsProvider);
  final consent = settings.valueOrNull?.helpImproveApp;
  return GatedTelemetry(ref.watch(telemetrySinkProvider), consent: consent);
});

/// The SDK seam. Overridden in `bootstrap` with `FirebaseTelemetry`, and left
/// as [DisabledTelemetry] in tests and anywhere Firebase is not initialized.
final telemetrySinkProvider = Provider<Telemetry>(
  (ref) => const DisabledTelemetry(),
);

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
