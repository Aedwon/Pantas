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
  bool _purgePending = false;

  /// Applies persisted consent from storage at startup.
  ///
  /// For false / unanswered: closes gate, clears identity, disables Analytics,
  /// and deletes unsent crash reports.
  /// For true: enables Analytics and sends unsent reports created during prior
  /// consent-true use without purging first, then opens gate if successful.
  Future<void> applyStartupConsent({required bool enabled}) async {
    if (!enabled) {
      state = false;
      try {
        await _sink.setUserIdentifier('');
      } catch (error, stack) {
        debugPrint(
          'Failed to clear telemetry identity on startup: $error\n$stack',
        );
      }
      try {
        await _sink.setEnabled(enabled: false);
        _purgePending = false;
      } catch (error, stack) {
        _purgePending = true;
        debugPrint(
          'Failed to disable telemetry SDKs on startup: $error\n$stack',
        );
      }
      return;
    }

    try {
      await _sink.setEnabled(enabled: true);
      state = true;
      _purgePending = false;
    } catch (error, stack) {
      state = false;
      debugPrint('Failed to enable telemetry SDKs on startup: $error\n$stack');
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
      state = false;
      try {
        await _sink.setUserIdentifier('');
      } catch (error, stack) {
        debugPrint('Failed to clear telemetry identity: $error\n$stack');
      }
      try {
        await _sink.setEnabled(enabled: false);
        _purgePending = false;
      } catch (error, stack) {
        _purgePending = true;
        debugPrint('Failed to disable telemetry SDKs: $error\n$stack');
      }
      return;
    }

    // Opt-in (false -> true): must purge unsent reports first before enabling or sending.
    try {
      await _sink.setEnabled(enabled: false);
      _purgePending = false;
    } catch (error, stack) {
      _purgePending = true;
      state = false;
      debugPrint(
          'Failed to purge unsent reports before opt-in: $error\n$stack');
      return;
    }

    try {
      await _sink.setEnabled(enabled: true);
      state = true;
      _purgePending = false;
    } catch (error, stack) {
      state = false;
      debugPrint('Failed to enable telemetry SDKs on opt-in: $error\n$stack');
    }
  }
}
