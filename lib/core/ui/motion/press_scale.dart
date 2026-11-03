import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';

/// Shrinks its child while a finger or the mouse is down on it, then lets it
/// spring back (item 17, demos 5 and 8): 120 ms down, 180 ms up, shared ease.
///
/// Scale is the only thing that changes: no shadow grows and nothing lifts.
/// The press is read from raw pointer events, so it answers at once, even to a
/// tap too short for the button's own pressed state. It never joins the tap
/// competition, so the child keeps its own tap, and a pointer that drags away
/// (a scroll) lets the child go.
///
/// Only this widget rebuilds while it moves. With reduced motion the child
/// does not shrink at all.
class PressScale extends StatefulWidget {
  const PressScale({
    required this.child,
    this.scale = .98,
    this.enabled = true,
    super.key,
  });

  final Widget child;

  /// How small the child gets while it is held down, as a fraction of its size.
  final double scale;

  /// False when the child cannot be pressed (a disabled button).
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;
  int? _pointer;
  Offset? _start;

  void _press(PointerDownEvent event) {
    if (!widget.enabled || _pointer != null) return;
    _pointer = event.pointer;
    _start = event.position;
    setState(() => _down = true);
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    final start = _start;
    // A drag is a scroll or a swipe, not a press.
    if (start != null && (event.position - start).distance > kTouchSlop) {
      _let(event.pointer);
    }
  }

  void _let(int pointer) {
    if (pointer != _pointer) return;
    _pointer = null;
    _start = null;
    if (mounted) setState(() => _down = false);
  }

  @override
  void didUpdateWidget(PressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _down) {
      _pointer = null;
      _start = null;
      _down = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return Listener(
      onPointerDown: _press,
      onPointerMove: _move,
      onPointerUp: (e) => _let(e.pointer),
      onPointerCancel: (e) => _let(e.pointer),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _down ? widget.scale : 1),
        duration: _down ? PantasDurations.tap : PantasDurations.release,
        curve: PantasCurves.shared,
        child: widget.child,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
      ),
    );
  }
}
