import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';

class ProgressRing extends StatefulWidget {
  const ProgressRing({
    required this.fraction,
    this.size = PantasSize.check,
    this.child,
    this.showCheck = true,
    this.fillDuration,
    this.fillDelay = Duration.zero,
    this.emptyStrokeWidth,
    this.emptyTrackColor,
    super.key,
    this.delay = Duration.zero,
  })  : animateIn = true,
        trackColor = null,
        trackWidth = null,
        studyStyle = false,
        pullStyle = false,
        assert(fraction >= 0 && fraction <= 1, 'Fraction must be from 0 to 1.');
  const ProgressRing.study({
    required this.fraction,
    this.delay = Duration.zero,
    this.size = PantasSize.check,
    this.animateIn = true,
    this.trackColor,
    this.trackWidth,
    super.key,
  })  : emptyStrokeWidth = null,
        emptyTrackColor = null,
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
        size = PantasSize.avatarLg,
        trackColor = null,
        trackWidth = null,
        delay = Duration.zero,
        animateIn = true,
        showCheck = false,
        fillDuration = null,
        fillDelay = Duration.zero,
        studyStyle = false,
        pullStyle = true,
        assert(fraction >= 0 && fraction <= 1, 'Fraction must be from 0 to 1.');
  final double? emptyStrokeWidth;
  final Color? emptyTrackColor;

  /// A track color and width that replace the ring's own (the TaskStatus
  /// half-done marker draws a `border-control` track 1.5 wide).
  final Color? trackColor;
  final double? trackWidth;

  /// The empty ring on the phone's rows. Light keeps the board's pale gray;
  /// dark uses the 3:1 gray, because the pale one disappears into the card.
  static Color phoneEmptyTrack(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? context.colors.iconChevron
          : context.colors.divider;
  final bool pullStyle;
  final bool studyStyle;
  final Duration delay;

  /// False when the ring comes back to a screen that has already shown it
  /// (a list laid out again, a row scrolled back into view): it stands at
  /// [fraction] at once and fills only when [fraction] changes.
  final bool animateIn;
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
  bool _arrived = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (_still != still) {
      final begin = _still == null
          ? (widget.animateIn ? 0.0 : widget.fraction)
          : _fill.value;
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
        oldWidget.trackColor != widget.trackColor ||
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
    // The arc grows over `dur-long-3` after `dur-wait` (ProgressRing README).
    final fillMs = widget.fillDuration?.inMilliseconds ??
        PantasDurations.long3.inMilliseconds;
    final waitMs = PantasDurations.wait.inMilliseconds;
    final checkMs = PantasDurations.medium2.inMilliseconds;
    final overlapMs = PantasDurations.short1.inMilliseconds;
    final endMs = delayMs + waitMs + fillMs + (complete ? checkMs : 0);
    _controller.duration = Duration(milliseconds: endMs);
    _fill = _controller.drive(
      Tween(begin: begin, end: widget.fraction).chain(
        CurveTween(
          curve: Interval(
            (delayMs + waitMs) / endMs,
            (delayMs + waitMs + fillMs) / endMs,
            curve: PantasCurves.house,
          ),
        ),
      ),
    );
    // HP_Day: the check begins a short step before the fill ends.
    _check = _controller.drive(
      CurveTween(
        curve: Interval(
          (delayMs + waitMs + fillMs - overlapMs) / endMs,
          1,
          curve: PantasCurves.spring,
        ),
      ),
    );
    final standing = !_arrived && !widget.animateIn;
    _arrived = true;
    if (_still! || standing) {
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
        dimension: PantasSize.avatarLg,
        child: CustomPaint(
          key: const ValueKey('progress-ring-paint'),
          painter: _RingPainter(
            fraction: _fill,
            track: context.colors.divider,
            fill: context.colors.accent,
            stroke: PantasBorder.ringCurrent,
            trackStroke: PantasBorder.ringCurrent,
            radius: PantasSize.avatarLg / 2 - PantasBorder.ringStrong * 2,
            cap: StrokeCap.butt,
          ),
          child: Center(child: widget.child),
        ),
      );
    }
    final complete = widget.fraction == 1 && widget.showCheck;
    // Track `divider` (decorative: the number is always printed). An empty
    // ring draws no arc, so no dot shows at 12 o'clock.
    final track = widget.trackColor ??
        (widget.fraction == 0
            ? widget.emptyTrackColor ?? context.colors.iconChevron
            : context.colors.divider);
    final stroke = widget.fraction == 0
        ? widget.studyStyle
            ? PantasBorder.ringSelected
            : widget.emptyStrokeWidth ?? PantasBorder.ringStrong
        : PantasSize.ringStroke;
    if (_painter == null ||
        _painter!.trackPaint.strokeWidth !=
            (widget.trackWidth ??
                (widget.studyStyle || widget.fraction > 0
                    ? PantasBorder.ringSelected
                    : stroke)) ||
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
        trackStroke: widget.trackWidth ??
            (widget.studyStyle || widget.fraction > 0
                ? PantasBorder.ringSelected
                : stroke),
      );
    }
    return Semantics(
      label: complete ? 'Done' : '${(widget.fraction * 100).round()} percent',
      excludeSemantics: complete,
      // The fill animates every frame. Its own layer keeps that from
      // repainting the row's text and everything else beside the ring.
      child: RepaintBoundary(
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
        (stroke == PantasBorder.ringStrong
            ? size.width / 2 - PantasBorder.ringStrong / 2
            : size.width / 2 - PantasBorder.ringStrong);
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
