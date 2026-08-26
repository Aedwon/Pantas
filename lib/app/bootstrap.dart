import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/telemetry_consent_controller.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/bundle/seed_installer.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/content_database_opener.dart';
import 'package:pantas/core/dev/dev_demo_switch.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/platform/app_check.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/error_boundary.dart';
import 'package:pantas/core/telemetry/firebase_telemetry.dart';
import 'package:pantas/core/ui/components/app_error_view.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/domain/mock_availability.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/notifications/presentation/notifications_lifecycle_observer.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
import 'package:pantas/features/review_prompt/data/in_app_review_gateway.dart';
import 'package:pantas/features/review_prompt/data/review_prompt_store.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// Feeds the real subscription into the mock cooldown.
///
/// `mockEntitlementProvider` ships hardcoded to false because
/// `features/mock_exam` cannot import `features/paywall` without breaking the
/// layering rule. `lib/app/` can import both, so the wiring lives here, the
/// same way the notification providers are wired.
///
/// Exposed as a list so tests can apply it without running `bootstrap`.
final mockEntitlementOverrides = <Override>[
  mockEntitlementProvider.overrideWith(
    (ref) => MockEntitlementSnapshot(
      proIsActive:
          ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false,
    ),
  ),
];

/// Feeds the shipping telemetry consent gateway into settings actions and startup.
///
/// Exposed as a list so tests can exercise the exact telemetry override collection
/// used by [bootstrap].
final telemetryConsentOverrides = <Override>[
  analyticsConsentGatewayProvider.overrideWith(
    (ref) => ref.watch(telemetryConsentControllerProvider.notifier),
  ),
];

/// Handles uncaught bootstrap errors by recording to telemetry best-effort
/// and logging to console.
void handleBootstrapError(
  Object error,
  StackTrace stack, {
  ProviderContainer? container,
}) {
  try {
    container?.read(telemetryProvider).recordError(error, stack).ignore();
  } catch (e) {
    debugPrint('Telemetry recordError failed: $e');
  }
  debugPrint('Uncaught: $error\n$stack');
}

Future<void> bootstrap(Flavor flavor) async {
  // Late-bound on purpose. The boundary has to be live before the container
  // exists, because the container is built by the very code it guards: an
  // error during storage or Firebase setup is exactly the one worth catching.
  ProviderContainer? container;

  await runGuarded(
    () => _bootstrap(flavor, (built) => container = built),
    onError: (error, stack) => handleBootstrapError(
      error,
      stack,
      container: container,
    ),
  );
}

Future<void> _bootstrap(
  Flavor flavor,
  void Function(ProviderContainer) onContainerReady,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  installAppErrorView();

  await bootstrapFirebase(flavor);
  await activateAppCheck(flavor);

  final overrides = await bootstrapStorageOverrides();
  final contentOverrides = await bootstrapContentOverrides();
  final remoteFlagsOverrides = await bootstrapRemoteFlagsOverrides();

  final container = ProviderContainer(
    overrides: [
      ...overrides,
      ...contentOverrides,
      ...remoteFlagsOverrides,
      ...mockEntitlementOverrides,
      ...telemetryConsentOverrides,
      // Only when Firebase actually started. It does not yet: there is no
      // project, so `bootstrapFirebase` initializes nothing. The gate above
      // this still decides whether anything reaches the sink.
      telemetrySinkProvider.overrideWithValue(
        FirebaseTelemetry.instancesIfAvailable(),
      ),
      // The review popup and the record of having asked. Both are inert
      // until this runs, so nothing pops in a test.
      appReviewGatewayProvider.overrideWith((ref) => InAppReviewGateway()),
      reviewPromptStoreProvider.overrideWith(
        (ref) => DriftReviewPromptStore(ref.watch(appDatabaseProvider)),
      ),
      notificationsGatewayProvider.overrideWith(
        (ref) => ref.watch(liveNotificationsGatewayProvider),
      ),
      notificationServiceProvider.overrideWith(
        (ref) => ref.watch(featureNotificationServiceProvider),
      ),
      notificationPermissionStatusProvider.overrideWith(
        (ref) => ref.watch(featurePermissionStatusStreamProvider),
      ),
    ],
  );
  onContainerReady(container);

  await applyPersistedTelemetryConsent(container);
  await registerDevProSwitch(container);
  await registerDevDemoSwitch(container);
  await _installContentSeed(container);
  await bootstrapRevenueCat(container);

  final notificationsLifecycleObserver = NotificationsLifecycleObserver(
    service: container.read(notificationServiceProvider),
  );
  WidgetsBinding.instance.addObserver(notificationsLifecycleObserver);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: App(flavor: flavor),
    ),
  );
}

Future<void> _installContentSeed(ProviderContainer container) async {
  final prefs = container.read(appPreferencesRepositoryProvider);
  final wrote = await SeedInstaller().install(
    installedVersion: await prefs.installedContentSeedVersion(),
    bundledVersion: contentSeedVersion,
  );
  if (wrote) {
    await prefs.setInstalledContentSeedVersion(contentSeedVersion);
  }
}

/// Reads persisted telemetry preference and applies it to [telemetryConsentControllerProvider].
Future<void> applyPersistedTelemetryConsent(
  ProviderContainer container,
) async {
  try {
    final settings = await container.read(userSettingsProvider.future);
    final controller = container.read(
      telemetryConsentControllerProvider.notifier,
    );
    await controller.setAnalyticsCollectionEnabled(
      enabled: settings.helpImproveApp,
    );
  } catch (error, stack) {
    debugPrint('Failed to apply persisted telemetry consent: $error\n$stack');
  }
}
