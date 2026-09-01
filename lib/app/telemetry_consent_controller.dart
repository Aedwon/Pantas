import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

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
  void closeTelemetryGate() {
    state = false;
  }

  /// Applies persisted consent from storage at startup.
  ///
  /// For false / unanswered: closes gate, clears identity, disables Analytics,
  /// and deletes unsent crash reports.
  /// For true: enables Analytics and sends unsent reports created during prior
  /// consent-true use without purging first, then opens gate if successful.
  Future<void> applyStartupConsent({required bool enabled}) async {
    if (!enabled) {
      await _handleOptOut();
      return;
    }

    try {
      await _sink.setEnabled(enabled: true);
      state = true;
    } catch (error, stack) {
      state = false;
      debugPrint('Failed to enable telemetry SDKs on startup: $error\n$stack');
      await _rollbackDisabled('startup');
      rethrow;
    }
  }

  /// Handles runtime consent transitions (e.g. Settings toggle).
  ///
  /// On opt-out (false): closes gate immediately, clears identity, disables
  /// Analytics, and deletes unsent reports.
  /// On opt-in (true): purges unsent reports first before enabling Analytics or
  /// sending reports, ensuring no reports captured while opted-out upload.
  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    if (!enabled) {
      await _handleOptOut();
      return;
    }

    // Opt-in (false -> true): must purge unsent reports first before enabling
    // or sending.
    try {
      await _sink.setEnabled(enabled: false);
    } catch (error, stack) {
      state = false;
      debugPrint(
        'Failed to purge unsent reports before opt-in: $error\n$stack',
      );
      rethrow;
    }

    try {
      await _sink.setEnabled(enabled: true);
      state = true;
    } catch (error, stack) {
      state = false;
      debugPrint('Failed to enable telemetry SDKs on opt-in: $error\n$stack');
      await _rollbackDisabled('opt-in');
      rethrow;
    }
  }

  Future<void> _rollbackDisabled(String context) async {
    try {
      await _sink.setEnabled(enabled: false);
    } catch (error, stack) {
      debugPrint(
        'Failed to rollback telemetry SDK state on $context failure: '
        '$error\n$stack',
      );
    }
  }

  Future<void> _handleOptOut() async {
    closeTelemetryGate();
    Object? firstError;
    StackTrace? firstStack;

    try {
      await _sink.setUserIdentifier('');
    } catch (error, stack) {
      firstError ??= error;
      firstStack ??= stack;
      debugPrint('Failed to clear telemetry identity: $error\n$stack');
    }

    try {
      await _sink.setEnabled(enabled: false);
    } catch (error, stack) {
      firstError ??= error;
      firstStack ??= stack;
      debugPrint('Failed to disable telemetry SDKs: $error\n$stack');
    }

    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStack!);
    }
  }
}
