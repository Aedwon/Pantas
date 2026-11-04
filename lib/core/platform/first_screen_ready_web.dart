import 'dart:js_interop';

extension type _Splash(JSObject _) implements JSObject {
  external void ready();
  external void started();
  external bool isShown();
}

@JS('pantasSplash')
external _Splash? get _splash;

void sendFirstScreenReady() {
  _splash?.ready();
}

void sendAppStarted() {
  _splash?.started();
}

bool pageBeganFromSplash() {
  try {
    return _splash?.isShown() ?? false;
  } on Object {
    return false;
  }
}
