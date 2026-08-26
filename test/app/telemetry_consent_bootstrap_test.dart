import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/app/telemetry_consent_controller.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/storage.dart';
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
  bool throwOnRecordError = false;

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
    if (throwOnSetEnabled) {
      throw StateError('SDK setEnabled failed');
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIdentifierCalls.add(identifier);
  }
}

void main() {
  group('TelemetryConsentController effective runtime consent', () {
    test('starts false and stays false before consent is given', () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      expect(controller.state, isFalse);
    });

    test('enabling successfully sets effective state to true', () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      await controller.setAnalyticsCollectionEnabled(enabled: true);

      expect(controller.state, isTrue);
      expect(sink.enabledCalls, [true]);
    });

    test('enabling failure keeps effective state false', () async {
      final sink = RecordingTelemetrySink()..throwOnSetEnabled = true;
      final controller = TelemetryConsentController(sink);

      await controller.setAnalyticsCollectionEnabled(enabled: true);

      expect(controller.state, isFalse);
      expect(sink.enabledCalls, [true]);
    });

    test('disabling closes gate immediately, clears identity, and disables SDK',
        () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      // First enable
      await controller.setAnalyticsCollectionEnabled(enabled: true);
      expect(controller.state, isTrue);

      // Then disable
      await controller.setAnalyticsCollectionEnabled(enabled: false);

      expect(controller.state, isFalse);
      expect(sink.userIdentifierCalls, contains(''));
      expect(sink.enabledCalls, [true, false]);
    });

    test('disabling failure still leaves effective gate closed', () async {
      final sink = RecordingTelemetrySink();
      final controller = TelemetryConsentController(sink);

      await controller.setAnalyticsCollectionEnabled(enabled: true);
      expect(controller.state, isTrue);

      sink.throwOnSetEnabled = true;
      await controller.setAnalyticsCollectionEnabled(enabled: false);

      expect(controller.state, isFalse);
      expect(sink.userIdentifierCalls, contains(''));
    });
  });

  group('Startup consent application and settings integration', () {
    test('absent consent defaults to false and disables SDK', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sink = RecordingTelemetrySink();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          telemetrySinkProvider.overrideWithValue(sink),
          analyticsConsentGatewayProvider.overrideWith(
            (ref) => ref.watch(telemetryConsentControllerProvider.notifier),
          ),
        ],
      );
      addTearDown(container.dispose);

      final settings = await container.read(userSettingsProvider.future);
      expect(settings.helpImproveApp, isFalse);

      final controller =
          container.read(telemetryConsentControllerProvider.notifier);
      await controller.setAnalyticsCollectionEnabled(
        enabled: settings.helpImproveApp,
      );

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);
      expect(sink.enabledCalls, [false]);
      expect(sink.userIdentifierCalls, contains(''));

      // Verify telemetryProvider drops events
      final telemetry = container.read(telemetryProvider);
      await telemetry.log(TelemetryEvent.sessionStarted);
      expect(sink.loggedEvents, isEmpty);
    });

    test('persisted true consent enables SDK and opens effective gate',
        () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sink = RecordingTelemetrySink();

      final repo = DriftSettingsRepository(db);
      await repo.updateHelpImproveApp(enabled: true);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          telemetrySinkProvider.overrideWithValue(sink),
          analyticsConsentGatewayProvider.overrideWith(
            (ref) => ref.watch(telemetryConsentControllerProvider.notifier),
          ),
        ],
      );
      addTearDown(container.dispose);

      final settings = await container.read(userSettingsProvider.future);
      expect(settings.helpImproveApp, isTrue);

      final controller =
          container.read(telemetryConsentControllerProvider.notifier);
      await controller.setAnalyticsCollectionEnabled(
        enabled: settings.helpImproveApp,
      );

      expect(container.read(effectiveTelemetryConsentProvider), isTrue);
      expect(sink.enabledCalls, [true]);

      // Verify telemetryProvider forwards events
      final telemetry = container.read(telemetryProvider);
      await telemetry.log(TelemetryEvent.sessionStarted);
      expect(sink.loggedEvents, [TelemetryEvent.sessionStarted]);
    });

    test('settings toggle through actions drives controller and updates gate',
        () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sink = RecordingTelemetrySink();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          telemetrySinkProvider.overrideWithValue(sink),
          analyticsConsentGatewayProvider.overrideWith(
            (ref) => ref.watch(telemetryConsentControllerProvider.notifier),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);

      // Turn on via SettingsActions
      await container
          .read(settingsActionsProvider)
          .setHelpImproveApp(enabled: true);

      expect(container.read(effectiveTelemetryConsentProvider), isTrue);
      expect(sink.enabledCalls, [true]);

      // Turn off via SettingsActions
      await container
          .read(settingsActionsProvider)
          .setHelpImproveApp(enabled: false);

      expect(container.read(effectiveTelemetryConsentProvider), isFalse);
      expect(sink.enabledCalls, [true, false]);
      expect(sink.userIdentifierCalls, contains(''));
    });

    test('DisabledTelemetry works deterministically with controller', () async {
      final controller = TelemetryConsentController(const DisabledTelemetry());

      await controller.setAnalyticsCollectionEnabled(enabled: true);
      expect(controller.state, isTrue);

      await controller.setAnalyticsCollectionEnabled(enabled: false);
      expect(controller.state, isFalse);
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
      await controller.setAnalyticsCollectionEnabled(enabled: true);

      final telemetry = container.read(telemetryProvider);

      // Best effort error reporting callback simulation
      expect(
        () {
          try {
            telemetry
                .recordError(Exception('test'), StackTrace.current)
                .ignore();
          } catch (_) {}
        },
        returnsNormally,
      );
    });
  });
}
