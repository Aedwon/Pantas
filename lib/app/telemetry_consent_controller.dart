import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

final telemetryConsentControllerProvider =
    StateNotifierProvider<TelemetryConsentController, bool>((ref) {
  final sink = ref.watch(telemetrySinkProvider);
  return TelemetryConsentController(sink);
});

/// Controls telemetry consent and drives the underlying SDK collection state.
///
/// Implements [AnalyticsConsentGateway] so Settings can drive this directly.
/// Owns the effective runtime consent state, which starts false until consent
/// is read from storage and applied through the SDK.
class TelemetryConsentController extends StateNotifier<bool>
    implements AnalyticsConsentGateway {
  TelemetryConsentController(this._sink) : super(false);

  final Telemetry _sink;

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    if (!enabled) {
      // Opt-out / off: close application telemetry before attempting SDK shutdown.
      state = false;
      try {
        await _sink.setUserIdentifier('');
      } catch (error, stack) {
        debugPrint('Failed to clear telemetry identity: $error\n$stack');
      }
      try {
        await _sink.setEnabled(enabled: false);
      } catch (error, stack) {
        debugPrint('Failed to disable telemetry SDKs: $error\n$stack');
      }
      return;
    }

    // Opt-in / on: attempt to enable both collectors before opening the gate.
    try {
      await _sink.setEnabled(enabled: true);
      state = true;
    } catch (error, stack) {
      state = false;
      debugPrint('Failed to enable telemetry SDKs: $error\n$stack');
    }
  }
}
