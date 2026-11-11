import 'dart:async';

import 'package:flutter/widgets.dart';

// ds-board: Aedwon Idea 3 note, Nov 10. First repeat after 400 ms.
const Duration holdRepeatFirst = Duration(milliseconds: 400);

// ds-board: Aedwon Idea 3 note, Nov 10. Then one repeat every 140 ms.
const Duration holdRepeatSlow = Duration(milliseconds: 140);

// ds-board: Aedwon Idea 3 note, Nov 10. Once held 1.2 s, one repeat every
// 70 ms.
const Duration holdRepeatFast = Duration(milliseconds: 70);

// ds-board: Aedwon Idea 3 note, Nov 10. Once held 2.4 s, one repeat every
// 35 ms.
const Duration holdRepeatFastest = Duration(milliseconds: 35);

// ds-board: Aedwon Idea 3 note, Nov 10. The hold time at which the repeat
// speeds up to 70 ms.
const Duration holdRepeatAccelerateAt = Duration(milliseconds: 1200);

// ds-board: Aedwon Idea 3 note, Nov 10. The hold time at which the repeat
// speeds up to 35 ms.
const Duration holdRepeatAccelerateMoreAt = Duration(milliseconds: 2400);

/// Wraps a step button so that a press moves one step at once and a hold keeps
/// stepping, faster the longer it is held.
///
/// The step happens on pointer down, over the whole area of [builder]'s
/// result. Pass the `onPressed` the builder receives to the button: it fires
/// for keyboard and screen-reader activation, and is ignored for a pointer
/// press that this widget already handled.
///
/// [onStep] moves one step and returns whether it moved. The hold stops when
/// it returns false (the end of the range), and on release or cancel. The
/// repeat is an interaction timing, not an animation, so reduced motion does
/// not change it.
///
/// [onReleased] fires on release or cancel. `wasHold` is true when the press
/// lasted long enough to repeat, and false for a tap.
class HoldToRepeat extends StatefulWidget {
  const HoldToRepeat({
    required this.onStep,
    required this.builder,
    this.onReleased,
    super.key,
  });

  final bool Function() onStep;
  final void Function({required bool wasHold})? onReleased;
  final Widget Function(BuildContext context, VoidCallback onPressed) builder;

  @override
  State<HoldToRepeat> createState() => _HoldToRepeatState();
}

class _HoldToRepeatState extends State<HoldToRepeat> {
  Timer? _timer;
  Duration _held = Duration.zero;
  bool _pointerHandled = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _down(PointerDownEvent event) {
    _pointerHandled = true;
    _timer?.cancel();
    _held = Duration.zero;
    if (!widget.onStep()) return;
    _schedule(holdRepeatFirst);
  }

  void _schedule(Duration delay) {
    _timer = Timer(delay, () {
      _held += delay;
      if (!widget.onStep()) return;
      _schedule(
        _held >= holdRepeatAccelerateMoreAt
            ? holdRepeatFastest
            : _held >= holdRepeatAccelerateAt
                ? holdRepeatFast
                : holdRepeatSlow,
      );
    });
  }

  void _end(PointerEvent event) {
    _timer?.cancel();
    _timer = null;
    if (_pointerHandled) {
      widget.onReleased?.call(wasHold: _held >= holdRepeatFirst);
    }
    // The button's own tap arrives during this same event; forget the pointer
    // press once it has passed, so a key press afterwards still works.
    scheduleMicrotask(() => _pointerHandled = false);
  }

  void _pressed() {
    if (_pointerHandled) return;
    widget.onStep();
  }

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerUp: _end,
        onPointerCancel: _end,
        child: widget.builder(context, _pressed),
      );
}
