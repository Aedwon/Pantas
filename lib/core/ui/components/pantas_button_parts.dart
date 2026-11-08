import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The Spinner of design system 4.0.
///
/// A ring with a quarter arc that turns once every 900 ms, linear, forever
/// (`dur-long-3`, `motion-linear`). Under reduced motion the arc stops; the
/// host keeps a verb beside it so the state reads without motion.
///
/// [PantasSpinner.inline] is the 18 px busy spinner of a Button: the arc and
/// the track take the label color, the track at `opacity-spinner-track`. The
/// default is the 20 px page spinner: a `fill` track and an `accent` arc.
class PantasSpinner extends StatefulWidget {
  const PantasSpinner({super.key})
      : inlineColor = null,
        inline = false;

  /// The busy spinner inside a Button, in the label color [color].
  const PantasSpinner.inline({required Color color, super.key})
      : inlineColor = color,
        inline = true;

  final Color? inlineColor;
  final bool inline;

  @override
  State<PantasSpinner> createState() => _PantasSpinnerState();
}

class _PantasSpinnerState extends State<PantasSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: PantasDurations.long3,
  );
  late final Animation<double> _linear =
      CurvedAnimation(parent: _turn, curve: PantasCurves.linear);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      _turn.stop();
    } else if (!_turn.isAnimating) {
      _turn.repeat();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark
        ? PantasColors.dark
        : PantasColors.light;
    final inline = widget.inline;
    final arc = inline ? widget.inlineColor! : c.accent;
    final track =
        inline ? arc.withValues(alpha: PantasOpacity.spinnerTrack) : c.fill;
    // Inline is 18 px with a 2 px stroke; the page spinner is `size-icon`
    // with the 2.5 px `border-ring-current` stroke.
    final dimension = inline ? PantasSpace.s18 : PantasSize.icon;
    final stroke =
        inline ? PantasBorder.ringSelected : PantasBorder.ringCurrent;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: dimension,
        child: RotationTransition(
          turns: _linear,
          child: CustomPaint(
            painter: _SpinnerPainter(arc: arc, track: track, stroke: stroke),
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({
    required this.arc,
    required this.track,
    required this.stroke,
  });
  final Color arc;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint);
    paint.color = arc;
    // The top quarter, as a CSS border-top-color arc.
    canvas.drawArc(rect, -math.pi * 3 / 4, math.pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.arc != arc || old.track != track || old.stroke != stroke;
}

/// Locks a busy button to the width it had at rest, so it does not jump when
/// the spinner joins the label.
class ButtonWidthLock extends StatefulWidget {
  const ButtonWidthLock({required this.busy, required this.child, super.key});
  final bool busy;
  final Widget child;

  @override
  State<ButtonWidthLock> createState() => _ButtonWidthLockState();
}

class _ButtonWidthLockState extends State<ButtonWidthLock> {
  double _rest = 0;

  void _measure() {
    if (!mounted || widget.busy) return;
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize) _rest = box.size.width;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.busy) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _measure());
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: widget.busy ? _rest : 0),
      child: widget.child,
    );
  }
}

/// A 44 px touch target around a control that draws smaller (design system
/// 4.0, "touch targets are 44px or more"): the control keeps its drawn size
/// and the layout box grows to 44 on a layout that is touched. On a wide
/// screen, where a pointer drives, it adds nothing.
class TouchTarget extends StatelessWidget {
  const TouchTarget({
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.square = false,
    super.key,
  });
  final Widget child;
  final AlignmentGeometry alignment;

  /// Reserve 44 wide as well as 44 high (an icon button).
  final bool square;

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) return child;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: square ? PantasSize.targetTouch : 0,
        minHeight: PantasSize.targetTouch,
      ),
      child: Align(
        alignment: alignment,
        widthFactor: square ? null : 1,
        child: child,
      ),
    );
  }
}
