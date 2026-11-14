import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/auth_bootstrap.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/app/content_access_bridge.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/local_onboarding_preset_apply.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/start_location.dart';
import 'package:pantas/app/startup_gates.dart';
import 'package:pantas/app/sync_runtime_bootstrap.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/content/bundle/protected_content_installer.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/content_database_memory.dart';
import 'package:pantas/core/content/content_database_opener.dart';
import 'package:pantas/core/content/security/content_package_verifier.dart';
import 'package:pantas/core/content/security/content_signing_keys.dart';
import 'package:pantas/core/dev/dev_demo_switch.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/dev/local_panel_bridge.dart';
import 'package:pantas/core/dev/local_student_startup.dart';
import 'package:pantas/core/error/app_error_recovery.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/platform/app_check.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/platform/install/install_providers.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/telemetry/client_report.dart';
import 'package:pantas/core/telemetry/error_boundary.dart';
import 'package:pantas/core/telemetry/firebase_telemetry.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';
import 'package:pantas/core/telemetry/usage_visit.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/font_licenses.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/domain/mock_availability.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/notifications/presentation/notifications_lifecycle_observer.dart';
import 'package:pantas/features/onboarding/application/setup_acceptance.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
import 'package:pantas/features/review_prompt/data/in_app_review_gateway.dart';
import 'package:pantas/features/review_prompt/data/review_prompt_store.dart';
import 'package:pantas/features/roadmap/application/lesson_links_loader.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

const _contentBootstrapKeyId = 'content-bootstrap-v1';
const _contentBootstrapKeyB64 = String.fromEnvironment(
  'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64',
);

Future<Uint8List> _loadContentPackageAssetBytes(String path) async {
  final data = await rootBundle.load(path);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

ContentBootstrapKeyEntry? _lookupContentBootstrapKey(String keyId) {
  if (keyId != _contentBootstrapKeyId || _contentBootstrapKeyB64.isEmpty) {
    return null;
  }

  final Uint8List keyBytes;
  try {
    keyBytes = base64Decode(_contentBootstrapKeyB64);
  } on FormatException {
    return null;
  }

  if (keyBytes.length != 32) {
    return null;
  }

  return ContentBootstrapKeyEntry(
    keyId: _contentBootstrapKeyId,
    keyBytes: keyBytes,
    sequenceWindow: const ContentSequenceWindow(minReleaseSequence: 1),
  );
}

/// Feeds active-exam coverage into the mock cooldown and roadmap.
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
      proIsActive: ref.watch(proForActiveExamProvider).valueOrNull ?? false,
    ),
  ),
];

/// Feeds the shipping telemetry consent gateway into settings actions and
/// startup.
///
/// Exposed as a list so tests can exercise the exact telemetry override
/// collection
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
  var handed = false;
  try {
    container?.read(telemetryProvider).recordError(error, stack).ignore();
    handed = container != null;
  } catch (e) {
    debugPrint('Telemetry recordError failed: $e');
  }
  // Before the app has a container, or if it cannot be read, the web reporter
  // still hears the error. With a container it already did, through the gate.
  if (!handed) ClientReporter.active?.recordError(error, stack);
  debugPrint('Uncaught: $error\n$stack');
}

/// Report while consent and telemetry still exist, then stop failed services.
void disposeFailedStartup(
  Object error,
  StackTrace stack, {
  ProviderContainer? container,
}) {
  handleBootstrapError(error, stack, container: container);
  container?.dispose();
}

typedef BootstrapInitializer = Future<void> Function(
  Flavor flavor,
  void Function(ProviderContainer) onContainerReady,
);

Future<void> bootstrap(
  Flavor flavor, {
  BootstrapInitializer? initialize,
  bool releaseMode = kReleaseMode,
}) async {
  ProviderContainer? container;
  var starting = false;
  var surfaceMounted = false;
  final startupPage = ValueNotifier<Widget>(const SizedBox.shrink());
  late VoidCallback retry;

  Widget surface(Widget page) => MaterialApp(
        key: UniqueKey(),
        title: flavor.displayName,
        theme: appLightTheme(),
        darkTheme: appDarkTheme(),
        home: page,
      );

  void showStartup(Widget page) {
    startupPage.value = page;
    if (surfaceMounted) return;
    surfaceMounted = true;
    runApp(
      surface(
        ValueListenableBuilder<Widget>(
          valueListenable: startupPage,
          builder: (context, page, _) => page,
        ),
      ),
    );
  }

  Future<void> attempt() async {
    if (starting) return;
    starting = true;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      registerBundledFontLicenses();
      installAppErrorRecovery(
        releaseMode: releaseMode,
        onRetry: () {
          final ready = container;
          if (ready == null) {
            retry();
          } else {
            // Rebuild the root route, keeping the running data/services intact.
            ready.invalidate(routerProvider);
          }
        },
      );
      showStartup(
        Scaffold(
          body: Center(child: loadingFor(const AsyncLoading<void>())),
        ),
      );
      await (initialize ?? _bootstrap)(flavor, (built) => container = built);
      startupPage.dispose();
    } catch (error, stack) {
      disposeFailedStartup(error, stack, container: container);
      container = null;
      showStartup(StateView.fullScreen(error: error, onRetry: retry));
      sendAppStarted();
    } finally {
      starting = false;
    }
  }

  await runGuarded(
    () async {
      // Retry events can arrive through a different event zone. Binding keeps
      // runApp in the zone that initialized Flutter.
      retry = Zone.current.bindCallback(() => attempt().ignore());
      await attempt();
    },
    onError: (error, stack) =>
        handleBootstrapError(error, stack, container: container),
  );
}

/// Firebase's low-level bootstrap intentionally reports unavailable. At startup
/// that result needs the same recovery screen as storage/content failures.
Future<FirebaseBootstrapResult> bootstrapFirebaseForStartup(
  Flavor flavor, {
  FirebaseBootAdapter adapter = const FirebaseSdkBootAdapter(),
}) async {
  final result = await bootstrapFirebase(flavor, adapter: adapter);
  if (result == FirebaseBootstrapResult.unavailable) {
    throw StateError('Firebase setup failed.');
  }
  return result;
}

Future<void> _bootstrap(
  Flavor flavor,
  void Function(ProviderContainer) onContainerReady,
) async {
  AppDatabase? database;
  ContentDatabase? contentDatabase;
  ProviderContainer? ownedContainer;
  rememberStartLocation(Uri.base);
  rememberLocalStudentUrl();
  rememberLocalAccount();
  try {
    final firebaseResult = await bootstrapFirebaseForStartup(flavor);
    PerfTimeline.mark('boot.firebase');
    // The flags fetch only needs Firebase, so it runs beside the steps below
    // and is awaited where the flags are used. It never throws: a failure or
    // a timeout yields the fallback flags.
    final remoteFlags = bootstrapRemoteFlagsOverrides();
    // Web only, always on, sends no identity. Never blocks startup.
    ClientReporter.startForWeb();
    await activateAppCheck(flavor);
    PerfTimeline.mark('boot.appcheck');

    final overrides = await bootstrapStorageOverrides();
    // Capture the facade's handle. Its value override has no auto-disposal.
    final storageLookup = ProviderContainer(overrides: overrides);
    database = storageLookup.read(appDatabaseProvider);
    storageLookup.dispose();
    PerfTimeline.mark('boot.storage');
    // Web has no bundled content package. Lessons and question sets come
    // from the server through the content service (plan task C7).
    if (!kIsWeb) {
      await ensureProtectedContentInstalled(
        verifier: const BundledContentPackageVerifier(
          loadAssetBytes: _loadContentPackageAssetBytes,
          signingKeyLookup: ContentSigningKeys.lookupEntry,
          bootstrapKeyLookup: _lookupContentBootstrapKey,
        ),
      );
    }
    final contentOverrides = kIsWeb
        ? await bootstrapWebContentOverrides(
            open: () async {
              final opened = await openInMemoryContentDatabase();
              contentDatabase = opened;
              return opened;
            },
          )
        : await bootstrapContentOverrides(
            open: () async {
              final opened = await openProtectedContentDatabase();
              contentDatabase = opened;
              return opened;
            },
          );
    PerfTimeline.mark('boot.contentdb');
    final remoteFlagsOverrides = await remoteFlags;
    PerfTimeline.mark('boot.flags');
    final authOverrides = authRepositoryOverrides(firebaseResult);

    final container = ProviderContainer(
      overrides: [
        ...overrides,
        ...contentOverrides,
        ...remoteFlagsOverrides,
        ...authOverrides,
        ...mockEntitlementOverrides,
        ...telemetryConsentOverrides,
        // Web plans on the server and bundles no links.
        if (!kIsWeb)
          lessonLinksProvider.overrideWithValue(
            await loadLessonLinks(rootBundle),
          ),
        // Install the Firebase telemetry sink only when live Firebase instances
        // are available. User consent still gates anything reaching the sink.
        // On the web it also keeps a readable copy of the screen views, which
        // stays behind the same consent gate.
        telemetrySinkProvider.overrideWithValue(
          UsageVisitTelemetry.wrapForWeb(
            FirebaseTelemetry.instancesIfAvailable(),
          ),
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
    ownedContainer = container;
    onContainerReady(container);

    await bootstrapAuthSession(container, firebaseResult);
    PerfTimeline.mark('boot.auth');
    // The beta check is a server call. Start it now so it runs beside the
    // content restore, consent and sync steps. The router reuses its result.
    startBetaAccessCheck(container);
    // Payment setup waits on the network too and needs only storage and auth,
    // so it runs beside the content restore. It is awaited below, before sync
    // and the first screen, as it was before.
    final payments = bootstrapRevenueCat(container);
    // Awaited below; this only keeps an early failure in a step in between
    // from also being reported as unhandled.
    unawaited(
      payments.then<void>((_) {}, onError: (Object _, StackTrace __) {}),
    );
    (Object, StackTrace)? reprojectFailure;
    if (kIsWeb) {
      // Listen for the browser's install events from the first frame and ask
      // it to keep storage once Pantas runs installed.
      container.read(installPlatformProvider).start();
      reprojectFailure = await startWebContent(container);
    }
    PerfTimeline.mark('boot.content');
    await applyPersistedTelemetryConsent(container);
    if (reprojectFailure case (final error, final stack)) {
      unawaited(container.read(telemetryProvider).recordError(error, stack));
    }
    PerfTimeline.mark('boot.consent');
    // A named account's setup acceptance reaches the server, best effort. It
    // retries on each start until it succeeds.
    container.read(setupAcceptanceSyncProvider);
    // A minor's sharing follows the guardian's choice. It reads the server, so
    // startup does not wait for it.
    unawaited(
      container.read(minorSharingProvider.future).then<void>(
            (_) {},
            onError: (Object _, StackTrace __) {},
          ),
    );
    await registerDevProSwitch(container);
    await registerDevDemoSwitch(container);
    await payments;
    PerfTimeline.mark('boot.payments');
    await bootstrapSyncRuntime(container, firebaseResult);
    PerfTimeline.mark('boot.sync');
    // Local runs with ?localStudent=: the server records are written before the
    // first screen, so Home never holds a read from before them.
    if (await loadLocalStudentFromUrl(container)) {
      // Loading dropped every provider, including the payment gateway that
      // startup had signed in, so the account's Pro coverage was gone.
      await bootstrapRevenueCat(container);
    }
    registerLocalOnboardingPresets();
    await startLocalPanelBridge(container);
    // No page, Home included, may mount before the onboarding redirect can
    // see where the student is.
    await settleGatesBeforeFirstPage(container);
    PerfTimeline.mark('boot.gates');

    final notificationsLifecycleObserver = NotificationsLifecycleObserver(
      service: container.read(notificationServiceProvider),
    );
    WidgetsBinding.instance.addObserver(notificationsLifecycleObserver);

    sendAppStarted();
    PerfTimeline.mark('boot.runapp');
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: App(flavor: flavor),
      ),
    );
  } catch (error, stack) {
    // A retry opens fresh handles. Report before disposing consent/services.
    if (ownedContainer != null) {
      disposeFailedStartup(error, stack, container: ownedContainer);
    }
    final failedContent = contentDatabase;
    if (failedContent != null) {
      try {
        await failedContent.close();
      } catch (error) {
        debugPrint('Startup content cleanup failed: $error');
      }
    }
    if (database != null) {
      try {
        await database.close();
      } catch (error) {
        debugPrint('Startup storage cleanup failed: $error');
      }
    }
    rethrow;
  }
}

/// Web only. Fills the in-memory content database from the cache in the study
/// database, refreshes the catalog, and starts watching sign-out so cached
/// Pro-only fields are removed. A failure leaves the app running without
/// content.
///
/// Then puts the student's own custom exams back into that database, which a
/// reload empties. This runs even if the content above failed, and a failure
/// of its own is returned, not thrown: the student reaches the picker and finds
/// the exam under "Your exams". Telemetry consent is not applied yet, so the
/// caller reports the returned failure once it is.
@visibleForTesting
Future<(Object, StackTrace)?> startWebContent(
  ProviderContainer container,
) async {
  try {
    await container.read(contentMirrorProvider).start();
    container.read(contentAccessBridgeProvider);
  } catch (error, stack) {
    debugPrint('Web content did not start: $error\n$stack');
  }
  try {
    await container.read(customTrackRepositoryProvider).reprojectAll();
  } catch (error, stack) {
    debugPrint('Custom exams did not load: ${error.runtimeType}');
    return (error, stack);
  }
  return null;
}

/// Reads persisted telemetry preference and applies it to the telemetry consent
/// controller provider.
Future<void> applyPersistedTelemetryConsent(
  ProviderContainer container,
) async {
  try {
    final settings = await container.read(userSettingsProvider.future);
    final controller = container.read(
      telemetryConsentControllerProvider.notifier,
    );
    ClientReporter.active?.enabled = settings.speedReportsEnabled;
    await controller.applyStartupConsent(
      enabled: settings.helpImproveApp,
    );
  } catch (error, stack) {
    debugPrint('Failed to apply persisted telemetry consent: $error\n$stack');
  }
}
