import 'dart:async';

import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/firebase_bootstrap.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/app/telemetry_providers.dart';
import 'package:cse_cet_reviewer/core/content/bundle/seed_installer.dart';
import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/telemetry/error_boundary.dart';
import 'package:cse_cet_reviewer/core/telemetry/firebase_telemetry.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_error_view.dart';
import 'package:cse_cet_reviewer/features/notifications/application/notifications_providers.dart';
import 'package:cse_cet_reviewer/features/notifications/presentation/notifications_lifecycle_observer.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final overrides = await bootstrapStorageOverrides();

  // The content database must be on disk before it can be opened, so the
  // install runs before the overrides that open it.
  await SeedInstaller().install();
  final contentOverrides = await bootstrapContentOverrides();

  final container = ProviderContainer(
    overrides: [
      ...overrides,
      ...contentOverrides,
      // Firebase is initialized by now, so the SDK-backed sink is safe to
      // build. The gate above it still decides whether anything reaches it.
      telemetrySinkProvider.overrideWithValue(FirebaseTelemetry.instances()),
      notificationServiceProvider.overrideWith(
        (ref) => ref.watch(featureNotificationServiceProvider),
      ),
      notificationPermissionStatusProvider.overrideWith(
        (ref) => ref.watch(featurePermissionStatusStreamProvider),
      ),
    ],
  );
  onContainerReady(container);

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
