import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// The design system's keyboard focus ring: `border-focus` (2) in `accent`,
/// drawn [PantasSpace.s2] outside the control (offset 2), only for focus the
/// keyboard put there. It takes no layout room: the ring paints outside the
/// child's box, so a parent that clips would hide it.
class OffsetFocusRing extends StatefulWidget {
  const OffsetFocusRing({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.color,
    this.inset = false,
    super.key,
  });

  final Widget child;

  /// The radius of the control; the ring adds its offset and width to it.
  final BorderRadius borderRadius;

  /// Overrides `accent` (a selected day takes a `text-primary` ring).
  final Color? color;

  /// Draws the ring inside the control (offset -2), for controls that touch
  /// their neighbors (the five-day phone week strip, D196).
  final bool inset;

  @override
  State<OffsetFocusRing> createState() => _OffsetFocusRingState();
}

class _OffsetFocusRingState extends State<OffsetFocusRing> {
  bool _focused = false;

  static const double _reach = PantasBorder.focus + PantasSpace.s2;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.colors.accent;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) {
        if (mounted) setState(() => _focused = focused);
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: webKeyboardInput,
        child: widget.child,
        builder: (context, _, child) {
          final ring = webFocusRing(
            {if (_focused) WidgetState.focused},
            color,
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              child!,
              if (ring != null)
                Positioned(
                  left: widget.inset ? 0 : -_reach,
                  top: widget.inset ? 0 : -_reach,
                  right: widget.inset ? 0 : -_reach,
                  bottom: widget.inset ? 0 : -_reach,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      key: const ValueKey('focus-ring'),
                      decoration: BoxDecoration(
                        borderRadius: widget.inset
                            ? widget.borderRadius
                            : widget.borderRadius.add(
                                const BorderRadius.all(Radius.circular(_reach)),
                              ),
                        border: Border.fromBorderSide(ring),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
