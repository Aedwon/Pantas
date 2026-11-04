import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// True while [states] hold focus that the keyboard put there. A mouse click
/// also focuses a control, but the page then drives focus by pointer, and a
/// browser shows no focus ring for it (`:focus-visible`). This is the one rule
/// every wide web control uses for its ring.
///
/// Flutter's own highlight mode is not enough: a mouse never switches it away
/// from the traditional mode a desktop starts in, so it stays on after a
/// click. The mode is still required, and the last input must also be a key.
bool webKeyboardFocus(Set<WidgetState> states) {
  // Listens from the first control built, so the Tab that moves focus onto a
  // control is already seen when its ring is decided.
  _LastInput.watch();
  if (!states.contains(WidgetState.focused)) return false;
  return _LastInput.key &&
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
}

/// Whether the last input to the page was a key press (true) or a pointer
/// press (false). A page nobody has touched yet counts as pointer, so focus
/// the app sets itself shows no ring.
class _LastInput {
  static final ValueNotifier<bool> input = ValueNotifier<bool>(false);
  static bool get key => input.value;
  static bool _watching = false;
  static PointerRouter? _router;

  static void watch() {
    if (_watching) return;
    _watching = true;
    final router = GestureBinding.instance.pointerRouter;
    if (!identical(router, _router)) {
      _router = router..addGlobalRoute(_pointer);
    }
    HardwareKeyboard.instance
      ..removeHandler(_key)
      ..addHandler(_key);
  }

  static void reset() {
    input.value = false;
    _watching = false;
  }

  static void _pointer(PointerEvent event) {
    if (event is PointerDownEvent) input.value = false;
  }

  static bool _key(KeyEvent event) {
    if (event is KeyDownEvent) input.value = true;
    return false;
  }
}

/// Changes when the last input to the page switches between a key and a
/// pointer. A ring that is drawn apart from its control listens to it, since
/// a press elsewhere takes the ring away without moving focus.
ValueListenable<bool> get webKeyboardInput {
  _LastInput.watch();
  return _LastInput.input;
}

/// A test binding is new for each test, so the listeners start again too.
@visibleForTesting
void resetWebKeyboardFocus() => _LastInput.reset();

/// The 2 px accent ring of a control with keyboard focus, or null.
BorderSide? webFocusRing(Set<WidgetState> states, Color accent) =>
    webKeyboardFocus(states) ? BorderSide(color: accent, width: 2) : null;

/// Draws the keyboard-only focus ring around a control that has no ring of
/// its own: an `InkWell` row, a link, a custom tap target. Buttons get the
/// ring from the theme (`side`); this is the same rule for everything else.
/// The ring follows [borderRadius], sits inside the box, and shows only for
/// focus the keyboard put there.
class WebKeyboardRing extends StatefulWidget {
  const WebKeyboardRing({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });
  final Widget child;
  final BorderRadius borderRadius;
  @override
  State<WebKeyboardRing> createState() => _WebKeyboardRingState();
}

class _WebKeyboardRingState extends State<WebKeyboardRing> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    _LastInput.watch();
    final accent = context.webTokens.colors.accent;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) {
        if (mounted) setState(() => _focused = focused);
      },
      // A press on the page takes the ring away without moving focus, so the
      // last input is listened to as well as focus.
      child: ValueListenableBuilder<bool>(
        valueListenable: _LastInput.input,
        child: widget.child,
        builder: (context, _, child) {
          final ring =
              webFocusRing({if (_focused) WidgetState.focused}, accent);
          return DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              border: ring == null ? null : Border.fromBorderSide(ring),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
