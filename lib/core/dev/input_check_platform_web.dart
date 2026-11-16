import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:pantas/core/dev/input_check.dart';
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

/// The browser's session storage, which survives the address rewrite and a
/// reload but not a closed tab.
InputCheckStore createInputCheckStore() => const _SessionStore();

class _SessionStore implements InputCheckStore {
  const _SessionStore();

  @override
  String? read(String key) {
    try {
      return web.window.sessionStorage.getItem(key);
    } on Object {
      return null;
    }
  }

  @override
  void write(String key, String? value) {
    try {
      if (value == null) {
        web.window.sessionStorage.removeItem(key);
      } else {
        web.window.sessionStorage.setItem(key, value);
      }
    } on Object {
      // Blocked storage: the choice still holds for this load.
    }
  }
}

/// Calls [onVsync] on every screen refresh, whether or not Flutter draws.
/// requestAnimationFrame ticks once per refresh, so it counts vsyncs that
/// Flutter skips. Returns the stop function.
void Function() startVsyncCounter(void Function() onVsync) {
  var running = true;
  late final JSFunction tick;
  tick = ((double _) {
    if (!running) return;
    onVsync();
    web.window.requestAnimationFrame(tick);
  }).toJS;
  web.window.requestAnimationFrame(tick);
  return () => running = false;
}

/// Puts the numbers on `globalThis.__pantasPerf` for headless measurement.
void publishInputCheck(Map<String, Object?> data) {
  globalContext.setProperty('__pantasPerf'.toJS, data.jsify());
}
