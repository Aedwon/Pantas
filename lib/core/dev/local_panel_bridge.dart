import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/dev/local_panel_platform.dart';
import 'package:pantas/core/dev/local_panel_types.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';

export 'package:pantas/core/dev/local_panel_types.dart';

/// The local test panel's listener (`tools/local/panel/index.html`).
///
/// The panel is a page in a second browser tab of a local run. It sends JSON
/// text over `BroadcastChannel('pantas-local-panel')`:
///
/// - `{type: 'ping'}`: the app replies with a status.
/// - `{type: 'go', path}`: opens a screen. `:examId` in the path is filled
///   with the active exam.
/// - `{type: 'plan', value: 'free' | 'pro' | 'real'}`: sets the Free and Pro
///   switch. It is not stored.
/// - `{type: 'fresh'}`: the app replies `ack` and opens the reset page.
///
/// The app sends `{type: 'status', route, plan}` on a ping, after a plan
/// change and on every screen change.
///
/// The panel writes its own `pantas.local.*` keys, so there is no message for
/// presets or sample students. The panel stores a preset id under
/// `pantas.local.preset` and starts fresh. After startup the bridge reads and
/// removes that key and hands the id to [applyLocalPreset].
///
/// Nothing here runs unless the build is a local run in a browser.

/// Set by the onboarding presets. Called once after startup with the preset id
/// the panel stored. Null when no preset code is present.
Future<void> Function(ProviderContainer container, String id)? applyLocalPreset;

/// The `localStorage` key the panel stores a preset id under.
const localPresetKey = 'pantas.local.preset';

LocalPanelBridge? _bridge;

/// Starts the bridge for a local run in a browser, and does nothing in any
/// other build. Call after startup, before the first screen.
///
/// [channel] and [page] are for tests; a browser supplies its own.
Future<void> startLocalPanelBridge(
  ProviderContainer container, {
  LocalPanelChannel? channel,
  LocalPanelPage? page,
}) async {
  // Both are compile-time constants: normal builds drop everything below.
  if (!localEmulators || !kIsWeb) return;
  final openedChannel = channel ?? openLocalPanelChannel();
  final openedPage = page ?? localPanelPage();
  if (openedChannel == null || openedPage == null) return;
  _bridge?.dispose();
  final bridge = LocalPanelBridge(
    container: container,
    channel: openedChannel,
    page: openedPage,
  );
  _bridge = bridge..start();
  // The first frame draws before the router is read or a preset is applied.
  unawaited(
    Future<void>.delayed(Duration.zero, () async {
      bridge.attachRouter();
      await bridge.applyStoredPreset();
    }),
  );
}

/// Handles one panel message. Exposed for tests.
Future<void> handlePanelMessage(
  Map<String, Object?> message,
  ProviderContainer container,
  LocalPanelChannel channel, {
  required LocalPanelPage page,
}) =>
    LocalPanelBridge(container: container, channel: channel, page: page)
        .handle(message);

class LocalPanelBridge {
  LocalPanelBridge({
    required this.container,
    required this.channel,
    required this.page,
  });

  final ProviderContainer container;
  final LocalPanelChannel channel;
  final LocalPanelPage page;

  StreamSubscription<Map<String, Object?>>? _messages;
  ProviderSubscription<GoRouter>? _routerSubscription;
  GoRouter? _watched;
  String? _lastRoute;

  /// Starts answering the panel.
  void start() {
    _messages ??= channel.messages.listen(
      (message) => unawaited(handle(message)),
    );
  }

  /// Sends a status on every screen change. The router is rebuilt when the
  /// app recovers from an error, so this follows the new one.
  void attachRouter() {
    _routerSubscription ??= container.listen<GoRouter>(
      routerProvider,
      (_, next) => _watch(next),
      fireImmediately: true,
    );
  }

  void _watch(GoRouter router) {
    _watched?.routerDelegate.removeListener(_onRouteChange);
    _watched = router..routerDelegate.addListener(_onRouteChange);
  }

  void _onRouteChange() {
    final route = _route();
    if (route == _lastRoute) return;
    _sendStatus();
  }

  void dispose() {
    _watched?.routerDelegate.removeListener(_onRouteChange);
    _watched = null;
    _routerSubscription?.close();
    _routerSubscription = null;
    unawaited(_messages?.cancel());
    _messages = null;
    channel.close();
  }

  Future<void> handle(Map<String, Object?> message) async {
    switch (message['type']) {
      case 'ping':
        _sendStatus();
      case 'go':
        await _go(message['path']);
      case 'plan':
        _setPlan(message['value']);
      case 'fresh':
        channel.send({'type': 'ack'});
        page.navigate('/local-reset.html');
    }
  }

  Future<void> _go(Object? requested) async {
    if (requested is! String) return;
    // An app path only: no address of another site.
    if (!requested.startsWith('/') || requested.startsWith('//')) return;
    var path = requested;
    if (path.contains(':examId')) {
      final focus = await container.read(activeExamFocusProvider.future);
      final exam = focus.exam;
      if (exam == null) {
        debugPrint('Local panel: no active exam for $requested');
        return;
      }
      path = path.replaceAll(':examId', Uri.encodeComponent(exam.id));
    }
    // The panel fills every other ID. A path still holding one cannot open.
    if (path.contains('/:')) return;
    final router = container.read(routerProvider);
    if (_isTabShellPath(path)) {
      router.go(path);
    } else {
      unawaited(router.push<Object?>(path));
    }
  }

  void _setPlan(Object? value) {
    final next = switch (value) {
      'pro' => (true,),
      'free' => (false,),
      'real' => (null,),
      _ => null,
    };
    if (next == null) return;
    devProOverride.value = next.$1;
    _sendStatus();
  }

  void _sendStatus() {
    final route = _route();
    _lastRoute = route;
    channel.send({
      'type': 'status',
      'route': route,
      'plan': switch (devProOverride.value) {
        true => 'pro',
        false => 'free',
        null => 'real',
      },
    });
  }

  /// The screen on top, including one pushed over the tabs. The list's own
  /// address ignores pushed screens.
  String _route() {
    final shown =
        container.read(routerProvider).routerDelegate.currentConfiguration;
    return shown.lastOrNull?.matchedLocation ?? shown.uri.path;
  }

  /// Reads and removes the preset id the panel stored before it started fresh,
  /// and hands it to [applyLocalPreset]. A failure is logged; the app keeps
  /// running as it was.
  Future<void> applyStoredPreset() async {
    final id = page.takeStored(localPresetKey);
    final apply = applyLocalPreset;
    if (id == null || id.isEmpty || apply == null) return;
    try {
      await apply(container, id);
    } on Object catch (error, stack) {
      debugPrint('Local preset "$id" did not apply: $error\n$stack');
    }
  }
}

/// Screens inside the four-tab shell are reached with `go`. Everything else
/// is pushed, so back works (AGENTS.md, Navigation).
bool _isTabShellPath(String path) {
  const roots = ['/home', '/study', '/quiz', '/settings'];
  const homePages = [
    '/plan',
    '/performance',
    '/record',
    '/tendencies',
  ];
  final route = Uri.parse(path).path;
  if (roots.contains(route)) return true;
  return homePages.any((root) => route == root || route.startsWith('$root/'));
}
