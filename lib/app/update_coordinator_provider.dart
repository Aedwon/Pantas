import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/remote/content_service_providers.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';
import 'package:pantas/core/platform/app_update/update_overlay_registry.dart';
import 'package:pantas/core/telemetry/report_failure.dart';

final updateCoordinatorProvider = Provider<UpdateCoordinator>((ref) {
  final coordinator = UpdateCoordinator(
    onFailure: (error, stack) => reportFailure(
      ref.read(telemetryProvider),
      'update.apply',
      error,
      stack,
    ),
    // The web content mirror compares the server's content version at safe
    // points (Home, the end of a lesson or a quiz, no overlay open).
    onSafePoint: kIsWeb
        ? () => ref.read(contentMirrorProvider).checkContentVersion()
        : null,
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
    ref.onDispose(() {
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
