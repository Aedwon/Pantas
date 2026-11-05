import 'dart:js_interop';

extension type _Splash(JSObject _) implements JSObject {
  external void ready();
  external void started();
  external bool isShown();
  external void afterGone(JSFunction action);
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

void afterSplashGone(void Function() action) {
  try {
    final splash = _splash;
    if (splash != null) {
      splash.afterGone(action.toJS);
      return;
    }
  } on Object {
    // No usable splash: nothing covers the page.
  }
  action();
}
