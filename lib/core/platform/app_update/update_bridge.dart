export 'update_bridge_stub.dart'
    if (dart.library.js_interop) 'update_bridge_web.dart'
    show createUpdateBridge;

/// Browser shell operations, injectable without a browser in tests.
abstract interface class UpdateBridge {
  Future<UpdateStatus> check();

  /// Asks the browser to switch to the waiting build. Completes with true when
  /// the new worker took over (the page reloads), and false when nothing was
  /// applied: nothing waiting, or the worker refused because another window of
  /// the app is open. A false answer is not an attempt: the next safe point
  /// asks again.
  Future<bool> apply();
}

class UpdateStatus {
  const UpdateStatus({required this.available, required this.version});
  final bool available;
  final String? version;
}
