import 'dart:js_interop';

import 'package:pantas/core/platform/app_update/update_bridge.dart';

extension type _PantasUpdate(JSObject _) implements JSObject {
  external JSPromise<_Status> check();
  // A promise of true or false from web/pantas_pwa.js. An older page script
  // returns nothing and reloads on its own, which counts as applied.
  external JSAny? apply();
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
  Future<bool> apply() async {
    final bridge = _update;
    if (bridge == null) return false;
    final result = bridge.apply();
    final settled = result.isA<JSPromise<JSAny?>>()
        ? await (result! as JSPromise<JSAny?>).toDart
        : result;
    // Only an explicit false means nothing was applied.
    return !(settled.isA<JSBoolean>() && !(settled! as JSBoolean).toDart);
  }
}
