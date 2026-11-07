import 'dart:js_interop';

/// The small script in `web/pantas_pwa.js`.
extension type _PantasPwa(JSObject _) implements JSObject {
  external String? buildVersion();
  external String visitKind();
}

extension type _Navigator(JSObject _) implements JSObject {
  external String get userAgent;
}

extension type _Window(JSObject _) implements JSObject {
  external num get innerWidth;
}

extension type _Document(JSObject _) implements JSObject {
  external String get visibilityState;
  external void addEventListener(String type, JSFunction listener);
}

@JS('pantasPwa')
external _PantasPwa? get _pwa;

@JS('navigator')
external _Navigator get _navigator;

@JS('window')
external _Window get _window;

@JS('document')
external _Document get _document;

const supported = true;

String buildVersion() {
  try {
    return _pwa?.buildVersion() ?? 'unknown';
  } on Object {
    return 'unknown';
  }
}

String visitKind() {
  try {
    return _pwa?.visitKind() ?? 'first';
  } on Object {
    return 'first';
  }
}

String userAgent() {
  try {
    return _navigator.userAgent;
  } on Object {
    return '';
  }
}

int viewportWidth() {
  try {
    return _window.innerWidth.toInt();
  } on Object {
    return 0;
  }
}

void onPageHidden(void Function() action) {
  try {
    _document.addEventListener(
      'visibilitychange',
      () {
        if (_document.visibilityState == 'hidden') action();
      }.toJS,
    );
  } on Object {
    // Without the event the one-a-minute report still goes.
  }
}
