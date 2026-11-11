import 'dart:js_interop';

import 'package:flutter/widgets.dart';
// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

/// Adds one history entry that keeps the current address and state, and calls
/// [onBack] when browser Back removes it. The returned function removes the
/// entry when the viewer closes without Back.
VoidCallback? openViewerHistoryEntry(VoidCallback onBack) {
  final history = web.window.history;
  var open = true;
  late final JSFunction listener;
  void detach() => web.window.removeEventListener('popstate', listener);
  listener = ((web.Event _) {
    if (!open) return;
    open = false;
    detach();
    onBack();
  }).toJS;
  // The engine's own state is kept, so the engine reads this entry as the one
  // it already knows when Back returns to the page.
  history.pushState(history.state, '');
  web.window.addEventListener('popstate', listener);
  return () {
    if (!open) return;
    open = false;
    detach();
    history.back();
  };
}
