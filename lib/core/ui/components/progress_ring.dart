import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class ProgressRing extends StatefulWidget {
  const ProgressRing({
    required this.fraction,
    this.size = 24,
    this.child,
    this.showCheck = true,
    this.fillDuration,
    this.fillDelay = Duration.zero,
    this.emptyStrokeWidth,
    this.emptyTrackColor,
    super.key,
    this.delay = Duration.zero,
  })  : studyStyle = false,
        pullStyle = false,
        assert(fraction >= 0 && fraction <= 1, 'Fraction must be from 0 to 1.');
  const ProgressRing.study({
    required this.fraction,
    this.delay = Duration.zero,
    super.key,
  })  : emptyStrokeWidth = null,
        emptyTrackColor = null,
        size = 24,
        child = null,
        showCheck = false,
        fillDuration = null,
        fillDelay = Duration.zero,
        pullStyle = false,
        studyStyle = true,
        assert(fraction >= 0 && fraction <= 1, 'Fraction must be from 0 to 1.');
  const ProgressRing.pull({
    required this.fraction,
    this.child,
    super.key,
  })  : emptyStrokeWidth = null,
        emptyTrackColor = null,
        size = 44,
        delay = Duration.zero,
        showCheck = false,
        fillDuration = null,
        fillDelay = Duration.zero,
        studyStyle = false,
        pullStyle = true,
        assert(fraction >= 0 && fraction <= 1, 'Fraction must be from 0 to 1.');
  final double? emptyStrokeWidth;
  final Color? emptyTrackColor;
  final bool pullStyle;
  final bool studyStyle;
  final Duration delay;
  final double fraction;
  final double size;
  final Widget? child;
  final bool showCheck;
  final Duration? fillDuration;
  final Duration fillDelay;
  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late Animation<double> _fill;
  late Animation<double> _check;
  bool? _still;
  _RingPainter? _painter;
  bool _animated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (_still != still) {
      final begin = _still == null ? 0.0 : _fill.value;
      _still = still;
      animate(begin);
    }
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fraction != widget.fraction ||
        oldWidget.size != widget.size ||
        oldWidget.showCheck != widget.showCheck ||
        oldWidget.fillDuration != widget.fillDuration ||
        oldWidget.fillDelay != widget.fillDelay ||
        oldWidget.emptyStrokeWidth != widget.emptyStrokeWidth ||
        oldWidget.emptyTrackColor != widget.emptyTrackColor ||
        oldWidget.pullStyle != widget.pullStyle ||
        oldWidget.studyStyle != widget.studyStyle) {
      animate(_fill.value);
    }
  }

  void animate(double begin) {
    if (widget.pullStyle) {
      _controller.stop();
      _fill = AlwaysStoppedAnimation(widget.fraction);
      _check = const AlwaysStoppedAnimation(0);
      return;
    }
    final complete = widget.fraction == 1 && widget.showCheck;
    final delayMs = widget.studyStyle
        ? (!_animated ? widget.delay.inMilliseconds : 0)
        : widget.fillDelay.inMilliseconds;
    _animated = true;
    final fillMs = widget.studyStyle
        ? 700
        : widget.fillDuration?.inMilliseconds ??
            (widget.size == 34 ? 1200 : 600);
    final endMs = delayMs + fillMs + (complete ? 320 : 0);
    _controller.duration = Duration(milliseconds: endMs);
    _fill = _controller.drive(
      Tween(begin: begin, end: widget.fraction).chain(
        CurveTween(
          curve: Interval(
            (delayMs + (!widget.studyStyle && widget.size == 34 ? 300 : 0)) /
                endMs,
            (delayMs + fillMs) / endMs,
            curve: PantasCurves.houseOut,
          ),
        ),
      ),
    );
    // HP_Day: the 420ms check begins 100ms before the 600ms fill ends.
    _check = _controller.drive(
      CurveTween(
        curve: Interval(
          (delayMs + fillMs - 100) / endMs,
          1,
          curve: PantasCurves.popC,
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
    if (widget.pullStyle) {
      return SizedBox.square(
        dimension: 44,
        child: CustomPaint(
          key: const ValueKey('progress-ring-paint'),
          painter: _RingPainter(
            fraction: _fill,
            track: context.colors.separator,
            fill: context.colors.accent,
            stroke: 2.5,
            trackStroke: 2.5,
            radius: 19,
            cap: StrokeCap.butt,
          ),
          child: Center(child: widget.child),
        ),
      );
    }
    final complete = widget.fraction == 1 && widget.showCheck;
    final track = widget.fraction == 0
        ? widget.studyStyle
            ? context.colors.separator
            : widget.emptyTrackColor ?? context.colors.chevron
        : widget.size == 34
            ? context.colors.accentTint
            : context.colors.separator;
    final stroke = widget.fraction == 0
        ? widget.studyStyle
            ? 2.0
            : widget.emptyStrokeWidth ?? 1.5
        : widget.size == 34
            ? 2.5
            : 2.4;
    if (_painter == null ||
        _painter!.fraction != _fill ||
        _painter!.track != track ||
        _painter!.fill != context.colors.accent ||
        _painter!.stroke != stroke) {
      _painter = _RingPainter(
        fraction: _fill,
        track: track,
        fill: context.colors.accent,
        stroke: stroke,
        radius: widget.fraction == 0 && widget.emptyStrokeWidth != null
            ? (widget.size - stroke) / 2
            : null,
        trackStroke: widget.size == 24 && widget.fraction > 0 ? 2 : stroke,
      );
    }
    return Semantics(
      label: complete ? 'Done' : '${(widget.fraction * 100).round()} percent',
      excludeSemantics: complete,
      child: SizedBox.square(
        dimension: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              key: const ValueKey('progress-ring-paint'),
              size: Size.square(widget.size),
              painter: _painter,
              child: Center(child: widget.child),
            ),
            if (complete) CheckMark(progress: _check),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.fill,
    required this.stroke,
    required double trackStroke,
    this.radius,
    StrokeCap cap = StrokeCap.round,
  })  : trackPaint = (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackStroke
          ..color = track),
        fillPaint = (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = cap
          ..color = fill),
        super(repaint: fraction);
  final Animation<double> fraction;
  final Color track;
  final Color fill;
  final double stroke;
  final double? radius;
  final Paint trackPaint;
  final Paint fillPaint;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = this.radius ??
        (stroke == 1.5 ? size.width / 2 - .75 : size.width / 2 - 1.5);
    canvas.drawCircle(center, radius, trackPaint);
    if (fraction.value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * fraction.value,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      fraction != oldDelegate.fraction ||
      track != oldDelegate.track ||
      fill != oldDelegate.fill ||
      stroke != oldDelegate.stroke ||
      radius != oldDelegate.radius ||
      fillPaint.strokeCap != oldDelegate.fillPaint.strokeCap;
}
