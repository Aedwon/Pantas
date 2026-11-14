export 'update_bridge_stub.dart'
    if (dart.library.js_interop) 'update_bridge_web.dart'
    show createUpdateBridge;

/// Browser shell operations, injectable without a browser in tests.
abstract interface class UpdateBridge {
  Future<UpdateStatus> check();
  Future<void> apply();
}

class UpdateStatus {
  const UpdateStatus({required this.available, required this.version});
  final bool available;
  final String? version;
}
