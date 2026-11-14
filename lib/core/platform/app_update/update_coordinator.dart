import 'package:pantas/core/platform/app_update/update_bridge.dart';
import 'package:pantas/core/platform/app_update/update_overlay_registry.dart';

/// Applies a browser update only at an explicitly safe point.
class UpdateCoordinator {
  UpdateCoordinator({
    required UpdateBridge bridge,
    required Future<void> Function() waitForWrites,
    required void Function(Object, StackTrace) onFailure,
  })  : _bridge = bridge,
        _waitForWrites = waitForWrites,
        _onFailure = onFailure;

  final UpdateBridge _bridge;
  final Future<void> Function() _waitForWrites;
  final void Function(Object, StackTrace) _onFailure;
  final Set<String> _attempted = {};
  final Set<Object> _overlays = {};
  String _path = '';
  bool _lessonEnded = false;
  bool _disposed = false;
  bool _applying = false;

  bool get isApplying => _applying;
  String get currentPath => _path;
  int _epoch = 0;
  Future<void>? _checking;

  void routeChanged(String path) {
    if (path == _path) return;
    _path = path;
    lessonStarted();
  }

  void setOverlay(Object owner, {required bool visible}) {
    if (visible) {
      _overlays.add(owner);
    } else {
      _overlays.remove(owner);
    }
    _epoch++;
  }

  void lessonStarted() {
    _lessonEnded = false;
    _epoch++;
  }

  void lessonEnded() {
    if (_path.startsWith('/lesson/') || _path.startsWith('/study/ending/')) {
      _lessonEnded = true;
      _epoch++;
    }
  }

  bool get _safe =>
      !_disposed &&
      _overlays.isEmpty &&
      !updateOverlayRegistry.hasOpenOverlays &&
      (_path == '/home' ||
          RegExp(r'^/(quiz/(debrief|all)|mock/results)/[^/]+$')
              .hasMatch(_path) ||
          _lessonEnded);

  Future<void> check() => _checking ??= _check().whenComplete(() {
        _checking = null;
      });

  Future<void> _check() async {
    try {
      final status = await _bridge.check();
      final version = status.version;
      if (!status.available || version == null || !_safe) return;
      if (_attempted.contains(version)) return;
      final epoch = _epoch;
      await _waitForWrites();
      if (!_safe || _epoch != epoch) return;
      // Reserve before calling JS, including failures and concurrent checks.
      _attempted.add(version);
      _applying = true;
      try {
        await _bridge.apply();
      } finally {
        _applying = false;
      }
    } on Object catch (error, stack) {
      _onFailure(error, stack);
    }
  }

  void dispose() {
    _disposed = true;
    _epoch++;
  }
}
