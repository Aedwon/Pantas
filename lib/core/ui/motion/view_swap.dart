import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

/// Swaps one block for another when a switch picks a different view (item 17,
/// demo 9): Day and Week, the practice modes, a list level.
///
/// Fade and slide, 240 ms (`base`). The old block fades out over 0 to 100 ms
/// on the ease while drifting 12 px away from the new view; the new block
/// fades in over 60 to 240 ms on the shared ease while drifting 12 px in from
/// it. The side it comes from follows the order of [index]: a higher index
/// comes in from the right.
///
/// With [fade] false there is no fade: the old block leaves at once and the
/// new one slides in 24 px. That is the preview's choice for a block that is
/// nearly a whole phone screen, where a fade would cost frames.
///
/// Only the changing block moves, and each block is a repaint boundary that is
/// built once, so a frame only moves and fades finished layers. With reduced
/// motion the new block is simply there.
class ViewSwap extends StatefulWidget {
  const ViewSwap({
    required this.index,
    required this.child,
    this.fade = true,
    super.key,
  });

  /// Which view [child] is. A different value starts the swap.
  final int index;
  final Widget child;
  final bool fade;

  @override
  State<ViewSwap> createState() => _ViewSwapState();
}

class _ViewSwapState extends State<ViewSwap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PantasDurations.medium1,
    value: 1,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _outgoing = null);
      }
    });

  Widget? _outgoing;
  int _outgoingIndex = 0;
  double _direction = 1;

  @override
  void didUpdateWidget(ViewSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _outgoing = null;
      _controller.value = 1;
      return;
    }
    // A swap in the middle of another one drops the older block at once.
    _outgoing = oldWidget.child;
    _outgoingIndex = oldWidget.index;
    _direction = widget.index > oldWidget.index ? 1 : -1;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The preview's phases, in ms of the 240 ms (`base`) clock.
  static final double _totalMs =
      PantasDurations.medium1.inMilliseconds.toDouble();
  static const double _outEndMs = 100;
  static const double _inStartMs = 60;

  static double _phase(double ms, double from, double to) =>
      ((ms - from) / (to - from)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final outgoing = _outgoing;
    final fade = widget.fade;
    final travel = fade ? 12.0 : 24.0;
    return Stack(
      children: [
        if (outgoing != null)
          AnimatedBuilder(
            key: ValueKey<String>('out-$_outgoingIndex'),
            animation: _controller,
            child: RepaintBoundary(child: outgoing),
            builder: (context, child) {
              final out = fade
                  ? PantasCurves.fade.transform(
                      _phase(_controller.value * _totalMs, 0, _outEndMs),
                    )
                  : 1.0;
              // Gone: it has faded out, or it left at once.
              if (out >= 1) return const SizedBox.shrink();
              return Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: Opacity(
                      opacity: 1 - out,
                      child: Transform.translate(
                        offset: Offset(-12 * _direction * out, 0),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        KeyedSubtree(
          key: ValueKey<int>(widget.index),
          child: AnimatedBuilder(
            animation: _controller,
            child: RepaintBoundary(child: widget.child),
            builder: (context, child) {
              final entered = PantasCurves.move.transform(
                _phase(
                  _controller.value * _totalMs,
                  fade ? _inStartMs : 0,
                  _totalMs,
                ),
              );
              return Opacity(
                opacity: fade ? entered : 1,
                child: Transform.translate(
                  offset: Offset(travel * _direction * (1 - entered), 0),
                  child: child,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
