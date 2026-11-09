import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/web/web_hover.dart';

/// A tap area on custom content, in place of an ink well: the label color at
/// `opacity-hover` washes the shape on hover, a press scales it, and keyboard
/// focus draws the system ring. A screen reader reads it as one button. A
/// null [onTap] is the disabled state.
class QuizTapArea extends StatelessWidget {
  const QuizTapArea({
    required this.onTap,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.wash = true,
    this.focusRing = true,
    super.key,
  });

  final VoidCallback? onTap;
  final Widget child;

  /// The shape of the hover wash and the focus ring.
  final BorderRadius borderRadius;

  /// False for content that draws its own hover.
  final bool wash;

  /// False when a parent draws the ring (a row inside a clipped card).
  final bool focusRing;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final washColor = context.colors.textPrimary.withValues(
      alpha: PantasOpacity.hover,
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        onTap: onTap,
        child: _Ring(
          on: focusRing,
          borderRadius: borderRadius,
          child: PressScale(
            enabled: enabled,
            child: FocusableActionDetector(
              enabled: enabled,
              mouseCursor:
                  enabled ? SystemMouseCursors.click : MouseCursor.defer,
              shortcuts: const {
                SingleActivator(
                  LogicalKeyboardKey.enter,
                  includeRepeats: false,
                ): ActivateIntent(),
                SingleActivator(
                  LogicalKeyboardKey.space,
                  includeRepeats: false,
                ): ActivateIntent(),
              },
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    onTap?.call();
                    return null;
                  },
                ),
              },
              child: WebHover(
                builder: (context, hovered) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  onTap: onTap,
                  child: DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      color: wash && enabled && hovered
                          ? washColor
                          : Colors.transparent,
                      borderRadius: borderRadius,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.on,
    required this.borderRadius,
    required this.child,
  });

  final bool on;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      on ? OffsetFocusRing(borderRadius: borderRadius, child: child) : child;
}
