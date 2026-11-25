import 'dart:js_interop';

/// The small script in `web/pantas_pwa.js`.
extension type _PantasPwa(JSObject _) implements JSObject {
  external JSPromise<JSAny?> updateNow();
}

@JS('pantasPwa')
external _PantasPwa? get _pwa;

@JS('location.reload')
external void _reload();

/// Asks the browser for the newest service worker, switches to it when it is
/// ready and this is the only window, then reloads. It never removes the worker
/// or its cached files, so a lost connection leaves the installed app bootable.
Future<void> updateWebAppInPlace() async {
  final pwa = _pwa;
  if (pwa == null) {
    _reload();
    return;
  }
  try {
    await pwa.updateNow().toDart;
  } on Object {
    _reload();
  }
}
