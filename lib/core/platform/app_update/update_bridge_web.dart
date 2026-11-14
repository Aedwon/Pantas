import 'dart:js_interop';

import 'package:pantas/core/platform/app_update/update_bridge.dart';
// Already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

extension type _PantasUpdate(JSObject _) implements JSObject {
  external JSPromise<_Status> check();
  external JSPromise<JSAny?> apply();
}
extension type _Status(JSObject _) implements JSObject {
  external bool get available;
  external String? get version;
}
@JS('pantasUpdate')
external _PantasUpdate? get _update;

UpdateBridge createUpdateBridge() => const _WebUpdateBridge();

class _WebUpdateBridge implements UpdateBridge {
  const _WebUpdateBridge();
  @override
  Future<UpdateStatus> check() async {
    final bridge = _update;
    if (bridge == null) {
      return const UpdateStatus(available: false, version: null);
    }
    final status = await bridge.check().toDart;
    return UpdateStatus(available: status.available, version: status.version);
  }

  @override
  Future<void> apply() async {
    // Activation can wait for the worker. Hold input at this already-safe
    // point so a click cannot start a session or open an unsaved form before
    // JS reloads. There is no visible control or layout change.
    final block = ((web.Event event) {
      event
        ..preventDefault()
        ..stopImmediatePropagation();
    }).toJS;
    const events = [
      'pointerdown',
      'pointerup',
      'pointermove',
      'pointercancel',
      'wheel',
      'scroll',
      'touchstart',
      'touchmove',
      'touchend',
      'touchcancel',
      'click',
      'keydown',
      'keyup',
      'input',
      'change',
      'compositionstart',
      'compositionupdate',
      'compositionend',
      'drop',
      'beforeinput',
      'submit',
    ];
    for (final event in events) {
      web.window.addEventListener(
        event,
        block,
        web.AddEventListenerOptions(capture: true, passive: false),
      );
    }
    try {
      await _update?.apply().toDart;
    } finally {
      for (final event in events) {
        web.window.removeEventListener(event, block, true.toJS);
      }
    }
  }
}
