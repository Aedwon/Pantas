import 'package:flutter/foundation.dart';

/// Inline portals and stacks are modal without creating a Navigator route.
/// Only visibility is registered here. No input or student data is retained.
class UpdateOverlayRegistry extends ChangeNotifier {
  final Set<Object> _open = {};
  bool get hasOpenOverlays => _open.isNotEmpty;

  void setOpen(Object owner, {required bool open}) {
    final changed = open ? _open.add(owner) : _open.remove(owner);
    if (changed) notifyListeners();
  }
}

final updateOverlayRegistry = UpdateOverlayRegistry();
