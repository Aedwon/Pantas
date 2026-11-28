import 'dart:async';

import 'package:pantas/core/platform/app_update/update_overlay_registry.dart';

/// Finds the safe points of a session (Home, the end of a lesson or a quiz,
/// with no overlay open) and runs the content-version check at each one.
/// It no longer applies a browser update: a new build reaches a student only
/// when every Pantas tab is closed, or through the Update Required screen.
class UpdateCoordinator {
  UpdateCoordinator({
    required void Function(Object, StackTrace) onFailure,
    Future<void> Function()? onSafePoint,
  })  : _onFailure = onFailure,
        _onSafePoint = onSafePoint;

  final void Function(Object, StackTrace) _onFailure;

  /// Runs, without being waited for, each time a check finds a safe point.
  /// Its own failures are reported.
  final Future<void> Function()? _onSafePoint;
  final Set<Object> _overlays = {};
  String _path = '';
  int _quizRevision = 0;
  bool _lessonEnded = false;
  bool _quizEnded = false;
  bool _disposed = false;

  /// Invalidates completion work after navigation or a session start.
  int get quizRevision => _quizRevision;
  Future<void>? _checking;

  void routeChanged(String path) {
    if (path == _path) return;
    _path = path;
    lessonStarted();
    quizStarted();
  }

  void setOverlay(Object owner, {required bool visible}) {
    if (visible) {
      _overlays.add(owner);
    } else {
      _overlays.remove(owner);
    }
  }

  void lessonStarted() {
    _lessonEnded = false;
  }

  void lessonEnded() {
    if (_path.startsWith('/lesson/') || _path.startsWith('/study/ending/')) {
      _lessonEnded = true;
    }
  }

  void quizStarted() {
    _quizRevision++;
    _quizEnded = false;
  }

  void quizEnded() {
    _quizEnded = true;
    unawaited(check());
  }

  bool get _safe =>
      !_disposed &&
      _overlays.isEmpty &&
      !updateOverlayRegistry.hasOpenOverlays &&
      (_path == '/home' ||
          RegExp(r'^/(quiz/(debrief|all)|mock/results)/[^/]+$')
              .hasMatch(_path) ||
          _lessonEnded ||
          _quizEnded);

  Future<void> check() => _checking ??= _check().whenComplete(() {
        _checking = null;
      });

  Future<void> _check() async {
    try {
      final onSafePoint = _onSafePoint;
      if (onSafePoint != null && _safe) {
        unawaited(onSafePoint().catchError(_onFailure));
      }
    } on Object catch (error, stack) {
      _onFailure(error, stack);
    }
  }

  void dispose() {
    _disposed = true;
  }
}
