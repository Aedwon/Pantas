import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/platform/app_update/update_bridge.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';
import 'package:pantas/core/platform/app_update/update_overlay_registry.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/report_failure.dart';

final updateCoordinatorProvider = Provider<UpdateCoordinator>((ref) {
  final coordinator = UpdateCoordinator(
    bridge: createUpdateBridge(),
    waitForWrites: () => ref.read(appDatabaseProvider).waitForDurableWrites(),
    onFailure: (error, stack) => reportFailure(
      ref.read(telemetryProvider),
      'update.apply',
      error,
      stack,
    ),
  );
  if (kIsWeb) {
    void overlaysChanged() {
      coordinator.setOverlay(
        updateOverlayRegistry,
        visible: updateOverlayRegistry.hasOpenOverlays,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(coordinator.check());
      });
    }

    updateOverlayRegistry.addListener(overlaysChanged);
    ref.onDispose(() => updateOverlayRegistry.removeListener(overlaysChanged));
    final lifecycle = _UpdateLifecycle(coordinator);
    WidgetsBinding.instance.addObserver(lifecycle);
    // JS caches checks for five minutes. Polling also picks up its visibility
    // checks while Home remains open, without a route change.
    final timer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(coordinator.check());
    });
    ref.onDispose(() {
      timer.cancel();
      WidgetsBinding.instance.removeObserver(lifecycle);
    });
  }
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

class _UpdateLifecycle extends WidgetsBindingObserver {
  _UpdateLifecycle(this.coordinator);
  final UpdateCoordinator coordinator;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(coordinator.check());
  }
}

/// Attach to every router navigator, including the phone's tab branches.
/// Popup routes do not change the URL, but must still block a reload.
class UpdateOverlayObserver extends NavigatorObserver {
  UpdateOverlayObserver(this.coordinator);
  final UpdateCoordinator coordinator;
  final Set<Route<dynamic>> _popups = {};

  void _changed() {
    coordinator.setOverlay(this, visible: _popups.isNotEmpty);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(coordinator.check());
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute) _popups.add(route);
    _changed();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _popups.remove(route);
    _changed();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _popups.remove(route);
    _changed();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _popups.remove(oldRoute);
    if (newRoute is PopupRoute) _popups.add(newRoute);
    _changed();
  }
}

/// Holds the safe route for the entire asynchronous activation. Bypass normal
/// redirects even on that path, so an auth/flags refresh cannot bounce between
/// the held route and a gate until go_router reaches its redirect limit.
GoRouterRedirect guardUpdateActivation(
  UpdateCoordinator? coordinator,
  GoRouterRedirect redirect,
) =>
    (context, state) {
      if (coordinator != null && coordinator.isApplying) {
        return state.uri.path == coordinator.currentPath
            ? null
            : coordinator.currentPath;
      }
      return redirect(context, state);
    };

/// Observes settled matches rather than incoming URLs or tab highlights.
/// The delegate is empty until Router performs its first parse during boot.
VoidCallback observeUpdateRoutes(GoRouter router, UpdateCoordinator updates) {
  void routeChanged() {
    if (router.routerDelegate.currentConfiguration.isEmpty) return;
    updates.routeChanged(router.state.uri.path);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(updates.check());
    });
  }

  router.routerDelegate.addListener(routeChanged);
  routeChanged();
  return () => router.routerDelegate.removeListener(routeChanged);
}
