import 'dart:js_interop';

@JS('window.matchMedia')
external _PointerQuery _matchMedia(String query);

extension type _PointerQuery(JSObject _) implements JSObject {
  external bool get matches;
}

bool get primaryPointerIsFine => _matchMedia('(pointer: fine)').matches;
