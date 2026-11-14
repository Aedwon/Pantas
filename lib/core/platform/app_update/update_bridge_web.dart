import 'dart:js_interop';

import 'package:pantas/core/platform/app_update/update_bridge.dart';

extension type _PantasUpdate(JSObject _) implements JSObject {
  external JSPromise<_Status> check();
  external void apply();
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
    _update?.apply();
  }
}
