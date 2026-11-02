import 'package:flutter/material.dart';

/// Chrome motion helpers. Every duration collapses to zero when the system
/// asks for reduced motion.
Duration chromeDuration(BuildContext context, int milliseconds) =>
    MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Duration(milliseconds: milliseconds);

/// Soft fill under the pointer, with a pointer cursor.
class HoverFill extends StatefulWidget {
  const HoverFill({
    required this.builder,
    required this.hover,
    this.radius = 7,
    this.enabled = true,
    super.key,
  });

  /// Builds the content. The fill is drawn behind it.
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(BuildContext context, bool hovered) builder;
  final Color hover;
  final double radius;
  final bool enabled;

  @override
  State<HoverFill> createState() => _HoverFillState();
}

class _HoverFillState extends State<HoverFill> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: chromeDuration(context, 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered && widget.enabled ? widget.hover : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: widget.builder(context, _hovered),
      ),
    );
  }
}

/// Shrinks to 0.97 while pressed and springs back.
class PressScale extends StatefulWidget {
  const PressScale({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  var _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: chromeDuration(context, 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
