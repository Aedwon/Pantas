import 'dart:js_interop';

import 'package:pantas/core/platform/welcome/welcome_handover.dart';

/// The small script in `web/pantas_welcome.js`. It starts before Flutter and
/// owns the HTML screen.
extension type _PantasWelcome(JSObject _) implements JSObject {
  external bool isShown();
  // ignore: avoid_positional_boolean_parameters
  external void ready(bool holdForTap);
}

@JS('pantasWelcome')
external _PantasWelcome? get _welcome;

WelcomeHandover createWelcomeHandover() => WebWelcomeHandover();

class WebWelcomeHandover implements WelcomeHandover {
  @override
  bool get shownThisVisit {
    try {
      return _welcome?.isShown() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  void appReady({required bool holdForTap}) {
    try {
      _welcome?.ready(holdForTap);
    } on Object {
      // Without the script there is no HTML screen to remove.
    }
  }
}
