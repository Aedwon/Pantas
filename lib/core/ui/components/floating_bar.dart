import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum FloatingBarState { neutral, right, wrong }

// QV_Answer's status surface is quieter than a selected-choice tint.

class FloatingBar extends StatelessWidget {
  const FloatingBar({
    required this.left,
    required this.counter,
    required this.right,
    this.state = FloatingBarState.neutral,
    super.key,
  })  : content = null,
        radius = 30,
        inset = 8;

  /// QN_Report and QN_WrongOpen replace the row with a growing form.
  const FloatingBar.content({
    required Widget child,
    this.state = FloatingBarState.neutral,
    this.radius = 30,
    this.inset = 8,
    super.key,
  })  : content = child,
        left = const SizedBox.shrink(),
        counter = '',
        right = const SizedBox.shrink();

  final Widget? content;
  final double radius;
  final double inset;
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
      FloatingBarState.right => c.floatingRight,
      FloatingBarState.wrong => c.floatingWrong
    };
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Duration(
              milliseconds: state == FloatingBarState.neutral ? 250 : 300,
            ),
      constraints: const BoxConstraints(minHeight: 60),
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: .12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: state == FloatingBarState.neutral
              ? context.colors.shadow.withValues(alpha: .06)
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
        child: content ??
            Row(
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
