import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/web/web_hover.dart';

/// A tap area on custom content: the system's hover well (`surface-hover`),
/// the 0.97 press, the offset focus ring and a pointer cursor. A rounded
/// rectangle, never a pill. Enter and Space press it when it has focus.
///
/// Use it where a row or a block of mixed content is the control, so no Button
/// or ListRow fits. A null [onTap] makes it inert.
class ReaderTap extends StatelessWidget {
  const ReaderTap({
    required this.onTap,
    required this.child,
    this.radius = PantasRadius.md,
    this.selectedFill,
    this.hoverFill,
    this.washOnTop = false,
    this.semanticLabel,
    super.key,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double radius;

  /// A fill that replaces the hover well while set (a selected row).
  final Color? selectedFill;

  /// The hover well when it is not `surface-hover` (the toast's action).
  final Color? hoverFill;

  /// Draws the hover as a teal wash over the content, for a child that is an
  /// opaque card and would hide a well drawn behind it.
  final bool washOnTop;

  /// Replaces the name read from the content.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final border = BorderRadius.circular(radius);
    final still = MediaQuery.disableAnimationsOf(context);
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: semanticLabel != null,
      child: PressScale(
        scale: pantasPressScale,
        enabled: enabled,
        child: OffsetFocusRing(
          borderRadius: border,
          child: WebHover(
            builder: (context, hovered) => FocusableActionDetector(
              enabled: enabled,
              mouseCursor:
                  enabled ? SystemMouseCursors.click : MouseCursor.defer,
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    onTap?.call();
                    return null;
                  },
                ),
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTap: onTap,
                child: AnimatedContainer(
                  duration: still ? Duration.zero : PantasDurations.short2,
                  foregroundDecoration: washOnTop
                      ? BoxDecoration(
                          color: hovered && enabled
                              ? colors.accent
                                  .withValues(alpha: PantasOpacity.hover)
                              : Colors.transparent,
                          borderRadius: border,
                        )
                      : null,
                  decoration: BoxDecoration(
                    color: selectedFill ??
                        (hovered && enabled && !washOnTop
                            ? (hoverFill ?? colors.surfaceHover)
                            : Colors.transparent),
                    borderRadius: border,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
