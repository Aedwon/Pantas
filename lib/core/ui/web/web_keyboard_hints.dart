import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/web/web_pointer_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/ui/web/web_pointer_web.dart';

/// Lives above the router so a hardware key reveals hints for the whole visit.
class WebKeyboardHints extends StatefulWidget {
  const WebKeyboardHints({
    required this.child,
    this.finePointer,
    super.key,
  });
  final Widget child;
  final bool? finePointer;

  static bool visibleOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HintVisibility>()?.visible ??
      true;

  @override
  State<WebKeyboardHints> createState() => _WebKeyboardHintsState();
}

class _WebKeyboardHintsState extends State<WebKeyboardHints> {
  bool _hardwareKeyUsed = false;
  late final bool _finePointer = widget.finePointer ?? primaryPointerIsFine;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  bool _onKey(KeyEvent event) {
    if (!_hardwareKeyUsed && event is KeyDownEvent && !event.synthesized) {
      setState(() => _hardwareKeyUsed = true);
    }
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _HintVisibility(
        visible: _finePointer || _hardwareKeyUsed,
        child: widget.child,
      );
}

class _HintVisibility extends InheritedWidget {
  const _HintVisibility({required this.visible, required super.child});
  final bool visible;

  @override
  bool updateShouldNotify(_HintVisibility oldWidget) =>
      visible != oldWidget.visible;
}
