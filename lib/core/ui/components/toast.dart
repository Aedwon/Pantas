import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

// QV_Flag's toast uses the same inverted pair in both themes.

class Toast extends StatelessWidget {
  const Toast({
    required this.message,
    this.onUndo,
    this.visible = true,
    super.key,
  });
  final String message;
  final VoidCallback? onUndo;
  final bool visible;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(
          begin:
              MediaQuery.disableAnimationsOf(context) ? (visible ? 1 : 0) : 0,
          end: visible ? 1 : 0,
        ),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : Duration(milliseconds: visible ? 250 : 300),
        curve: PantasCurves.houseOut,
        builder: (context, value, child) => ExcludeFocus(
          excluding: !visible,
          child: IgnorePointer(
            ignoring: !visible,
            child: ExcludeSemantics(
              excluding: !visible,
              child: Opacity(
                opacity: value,
                child: Transform.translate(
                  key: const ValueKey('toast-rise'),
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              ),
            ),
          ),
        ),
        child: Semantics(
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: context.colors.toastBackground,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: .18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: context.type.subhead.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colors.onToast,
                    ),
                  ),
                ),
                if (onUndo != null)
                  TextButton(
                    onPressed: onUndo,
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.toastAction,
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(
                      'Undo',
                      style: context.type.subheadStrong
                          .copyWith(color: context.colors.toastAction),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
