import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

/// [overlayBuilder] lets the mock finale add its two balls to this same arc.
class HalfRingGauge extends StatefulWidget {
  const HalfRingGauge({
    required this.fraction,
    required this.label,
    this.overlayBuilder,
    this.decimalPlaces = 0,
    super.key,
  }) : assert(fraction >= 0 && fraction <= 1,
            'Accuracy must be between zero and one.');
  final int decimalPlaces;
  final double fraction;
  final String label;
  final Widget Function(BuildContext, double)? overlayBuilder;
  @override
  State<HalfRingGauge> createState() => _HalfRingGaugeState();
}

class _HalfRingGaugeState extends State<HalfRingGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late Animation<double> _fill;
  bool? _still;
  _GaugePainter? _painter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still != _still) {
      final begin = _still == null ? 0.0 : _fill.value;
      _still = still;
      animate(begin);
    }
  }

  @override
  void didUpdateWidget(HalfRingGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fraction != widget.fraction) animate(_fill.value);
  }

  void animate(double begin) {
    _fill = _controller.drive(Tween(begin: begin, end: widget.fraction).chain(
      CurveTween(
          curve: const Interval(3 / 14, 1, curve: PantasCurves.houseOut)),
    ));
    if (_still!) {
      _controller
        ..stop()
        ..value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    if (_painter == null ||
        _painter!.fraction != _fill ||
        _painter!.fill != colors.accent ||
        _painter!.track != colors.fill) {
      _painter = _GaugePainter(
          fraction: _fill, fill: colors.accent, track: colors.fill);
    }
    return Semantics(
      label:
          '${widget.label} ${(widget.fraction * 100).toStringAsFixed(widget.decimalPlaces)} percent',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            height: 112,
            child: Stack(
              children: [
                CustomPaint(
                  key: const ValueKey('half-ring-paint'),
                  size: const Size(220, 112),
                  painter: _painter,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedBuilder(
                      animation: _fill,
                      builder: (context, percent) => Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                              (_fill.value * 100)
                                  .toStringAsFixed(widget.decimalPlaces),
                              style: type.largeTitle
                                  .copyWith(fontSize: 44, letterSpacing: -1.32)
                                  .tabular),
                          const SizedBox(width: 1),
                          percent!,
                        ],
                      ),
                      child: Text('%',
                          style: type.emphasized.copyWith(
                              fontSize: 20,
                              letterSpacing: -.24,
                              color: colors.secondaryLabel)),
                    ),
                  ),
                ),
                if (widget.overlayBuilder != null)
                  AnimatedBuilder(
                      animation: _fill,
                      builder: (context, _) =>
                          widget.overlayBuilder!(context, _fill.value)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(widget.label, style: type.subheadStrong),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(
      {required this.fraction, required this.fill, required this.track})
      : trackPaint = (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..color = track),
        fillPaint = (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..color = fill),
        super(repaint: fraction);
  final Animation<double> fraction;
  final Color fill;
  final Color track;
  final Paint trackPaint;
  final Paint fillPaint;

  @override
  void paint(Canvas canvas, Size size) {
    const rect = Rect.fromLTWH(18, 10, 184, 184);
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);
    if (fraction.value > 0) {
      canvas.drawArc(rect, math.pi, math.pi * fraction.value, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.fill != fill ||
      oldDelegate.track != track;
}
