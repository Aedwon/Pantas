import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

// QV_Flag's toast uses the same inverted pair in both themes.

class Toast extends StatelessWidget {
  const Toast({
    required this.message,
    this.onUndo,
    this.keyHint,
    this.visible = true,
    this.web = false,
    super.key,
  });

  /// Wide web layout (board `.toast`): intrinsic width, 15 px text and a
  /// 57x31 Undo button.
  final bool web;
  final String message;
  final String? keyHint;
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
            padding: web
                ? const EdgeInsets.fromLTRB(18, 12, 10, 12)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
              mainAxisSize: web ? MainAxisSize.min : MainAxisSize.max,
              children: [
                Flexible(
                  child: Text(
                    message,
                    style: web
                        ? context.type.subhead.copyWith(
                            fontSize: 15,
                            color: context.colors.onToast,
                          )
                        : context.type.subhead.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.colors.onToast,
                          ),
                  ),
                ),
                if (web && onUndo != null) const SizedBox(width: 12),
                if (keyHint != null) ...[
                  const SizedBox(width: 14),
                  WebKeyHint(keyHint!, onButton: true),
                ],
                if (onUndo != null)
                  TextButton(
                    onPressed: onUndo,
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.toastAction,
                      minimumSize: web ? const Size(0, 31) : const Size(44, 44),
                      padding: web
                          ? const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            )
                          : null,
                      tapTargetSize:
                          web ? MaterialTapTargetSize.shrinkWrap : null,
                      visualDensity: web ? VisualDensity.standard : null,
                      shape: web
                          ? RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )
                          : null,
                    ),
                    child: Text(
                      'Undo',
                      style: context.type.subheadStrong.copyWith(
                        fontSize: web ? 15 : null,
                        color: context.colors.toastAction,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
