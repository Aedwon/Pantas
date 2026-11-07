import 'dart:js_interop';

extension type _Performance(JSObject _) implements JSObject {
  external double now();
  external void mark(String name);
  external JSArray<_Mark> getEntriesByType(String type);
}

extension type _Mark(JSObject _) implements JSObject {
  external String get name;
  external double get startTime;
}

@JS('performance')
external _Performance? get _performance;

/// Milliseconds since navigation began, from the same clock the page's own
/// scripts use. Falls back to zero if the browser has no timer.
int nowMs() {
  try {
    return _performance?.now().round() ?? 0;
  } on Object {
    return 0;
  }
}

/// Also shows the mark in the browser's performance tools.
void browserMark(String name) {
  try {
    _performance?.mark(name);
  } on Object {
    // A timing mark must never break the app.
  }
}

/// The marks the page's own scripts made before and around the app: `page.*`
/// and `splash.*`.
List<(String, int)> pageMarks() {
  try {
    final marks = _performance?.getEntriesByType('mark').toDart ?? const [];
    return [
      for (final mark in marks)
        if (mark.name.startsWith('page.') || mark.name.startsWith('splash.'))
          (mark.name, mark.startTime.round()),
    ];
  } on Object {
    return const [];
  }
}
