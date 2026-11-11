import 'package:flutter/material.dart';

/// Makes a whole row respond to a tap without adding ink or hover.
///
/// Use it for a row whose control (a switch, for example) is small. The inner
/// control keeps its own handler and wins a tap on itself, so it fires once.
/// Semantics are left to the inner control, so a screen reader does not
/// announce a second control. A null [onTap] makes the row do nothing.
class RowTapTarget extends StatelessWidget {
  const RowTapTarget({required this.onTap, required this.child, super.key});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
