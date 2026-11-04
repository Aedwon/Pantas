import 'dart:js_interop';

extension type _Splash(JSObject _) implements JSObject {
  external void ready();
  external void started();
}

@JS('pantasSplash')
external _Splash? get _splash;

void sendFirstScreenReady() {
  _splash?.ready();
}

void sendAppStarted() {
  _splash?.started();
}
