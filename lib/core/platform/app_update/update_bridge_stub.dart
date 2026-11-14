import 'package:pantas/core/platform/app_update/update_bridge.dart';

UpdateBridge createUpdateBridge() => const _NativeUpdateBridge();

class _NativeUpdateBridge implements UpdateBridge {
  const _NativeUpdateBridge();
  @override
  Future<UpdateStatus> check() async =>
      const UpdateStatus(available: false, version: null);
  @override
  Future<void> apply() async {}
}
