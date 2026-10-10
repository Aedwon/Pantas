import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum FloatingBarState { neutral, right, wrong }

// QV_Answer's status surface is quieter than a selected-choice tint.
const floatingBarRightSurface = Color(0xFFEFF7F5);
const floatingBarWrongSurface = Color(0xFFFFF3F4);

class FloatingBar extends StatelessWidget {
  const FloatingBar({
    required this.left,
    required this.counter,
    required this.right,
    this.state = FloatingBarState.neutral,
    super.key,
  });
  final Widget left;
  final String counter;
  final Widget right;
  final FloatingBarState state;
  static const contentBottomInset = 102.0;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (state) {
      FloatingBarState.neutral => c.surface,
      FloatingBarState.right => Theme.of(context).brightness == Brightness.light
          ? floatingBarRightSurface
          : c.accentTint,
      FloatingBarState.wrong => Theme.of(context).brightness == Brightness.light
          ? floatingBarWrongSurface
          : c.wrongTint
    };
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: PantasCurves.houseOut,
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: state == FloatingBarState.neutral
              ? Colors.black.withValues(alpha: .06)
              : state == FloatingBarState.right
                  ? c.accent.withValues(alpha: .28)
                  : c.destructive.withValues(alpha: .26),
        ),
      ),
      child: TextButtonTheme(
        data: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                heightFactor: 1,
                child: left,
              ),
            ),
            Text(counter, style: context.type.subheadStrong),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                heightFactor: 1,
                child: right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
