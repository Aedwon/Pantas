import 'dart:js_interop';

/// The small script in `web/pantas_pwa.js`.
extension type _PantasPwa(JSObject _) implements JSObject {
  external JSPromise<JSAny?> updateNow();
}

@JS('pantasPwa')
external _PantasPwa? get _pwa;

@JS('location.reload')
external void _reload();

/// Drops this browser's service worker and cached app files, then reloads so
/// the page loads the newest build from the network.
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
