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
    this.web = false,
    super.key,
  })  : assessment = false,
        correct = null,
        total = null,
        mockSize = false,
        numberOpacity = 1,
        labelOpacity = 1,
        displayedFraction = null,
        odometerProgress = null,
        trackOpacity = 1,
        glowOpacity = 0,
        glowScale = 1,
        assert(
          fraction >= 0 && fraction <= 1,
          'Accuracy must be between zero and one.',
        );

  /// MK_Results uses a different arc, hero size and baseline from Home.
  const HalfRingGauge.mock({
    required this.fraction,
    required this.label,
    this.overlayBuilder,
    this.web = false,
    this.numberOpacity = 1,
    this.labelOpacity = 1,
    this.displayedFraction,
    this.odometerProgress,
    this.trackOpacity = 1,
    this.glowOpacity = 0,
    this.glowScale = 1,
    super.key,
  })  : assessment = false,
        correct = null,
        total = null,
        mockSize = true,
        decimalPlaces = 1,
        assert(fraction >= -.25 && fraction <= 1, 'Mock score must be valid.');

  const HalfRingGauge.quizCount({
    required int correct,
    required int total,
    this.assessment = false,
    this.labelOpacity = 1,
    this.web = false,
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
        decimalPlaces = 0,
        mockSize = false,
        numberOpacity = 1,
        displayedFraction = null,
        odometerProgress = null,
        trackOpacity = 1,
        glowOpacity = 0,
        glowScale = 1;

  final bool web;
  final bool assessment;
  final int? correct;
  final int? total;
  final double numberOpacity;
  final double labelOpacity;
  final double? displayedFraction;

  /// The desktop finale uses the board's vertical score strip.
  final double? odometerProgress;
  final double trackOpacity;
  final double glowOpacity;
  final double glowScale;
  final bool mockSize;
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
    _controller.duration =
        Duration(milliseconds: quiz ? (widget.assessment ? 1500 : 1600) : 1400);
    final curve = quiz
        ? Interval(
            widget.assessment ? 4 / 15 : .25,
            1,
            curve: const Cubic(.2, .8, .25, 1),
          )
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

  Widget _mockOdometer(BuildContext context, PantasType type) {
    final style = type.largeTitle
        .copyWith(fontSize: 64, height: 1, letterSpacing: -1.68)
        .tabular;
    final target = widget.fraction * 100;
    final text = TextPainter(
      text: TextSpan(text: target.toStringAsFixed(1), style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = text.width;
    text.dispose();
    final height = MediaQuery.textScalerOf(context).scale(64);
    return Baseline(
      baseline: height * .8,
      baselineType: TextBaseline.alphabetic,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topRight,
            maxHeight: height * 47,
            child: Transform.translate(
              key: const ValueKey('web-finale-odometer'),
              offset: Offset(0, -height * 46 * widget.odometerProgress!),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i <= 46; i++)
                    SizedBox(
                      height: height,
                      child: Text(
                        (target * i / 46).toStringAsFixed(1),
                        style: style,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
    final quiz = widget.correct != null;
    final large = quiz || widget.mockSize;
    final wideAssessment = quiz && widget.web && widget.assessment;
    final wideQuiz = quiz && widget.web && !wideAssessment;
    final wideMock = widget.mockSize && widget.web;
    if (_painter == null ||
        _painter!.fraction != _fill ||
        _painter!.trackOpacity != widget.trackOpacity ||
        _painter!.glowOpacity != widget.glowOpacity ||
        _painter!.glowScale != widget.glowScale ||
        _painter!.fill != colors.accent ||
        _painter!.track != colors.fill ||
        _painter!.mockSize != large ||
        _painter!.wideMock != wideMock ||
        _painter!.wideAssessment != wideAssessment ||
        _painter!.web != widget.web) {
      _painter = _GaugePainter(
        fraction: _fill,
        trackOpacity: widget.trackOpacity,
        glowOpacity: widget.glowOpacity,
        glowScale: widget.glowScale,
        fill: colors.accent,
        track: colors.fill,
        mockSize: large,
        web: widget.web,
        wideMock: wideMock,
        wideAssessment: wideAssessment,
      );
    }
    final percentage = ((widget.displayedFraction ?? widget.fraction) * 100)
        .toStringAsFixed(widget.decimalPlaces);
    return Semantics(
      hidden: widget.numberOpacity == 0 && widget.labelOpacity == 0,
      label: quiz
          ? '${widget.correct} of ${widget.total} correct'
          : [
              if (widget.labelOpacity > 0) widget.label,
              if (widget.numberOpacity > 0) '$percentage percent',
            ].join(' '),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: wideAssessment
                ? 264
                : wideMock
                    ? 300
                    : wideQuiz
                        ? 320
                        : large
                            ? 264
                            : widget.web
                                ? 224
                                : 220,
            height: wideAssessment
                ? 140
                : wideMock
                    ? 158
                    : wideQuiz
                        ? 150
                        : large
                            ? 128
                            : widget.web
                                ? 118
                                : 112,
            child: Stack(
              children: [
                CustomPaint(
                  key: const ValueKey('half-ring-paint'),
                  size: wideAssessment
                      ? const Size(264, 140)
                      : wideMock
                          ? const Size(300, 158)
                          : wideQuiz
                              ? const Size(320, 150)
                              : large
                                  ? const Size(264, 128)
                                  : widget.web
                                      ? const Size(224, 118)
                                      : const Size(220, 112),
                  painter: _painter,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: wideAssessment
                      ? 24
                      : large
                          ? 2
                          : widget.web
                              ? 0
                              : 10,
                  child: Opacity(
                    opacity: widget.numberOpacity,
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
                                  if (wideMock &&
                                      widget.odometerProgress != null)
                                    _mockOdometer(context, type)
                                  else
                                    Text(
                                      ((widget.displayedFraction ??
                                                  _fill.value) *
                                              100)
                                          .toStringAsFixed(
                                        widget.decimalPlaces,
                                      ),
                                      style: type.largeTitle
                                          .copyWith(
                                            fontSize: wideMock
                                                ? 64
                                                : large
                                                    ? 56
                                                    : widget.web
                                                        ? 48
                                                        : 44,
                                            height:
                                                large || widget.web ? 1 : 1.12,
                                            letterSpacing:
                                                large ? -1.68 : -1.32,
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
                                  fontSize: wideMock
                                      ? 26
                                      : large
                                          ? 24
                                          : widget.web
                                              ? 22
                                              : 20,
                                  letterSpacing: -.24,
                                  color: colors.secondaryLabel,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                if (wideAssessment)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: type.subhead.copyWith(
                        fontSize: 16,
                        color: colors.secondaryLabel,
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
          if (!wideAssessment)
            SizedBox(
              height: wideMock
                  ? 10
                  : large || widget.web
                      ? 4
                      : 6,
            ),
          if (!wideAssessment)
            Opacity(
              opacity: widget.labelOpacity,
              child: Text(
                widget.label,
                style: quiz
                    ? type.subhead.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.secondaryLabel,
                      )
                    : wideMock
                        ? type.subhead.copyWith(
                            fontSize: 16,
                            color: colors.secondaryLabel,
                          )
                        : large
                            ? type.subhead
                                .copyWith(color: colors.secondaryLabel)
                            : type.subheadStrong,
              ),
            ),
        ],
      ),
    );
  }

  Widget _rollingCount(BuildContext context, PantasType type) {
    final style = type.largeTitle
        .copyWith(
          fontSize: widget.web && !widget.assessment ? 76 : 60,
          height: 1,
          letterSpacing: -1.8,
        )
        .tabular;
    final scaler = MediaQuery.textScalerOf(context);
    final fontSize = widget.web && !widget.assessment ? 76.0 : 60.0;
    final countHeight = widget.web && !widget.assessment ? 80.0 : 64.0;
    final extent = countHeight * scaler.scale(fontSize) / fontSize;
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
      height: countHeight,
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
                        fontSize: widget.web && !widget.assessment ? 28 : 24,
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
    required this.fill,
    required this.track,
    required this.mockSize,
    required this.web,
    this.trackOpacity = 1,
    this.glowOpacity = 0,
    this.glowScale = 1,
    this.wideMock = false,
    this.wideAssessment = false,
  })  : trackPaint = (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = wideAssessment
              ? 16
              : wideMock
                  ? 18
                  : web
                      ? 14
                      : 16
          ..strokeCap = StrokeCap.round
          ..color = track),
        fillPaint = (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = wideAssessment
              ? 16
              : wideMock
                  ? 18
                  : web
                      ? 14
                      : 16
          ..strokeCap = StrokeCap.round
          ..color = fill),
        super(repaint: fraction);
  final bool mockSize;
  final bool wideMock;
  final double trackOpacity;
  final double glowOpacity;
  final double glowScale;
  final bool wideAssessment;
  final bool web;
  final Animation<double> fraction;
  final Color fill;
  final Color track;
  final Paint trackPaint;
  final Paint fillPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = wideAssessment
        ? const Rect.fromLTWH(18, 16, 228, 228)
        : wideMock
            ? const Rect.fromLTWH(24, 20, 252, 252)
            : mockSize && web
                ? const Rect.fromLTWH(22, 12, 276, 276)
                : mockSize
                    ? const Rect.fromLTWH(24, 10, 216, 216)
                    : web
                        ? const Rect.fromLTWH(18, 14, 188, 188)
                        : const Rect.fromLTWH(18, 10, 184, 184);
    if (wideMock && glowOpacity > 0) {
      final center = Offset(size.width / 2, size.height * .7);
      final radius = 150 * glowScale;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              fill.withValues(alpha: .22 * glowOpacity),
              fill.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      trackPaint..color = track.withValues(alpha: trackOpacity),
    );
    if (fraction.value > 0) {
      canvas.drawArc(rect, math.pi, math.pi * fraction.value, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.trackOpacity != trackOpacity ||
      oldDelegate.glowOpacity != glowOpacity ||
      oldDelegate.glowScale != glowScale ||
      oldDelegate.fill != fill ||
      oldDelegate.track != track ||
      oldDelegate.mockSize != mockSize ||
      oldDelegate.wideMock != wideMock ||
      oldDelegate.wideAssessment != wideAssessment ||
      oldDelegate.web != web;
}
