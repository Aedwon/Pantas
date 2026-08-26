import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/app/telemetry_consent_controller.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/firebase_telemetry.dart';
import 'package:pantas/core/telemetry/gated_telemetry.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/settings/settings.dart';

import '../helpers/in_memory_database.dart';

class RecordingTelemetrySink implements Telemetry {
  final List<TelemetryEvent> loggedEvents = [];
  final List<bool> enabledCalls = [];
  final List<String> userIdentifierCalls = [];
  final List<Object> recordedErrors = [];

  bool throwOnSetEnabled = false;
  bool throwOnSetEnabledFalse = false;
  bool throwOnSetEnabledTrue = false;
  bool throwOnRecordError = false;
  bool throwOnSetUserIdentifier = false;

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    loggedEvents.add(event);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    if (throwOnRecordError) {
      throw StateError('Crashlytics recordError failed');
    }
    recordedErrors.add(error);
  }

  @override
  Future<void> setEnabled({required bool enabled}) async {
    enabledCalls.add(enabled);
    if (throwOnSetEnabled ||
        (enabled && throwOnSetEnabledTrue) ||
        (!enabled && throwOnSetEnabledFalse)) {
      throw StateError('SDK setEnabled($enabled) failed');
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    if (throwOnSetUserIdentifier) {
      throw StateError('setUserIdentifier failed');
    }
    userIdentifierCalls.add(identifier);
  }
}

void main() {
  group('TelemetryConsentController effective runtime consent and transitions',
      () {
    test('starts false and stays false before consent is applied', () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      expect(controller.state, isFalse);
    });

    test('startup persisted true enables SDK without purge and opens gate',
        () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      await controller.applyStartupConsent(enabled: true);

      expect(controller.state, isTrue);
      expect(sink.enabledCalls, [true]);
    });

    test('startup persisted true failure keeps effective state false',
        () async {
      final sink = RecordingTelemetrySink()..throwOnSetEnabled = true;
      final controller = TelemetryConsentController(sink);

      await controller.applyStartupConsent(enabled: true);

      expect(controller.state, isFalse);
      expect(sink.enabledCalls, [true]);
    });

    test(
        'startup persisted false closes gate, clears identity, and deletes unsent reports',
        () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      await controller.applyStartupConsent(enabled: false);

      expect(controller.state, isFalse);
      expect(sink.userIdentifierCalls, contains(''));
      expect(sink.enabledCalls, [false]);
    });

    test(
        'runtime transition false to true purges unsent reports before enabling',
        () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      // Runtime toggle from false to true
      await controller.setAnalyticsCollectionEnabled(enabled: true);

      expect(controller.state, isTrue);
      // Purge (false) must happen before enable (true)
      expect(sink.enabledCalls, [false, true]);
    });

    test(
        'runtime transition false to true stops and remains closed if purge fails',
        () async {
      final sink = RecordingTelemetrySink()..throwOnSetEnabledFalse = true;
      final controller = TelemetryConsentController(sink);

      await controller.setAnalyticsCollectionEnabled(enabled: true);

      expect(controller.state, isFalse);
      expect(sink.enabledCalls, [false]);
    });

    test('runtime transition false to true retries purge on later attempt',
        () async {
      final sink = RecordingTelemetrySink()..throwOnSetEnabledFalse = true;
      final controller = TelemetryConsentController(sink);

      // First attempt fails during purge
      await controller.setAnalyticsCollectionEnabled(enabled: true);
      expect(controller.state, isFalse);
      expect(sink.enabledCalls, [false]);

      // Retry succeeds
      sink.throwOnSetEnabledFalse = false;
      await controller.setAnalyticsCollectionEnabled(enabled: true);
      expect(controller.state, isTrue);
      expect(sink.enabledCalls, [false, false, true]);
    });

    test(
        'runtime transition true to false closes gate immediately, clears identity, and deletes unsent reports',
        () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      // Enable first
      await controller.applyStartupConsent(enabled: true);
      expect(controller.state, isTrue);

      // Disable
      await controller.setAnalyticsCollectionEnabled(enabled: false);

      expect(controller.state, isFalse);
      expect(sink.userIdentifierCalls, contains(''));
      expect(sink.enabledCalls, [true, false]);
    });

    test(
        'runtime transition true to false failure still leaves effective gate closed',
        () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      await controller.applyStartupConsent(enabled: true);
      expect(controller.state, isTrue);

      sink.throwOnSetEnabledFalse = true;
      await controller.setAnalyticsCollectionEnabled(enabled: false);

      expect(controller.state, isFalse);
      expect(sink.userIdentifierCalls, contains(''));
    });
  });

  group('Startup consent application and settings integration', () {
    test('absent consent defaults to false and deletes unsent reports',
        () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sink = RecordingTelemetrySink();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          telemetrySinkProvider.overrideWithValue(sink),
          ...telemetryConsentOverrides,
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);

      await applyPersistedTelemetryConsent(container);

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);
      expect(sink.enabledCalls, [false]);
      expect(sink.userIdentifierCalls, contains(''));

      // Verify telemetryProvider drops events
      final telemetry = container.read(telemetryProvider);
      await telemetry.log(TelemetryEvent.sessionStarted);
      expect(sink.loggedEvents, isEmpty);
    });

    test(
        'explicit stored false consent applies false and deletes unsent reports',
        () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sink = RecordingTelemetrySink();

      final repo = DriftSettingsRepository(db);
      await repo.updateHelpImproveApp(enabled: false);
      sink.enabledCalls.clear();
      sink.userIdentifierCalls.clear();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          telemetrySinkProvider.overrideWithValue(sink),
          ...telemetryConsentOverrides,
        ],
      );
      addTearDown(container.dispose);

      await applyPersistedTelemetryConsent(container);

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);
      expect(sink.enabledCalls, [false]);
      expect(sink.userIdentifierCalls, contains(''));

      final telemetry = container.read(telemetryProvider);
      await telemetry.log(TelemetryEvent.sessionStarted);
      expect(sink.loggedEvents, isEmpty);
    });

    test(
        'persisted true consent enables SDK without purge and opens effective gate',
        () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sink = RecordingTelemetrySink();

      final repo = DriftSettingsRepository(db);
      await repo.updateHelpImproveApp(enabled: true);
      sink.enabledCalls.clear();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          telemetrySinkProvider.overrideWithValue(sink),
          ...telemetryConsentOverrides,
        ],
      );
      addTearDown(container.dispose);

      // Verify ordering: before startup consent application, effective consent is false
      // and telemetry events are dropped even though stored setting is true
      await container
          .read(telemetryProvider)
          .log(TelemetryEvent.sessionStarted);
      expect(sink.loggedEvents, isEmpty);
      expect(sink.enabledCalls, isEmpty);
      expect(container.read(effectiveTelemetryConsentProvider), isFalse);

      // Run production startup consent application
      await applyPersistedTelemetryConsent(container);

      expect(container.read(effectiveTelemetryConsentProvider), isTrue);
      // Retains consented reports: direct enable with no prior purge
      expect(sink.enabledCalls, [true]);

      // Verify telemetryProvider forwards events after startup consent is applied
      await container
          .read(telemetryProvider)
          .log(TelemetryEvent.sessionStarted);
      expect(sink.loggedEvents, [TelemetryEvent.sessionStarted]);
    });

    test(
        'settings toggle through actions drives controller with false-to-true purge',
        () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sink = RecordingTelemetrySink();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          telemetrySinkProvider.overrideWithValue(sink),
          ...telemetryConsentOverrides,
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);

      // Turn on via SettingsActions (triggers purge then enable)
      await container
          .read(settingsActionsProvider)
          .setHelpImproveApp(enabled: true);

      expect(container.read(effectiveTelemetryConsentProvider), isTrue);
      expect(sink.enabledCalls, [false, true]);

      // Turn off via SettingsActions (triggers disable)
      await container
          .read(settingsActionsProvider)
          .setHelpImproveApp(enabled: false);

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);
      expect(sink.enabledCalls, [false, true, false]);
      expect(sink.userIdentifierCalls, contains(''));
    });

    test(
        'Firebase unavailable via instancesIfAvailable works deterministically',
        () async {
      final container = ProviderContainer(
        overrides: [
          telemetrySinkProvider.overrideWithValue(
            FirebaseTelemetry.instancesIfAvailable(),
          ),
          ...telemetryConsentOverrides,
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(telemetryConsentControllerProvider.notifier);

      await controller.setAnalyticsCollectionEnabled(enabled: true);
      expect(container.read(effectiveTelemetryConsentProvider), isTrue);

      await controller.setAnalyticsCollectionEnabled(enabled: false);
      expect(container.read(effectiveTelemetryConsentProvider), isFalse);
    });

    test('partial SDK failure on enable keeps effective gate false', () async {
      final sink = RecordingTelemetrySink()..throwOnSetEnabled = true;
      final container = ProviderContainer(
        overrides: [
          telemetrySinkProvider.overrideWithValue(sink),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(telemetryConsentControllerProvider.notifier);
      await controller.setAnalyticsCollectionEnabled(enabled: true);

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);
    });

    test(
        'failing crash report Future is handled best-effort and does not throw',
        () async {
      final sink = RecordingTelemetrySink()..throwOnRecordError = true;
      final container = ProviderContainer(
        overrides: [
          telemetrySinkProvider.overrideWithValue(sink),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(telemetryConsentControllerProvider.notifier);
      await controller.applyStartupConsent(enabled: true);

      expect(
        () => handleBootstrapError(
          Exception('test crash reporting failure'),
          StackTrace.current,
          container: container,
        ),
        returnsNormally,
      );
    });
  });
}
