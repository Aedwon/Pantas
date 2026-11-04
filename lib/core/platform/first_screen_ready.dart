import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/platform/first_screen_ready_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/platform/first_screen_ready_web.dart'
    as platform;

/// Tells the page the app is about to show a real screen, so the logo may start
/// its limit. Before this nothing useful is drawn underneath it.
void sendAppStarted() => platform.sendAppStarted();

/// True when this page began from the HTML splash (a returning visit), so the
/// app's first screen sits settled under the fading splash instead of playing
/// its own entrance a second time (4P-2). Tests replace the probe.
bool pageBeganFromSplash() => splashProbe();

@visibleForTesting
bool Function() splashProbe = platform.pageBeganFromSplash;

/// Runs [action] once the HTML splash has left the page, at once when none
/// covers it. A screen that must not show under the fading splash waits here
/// (4P-2). Tests replace the probe.
void afterSplashGone(VoidCallback action) => splashGoneProbe(action);

@visibleForTesting
void Function(VoidCallback) splashGoneProbe = platform.afterSplashGone;

final firstScreenSignalProvider = Provider<FirstScreenSignal>(
  (ref) => FirstScreenSignal(platform.sendFirstScreenReady),
);

class FirstScreenSignal {
  FirstScreenSignal(this._send);
  final VoidCallback _send;
  bool _sent = false;
  void ready() {
    if (_sent) return;
    _sent = true;
    _send();
  }
}

class FirstScreenReady extends ConsumerWidget {
  const FirstScreenReady({required this.child, this.ready = true, super.key});
  final Widget child;
  final bool ready;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    firstScreenReady(context, ref, ready: ready);
    return child;
  }
}

/// Call from the screen that owns the data, after its loading branch settles.
/// The post-frame callback ensures content or its error is drawn underneath.
void firstScreenReady(
  BuildContext context,
  WidgetRef ref, {
  bool ready = true,
  String? path,
}) {
  final router = GoRouter.maybeOf(context);
  if (path != null &&
      router != null &&
      router.routeInformationProvider.value.uri.path != path) {
    return;
  }
  if (!ready ||
      !TickerMode.valuesOf(context).enabled ||
      ModalRoute.of(context)?.isCurrent == false) {
    return;
  }
  final signal = ref.read(firstScreenSignalProvider);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted &&
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      signal.ready();
    }
  });
}
