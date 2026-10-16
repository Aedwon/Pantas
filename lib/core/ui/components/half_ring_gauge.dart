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
  })  : correct = null,
        total = null,
        assert(
          fraction >= 0 && fraction <= 1,
          'Accuracy must be between zero and one.',
        );
  const HalfRingGauge.quizCount({
    required int correct,
    required int total,
    super.key,
  })  : assert(
          correct >= 0 && total >= correct,
          'Correct count must be between zero and total.',
        ),
        correct = correct,
        total = total,
        fraction = total == 0 ? 0 : correct / total,
        label = 'correct',
        overlayBuilder = null,
        decimalPlaces = 0;

  final int? correct;
  final int? total;
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
  late Animation<double> _count;
  bool? _still;
  _GaugePainter? _painter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still != _still) {
      final begin = _still == null ? 0.0 : _fill.value;
      final beginCount = _still == null ? 0.0 : _count.value;
      _still = still;
      animate(begin, beginCount: beginCount);
    }
  }

  @override
  void didUpdateWidget(HalfRingGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fraction != widget.fraction ||
        oldWidget.correct != widget.correct ||
        oldWidget.total != widget.total) {
      animate(_fill.value, beginCount: _count.value);
    }
  }

  void animate(double begin, {double beginCount = 0}) {
    final quiz = widget.correct != null;
    _controller.duration = Duration(milliseconds: quiz ? 1600 : 1400);
    final curve = quiz
        ? const Interval(.25, 1, curve: Cubic(.2, .8, .25, 1))
        : const Interval(3 / 14, 1, curve: PantasCurves.houseOut);
    _count = _controller.drive(
      Tween(begin: beginCount, end: (widget.correct ?? 0).toDouble())
          .chain(CurveTween(curve: curve)),
    );
    _fill = _controller.drive(
      Tween(begin: begin, end: widget.fraction).chain(
        CurveTween(
          curve: curve,
        ),
      ),
    );
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
    final quiz = widget.correct != null;
    final rect = quiz
        ? const Rect.fromLTWH(24, 10, 216, 216)
        : const Rect.fromLTWH(18, 10, 184, 184);
    final colors = context.colors;
    final type = context.type;
    if (_painter == null ||
        _painter!.fraction != _fill ||
        _painter!.fill != colors.accent ||
        _painter!.track != colors.fill ||
        _painter!.rect != rect) {
      _painter = _GaugePainter(
        fraction: _fill,
        rect: rect,
        fill: colors.accent,
        track: colors.fill,
      );
    }
    final percentage =
        (widget.fraction * 100).toStringAsFixed(widget.decimalPlaces);
    return Semantics(
      label: quiz
          ? '${widget.correct} of ${widget.total} correct'
          : '${widget.label} $percentage percent',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: quiz ? 264 : 220,
            height: quiz ? 128 : 112,
            child: Stack(
              children: [
                CustomPaint(
                  key: const ValueKey('half-ring-paint'),
                  size: quiz ? const Size(264, 128) : const Size(220, 112),
                  painter: _painter,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: quiz ? 2 : 10,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: quiz
                        ? _rollingCount(context, type)
                        : AnimatedBuilder(
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
                                      .copyWith(
                                        fontSize: 44,
                                        letterSpacing: -1.32,
                                      )
                                      .tabular,
                                ),
                                const SizedBox(width: 1),
                                percent!,
                              ],
                            ),
                            child: Text(
                              '%',
                              style: type.emphasized.copyWith(
                                fontSize: 20,
                                letterSpacing: -.24,
                                color: colors.secondaryLabel,
                              ),
                            ),
                          ),
                  ),
                ),
                if (widget.overlayBuilder != null)
                  AnimatedBuilder(
                    animation: _fill,
                    builder: (context, _) =>
                        widget.overlayBuilder!(context, _fill.value),
                  ),
              ],
            ),
          ),
          SizedBox(height: quiz ? 4 : 6),
          Text(
            widget.label,
            style: quiz
                ? type.subhead.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.secondaryLabel,
                  )
                : type.subheadStrong,
          ),
        ],
      ),
    );
  }

  Widget _rollingCount(BuildContext context, PantasType type) {
    final style = type.largeTitle
        .copyWith(fontSize: 60, height: 1, letterSpacing: -1.8)
        .tabular;
    final scaler = MediaQuery.textScalerOf(context);
    final extent = 64 * scaler.scale(60) / 60;
    final measure = TextPainter(
      text: TextSpan(
        text: '${math.max(widget.correct!, _count.value.ceil())}',
        style: style,
      ),
      textDirection: Directionality.of(context),
      textScaler: scaler,
    )..layout();
    final width = measure.width;
    measure.dispose();
    return SizedBox(
      height: 64,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedBuilder(
          animation: _count,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRect(
                child: SizedBox(
                  width: width,
                  height: extent,
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: double.infinity,
                    child: Transform.translate(
                      key: const ValueKey('quiz-count-strip'),
                      offset: Offset(0, -_count.value * extent),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Keep only the current number and its neighbors.
                          // Preserve the board's absolute offset with a spacer.
                          SizedBox(
                            height:
                                math.max(0, _count.value.floor() - 1) * extent,
                          ),
                          for (var i = math.max(0, _count.value.floor() - 1);
                              i <=
                                  math.min(
                                    math.max(
                                      widget.correct!,
                                      _count.value.ceil(),
                                    ),
                                    _count.value.ceil() + 1,
                                  );
                              i++)
                            SizedBox(
                              height: extent,
                              child: Center(
                                child: Text('$i', style: style),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(
                  '/${widget.total}',
                  style: type.emphasized
                      .copyWith(
                        fontSize: 24,
                        height: 1.35,
                        color: context.colors.secondaryLabel,
                      )
                      .tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.fraction,
    required this.rect,
    required this.fill,
    required this.track,
  })  : trackPaint = (Paint()
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
  final Rect rect;
  final Color fill;
  final Color track;
  final Paint trackPaint;
  final Paint fillPaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);
    if (fraction.value > 0) {
      canvas.drawArc(rect, math.pi, math.pi * fraction.value, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.fraction != fraction ||
      oldDelegate.fill != fill ||
      oldDelegate.track != track;
}
