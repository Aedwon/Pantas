import 'dart:async';

import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/firebase_bootstrap.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/telemetry/error_boundary.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_error_view.dart';
import 'package:cse_cet_reviewer/features/notifications/application/notifications_providers.dart';
import 'package:cse_cet_reviewer/features/notifications/presentation/notifications_lifecycle_observer.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap(Flavor flavor) async {
  await runGuarded(
    () => _bootstrap(flavor),
    // TODO(task-3): forward to the telemetry gate built by
    // docs/superpowers/plans/2026-08-03-foundations-01-observability.md Task 3.
    // The boundary goes live before the reporter deliberately: catching an
    // error and printing it beats not catching it at all.
    onError: (error, stack) {
      debugPrint('Uncaught: $error\n$stack');
    },
  );
}

Future<void> _bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  installAppErrorView();

  await bootstrapFirebase(flavor);

  final overrides = await bootstrapStorageOverrides();
  final container = ProviderContainer(
    overrides: [
      ...overrides,
      notificationServiceProvider.overrideWith(
        (ref) => ref.watch(featureNotificationServiceProvider),
      ),
      notificationPermissionStatusProvider.overrideWith(
        (ref) => ref.watch(featurePermissionStatusStreamProvider),
      ),
    ],
  );
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
