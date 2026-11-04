import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The focus a page's keyboard shortcuts stand on.
///
/// A page that binds keys with `CallbackShortcuts` only hears them while focus
/// is somewhere inside it. A plain `Focus(autofocus: true)` takes focus once,
/// when the page is built. If focus then falls out of the page, nothing takes
/// it back and every key goes quiet until the student clicks the page. Focus
/// falls out when the control that held it stops being focusable (a button
/// that is busy or disabled, a choice that locks after Check) or when the
/// browser's own focus moves.
///
/// This keeps the page's node focused. When focus lands on a scope instead of
/// a control, which is what "nothing is focused" looks like, it returns to the
/// page. It never takes focus from a control that holds it: a text field, a
/// dialog or another page on top is left alone.
class KeyFocusKeeper extends StatefulWidget {
  const KeyFocusKeeper({
    required this.child,
    this.focusNode,
    this.onKeyEvent,
    super.key,
  });

  /// The page, with its `CallbackShortcuts` above this widget.
  final Widget child;

  /// A node the page also uses itself, to put focus back by hand.
  final FocusNode? focusNode;
  final FocusOnKeyEventCallback? onKeyEvent;

  @override
  State<KeyFocusKeeper> createState() => _KeyFocusKeeperState();
}

class _KeyFocusKeeperState extends State<KeyFocusKeeper> {
  FocusNode? _own;
  bool _queued = false;

  FocusNode get _node => widget.focusNode ?? (_own ??= FocusNode());

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_focusChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_focusChanged);
    _own?.dispose();
    super.dispose();
  }

  void _focusChanged() {
    // Settle after the frame: focus is often mid-change when this is called,
    // and a control that was just rebuilt may be about to take it.
    if (_queued) return;
    _queued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queued = false;
      _reclaim();
    });
  }

  void _reclaim() {
    if (!mounted) return;
    final node = _node;
    if (node.context == null || !node.canRequestFocus) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final manager = FocusManager.instance;
    final primary = manager.primaryFocus;
    final lost = primary == null ||
        primary == manager.rootScope ||
        (primary is FocusScopeNode && node.ancestors.contains(primary));
    if (lost) node.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Focus(
        focusNode: _node,
        autofocus: true,
        onKeyEvent: widget.onKeyEvent,
        child: widget.child,
      );
}

/// Whether the control that holds focus acts on Enter by itself.
///
/// A button, a choice or a link answers Enter with its own press. A page that
/// binds Enter above it must leave that press alone, or the page's action
/// runs instead of the control the student is on.
bool focusedControlTakesEnter({
  bool Function(BuildContext focused)? keepsEnter,
}) {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null || !context.mounted) return false;
  if (keepsEnter != null && keepsEnter(context)) return false;
  final action = Actions.maybeFind<ActivateIntent>(context);
  return action != null && action.isEnabled(const ActivateIntent());
}

/// A page's Enter shortcut that yields to a focused control.
///
/// Pass it as the `onKeyEvent` of the page's [KeyFocusKeeper], where
/// `CallbackShortcuts` would hold Enter. Enter runs [onEnter] only when no
/// focused control takes it: with focus on the page, on a dialog or on
/// nothing. With focus on a button or a choice, Enter goes on to that
/// control. A held key runs [onEnter] once, and Enter with Shift, Ctrl, Alt
/// or Cmd is left alone.
///
/// [keepsEnter] names the controls that hand Enter back to the page even
/// though they could take it: an answer that is already picked, where Enter
/// means "check it" and pressing the answer again would do nothing.
FocusOnKeyEventCallback enterKeyHandler(
  VoidCallback onEnter, {
  bool Function(BuildContext focused)? keepsEnter,
}) =>
    (FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent ||
          event.logicalKey != LogicalKeyboardKey.enter) {
        return KeyEventResult.ignored;
      }
      final keyboard = HardwareKeyboard.instance;
      if (keyboard.isShiftPressed ||
          keyboard.isControlPressed ||
          keyboard.isAltPressed ||
          keyboard.isMetaPressed) {
        return KeyEventResult.ignored;
      }
      if (focusedControlTakesEnter(keepsEnter: keepsEnter)) {
        return KeyEventResult.ignored;
      }
      onEnter();
      return KeyEventResult.handled;
    };

/// [enterKeyHandler] for a page that has no [KeyFocusKeeper]: wrap it round
/// the page.
class EnterShortcut extends StatelessWidget {
  const EnterShortcut({
    required this.onEnter,
    required this.child,
    this.keepsEnter,
    super.key,
  });

  final VoidCallback onEnter;
  final Widget child;
  final bool Function(BuildContext focused)? keepsEnter;

  @override
  Widget build(BuildContext context) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: enterKeyHandler(onEnter, keepsEnter: keepsEnter),
        child: child,
      );
}
