import 'dart:async';

import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/firebase_bootstrap.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/app/telemetry_providers.dart';
import 'package:cse_cet_reviewer/core/content/bundle/seed_installer.dart';
import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/content/content_database_opener.dart';
import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/platform/app_check.dart';
import 'package:cse_cet_reviewer/core/platform/remote_flags_providers.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/telemetry/error_boundary.dart';
import 'package:cse_cet_reviewer/core/telemetry/firebase_telemetry.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_error_view.dart';
import 'package:cse_cet_reviewer/features/mock_exam/application/mock_availability_provider.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:cse_cet_reviewer/features/notifications/application/notifications_providers.dart';
import 'package:cse_cet_reviewer/features/notifications/presentation/notifications_lifecycle_observer.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

Future<void> bootstrap(Flavor flavor) async {
  // Late-bound on purpose. The boundary has to be live before the container
  // exists, because the container is built by the very code it guards: an
  // error during storage or Firebase setup is exactly the one worth catching.
  ProviderContainer? container;

  await runGuarded(
    () => _bootstrap(flavor, (built) => container = built),
    onError: (error, stack) {
      // Reports only if the student has said yes. Before settings load, and
      // before they have answered, the gate is shut and this collects nothing.
      container?.read(telemetryProvider).recordError(error, stack);
      debugPrint('Uncaught: $error\n$stack');
    },
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
      // Only when Firebase actually started. It does not yet: there is no
      // project, so `bootstrapFirebase` initializes nothing. The gate above
      // this still decides whether anything reaches the sink.
      telemetrySinkProvider.overrideWithValue(
        FirebaseTelemetry.instancesIfAvailable(),
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

  await _installContentSeed(container);
  await bootstrapRevenueCat(container);
  await container.read(seederProvider).maybeSeed();

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
