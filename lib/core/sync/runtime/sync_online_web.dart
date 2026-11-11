import 'dart:async';
import 'dart:js_interop';

// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

Stream<void> onlineEvents() {
  late final StreamController<void> controller;
  final listener = ((web.Event _) => controller.add(null)).toJS;
  controller = StreamController<void>(
    onListen: () => web.window.addEventListener('online', listener),
    onCancel: () => web.window.removeEventListener('online', listener),
  );
  return controller.stream;
}
