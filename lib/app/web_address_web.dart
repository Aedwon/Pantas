import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('history')
external _BrowserHistory get _history;

extension type _BrowserHistory(JSObject _) implements JSObject {
  external JSAny? get state;
  external void go(int delta);
}

/// The engine numbers each history entry it makes, in `history.state`.
int? browserHistorySerial() {
  final state = _history.state;
  if (state == null || !state.isA<JSObject>()) return null;
  final serial = (state as JSObject).getProperty<JSAny?>('serialCount'.toJS);
  return serial.isA<JSNumber>() ? (serial as JSNumber?)?.toDartInt : null;
}

void browserHistoryGo(int delta) => _history.go(delta);
