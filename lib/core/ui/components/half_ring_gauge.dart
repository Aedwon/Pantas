import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

// The Gauge component is a 224 by 118 dial with a 14 px stroke
// (`size-gauge-w`, `size-gauge-stroke`). The quiz result, the assessment
// result and the mock finale draw larger dials from their own boards, which
// the system has no tokens for: their geometry and number sizes are named
// here, so the gap is in one place (reported to the lead).

/// The dial's `aspect-ratio: 224 / 118`.
const double _dialRatio = 118 / 224;

/// Quiz and mock result dial (phone), and the wide assessment dial.
const double _largeWidth = 264;
const double _largeHeight = 128;
const double _wideAssessmentHeight = 140;
const double _wideMockWidth = 300;
const double _wideMockHeight = 158;
const double _wideQuizWidth = 320;
const double _wideQuizHeight = 150;
const double _largeStroke = 16;
const double _wideMockStroke = 18;

/// The wide quiz result dial, for a page that crops around it.
const wideQuizDial = Size(_wideQuizWidth, _wideQuizHeight);

/// Number and unit sizes of those boards.
const double _largeNumber = 56;
const double _wideMockNumber = 64;
const double _largeUnit = 24;
const double _wideMockUnit = 26;
const double _quizCount = 60;
const double _wideQuizCount = 76;
const double _quizCountHeight = 64;
const double _wideQuizCountHeight = 80;
const double _quizTotal = 24;
const double _wideQuizTotal = 28;
const Duration _quizWait = Duration(milliseconds: 400);
const Duration _quizDuration = Duration(milliseconds: 1600);
const Duration _assessmentDuration = Duration(milliseconds: 1500);

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
    duration: PantasDurations.gauge,
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
    _controller.duration = quiz
        ? (widget.assessment ? _assessmentDuration : _quizDuration)
        : PantasDurations.gauge;
    // The arc waits `dur-wait` and then fills on `motion-gauge`. The quiz
    // result keeps its board's 400 ms lead.
    final wait = (quiz ? _quizWait : PantasDurations.wait).inMilliseconds /
        _controller.duration!.inMilliseconds;
    final curve = Interval(wait, 1, curve: PantasCurves.gauge);
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

  Widget _mockOdometer(BuildContext context) {
    final style = PantasType.webDisplay.copyWith(
      fontSize: _wideMockNumber,
      color: context.colors.textPrimary,
    );
    final target = widget.fraction * 100;
    final text = TextPainter(
      text: TextSpan(text: target.toStringAsFixed(1), style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = text.width;
    text.dispose();
    final height = MediaQuery.textScalerOf(context).scale(_wideMockNumber);
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
        _painter!.liquidStart != colors.liquidStart ||
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
        liquidStart: colors.liquidStart,
        track: colors.fill,
        mockSize: large,
        web: widget.web,
        wideMock: wideMock,
        wideAssessment: wideAssessment,
      );
    }
    const defaultDial = Size(
      PantasSize.gaugeW,
      PantasSize.gaugeW * _dialRatio,
    );
    final dial = wideAssessment
        ? const Size(_largeWidth, _wideAssessmentHeight)
        : wideMock
            ? const Size(_wideMockWidth, _wideMockHeight)
            : wideQuiz
                ? const Size(_wideQuizWidth, _wideQuizHeight)
                : large
                    ? const Size(_largeWidth, _largeHeight)
                    : defaultDial;
    final numberStyle =
        (widget.web ? PantasType.webDisplay : PantasType.phoneDisplayS)
            .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
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
          _ScaledDial(
            dial: dial,
            builder: (context) => Stack(
              children: [
                CustomPaint(
                  key: const ValueKey('half-ring-paint'),
                  size: dial,
                  painter: _painter,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: wideAssessment
                      ? PantasSpace.s24
                      : large
                          ? PantasSpace.s2
                          : PantasSpace.s0,
                  child: Opacity(
                    opacity: widget.numberOpacity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: quiz
                          ? _rollingCount(context)
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
                                    _mockOdometer(context)
                                  else
                                    Text(
                                      ((widget.displayedFraction ??
                                                  _fill.value) *
                                              100)
                                          .toStringAsFixed(
                                        widget.decimalPlaces,
                                      ),
                                      style: numberStyle.copyWith(
                                        color: colors.textPrimary,
                                        fontSize: wideMock
                                            ? _wideMockNumber
                                            : large
                                                ? _largeNumber
                                                : null,
                                        height: large ? 1 : null,
                                      ),
                                    ),
                                  const SizedBox(width: PantasSpace.s2),
                                  percent!,
                                ],
                              ),
                              child: Text(
                                '%',
                                style: PantasType.webStatUnit.copyWith(
                                  fontSize: wideMock
                                      ? _wideMockUnit
                                      : large
                                          ? _largeUnit
                                          : null,
                                  color: colors.textSecondary,
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
                      style: PantasType.webBody.copyWith(
                        color: colors.textSecondary,
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
              height: wideMock ? PantasSpace.s10 : PantasSpace.s4,
            ),
          if (!wideAssessment)
            Opacity(
              opacity: widget.labelOpacity,
              child: Text(
                widget.label,
                style: (wideMock ? PantasType.webBody : PantasType.webSub)
                    .copyWith(
                  fontWeight: quiz ? FontWeight.w500 : null,
                  color: colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rollingCount(BuildContext context) {
    final wide = widget.web && !widget.assessment;
    final fontSize = wide ? _wideQuizCount : _quizCount;
    final style = PantasType.phoneDisplayM.copyWith(
      fontSize: fontSize,
      color: context.colors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final scaler = MediaQuery.textScalerOf(context);
    final countHeight = wide ? _wideQuizCountHeight : _quizCountHeight;
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
              const SizedBox(width: PantasSpace.s4),
              Padding(
                padding: const EdgeInsets.only(bottom: PantasSpace.s8),
                child: Text(
                  '/${widget.total}',
                  style: PantasType.webStatUnit.copyWith(
                    fontSize: wide ? _wideQuizTotal : _quizTotal,
                    height: PantasType.phoneBody.height,
                    color: context.colors.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a dial at its board size and grows the whole dial with the text.
///
/// The number sits inside the arc, so scaling only the number at 200 percent
/// pushed it through the stroke. The dial is drawn at the board's size with
/// the text scale taken off, then scaled up as one piece by the text scale,
/// as far as the width allows. The number, the arc and the overlay keep their
/// proportions at every text size.
class _ScaledDial extends StatelessWidget {
  const _ScaledDial({required this.dial, required this.builder});

  final Size dial;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final grown = media.textScaler.scale(16) / 16;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Below 1x the whole dial shrinks with the text; above it, it grows
        // as far as the width allows.
        var grow = grown;
        if (grown > 1 && constraints.hasBoundedWidth) {
          final room = constraints.maxWidth / dial.width;
          if (grow > room) grow = room < 1 ? 1.0 : room;
        }
        return SizedBox(
          width: dial.width * grow,
          height: dial.height * grow,
          child: FittedBox(
            child: SizedBox(
              width: dial.width,
              height: dial.height,
              child: MediaQuery(
                data: media.copyWith(textScaler: TextScaler.noScaling),
                child: Builder(builder: builder),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.fraction,
    required this.fill,
    required this.liquidStart,
    required this.track,
    required this.mockSize,
    required this.web,
    this.trackOpacity = 1,
    this.glowOpacity = 0,
    this.glowScale = 1,
    this.wideMock = false,
    this.wideAssessment = false,
  })  : stroke = wideAssessment
            ? _largeStroke
            : wideMock
                ? _wideMockStroke
                : mockSize
                    ? _largeStroke
                    : PantasSize.gaugeStroke,
        trackPaint = (Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = track),
        fillPaint = (Paint()
          ..style = PaintingStyle.stroke
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

  /// The liquid gradient runs from this color to [fill] (`accent`) across
  /// the dial, so the arc ends on the contrast color in both themes.
  final Color liquidStart;
  final Color track;
  final double stroke;
  final Paint trackPaint;
  final Paint fillPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = wideAssessment
        ? const Rect.fromLTWH(18, 16, 228, 228)
        : wideMock
            ? const Rect.fromLTWH(18, 14, 264, 264)
            : mockSize && web
                ? const Rect.fromLTWH(22, 12, 276, 276)
                : mockSize
                    ? const Rect.fromLTWH(24, 10, 216, 216)
                    // The Gauge dial: the arc runs from (7, 111) to (217, 111)
                    // with radius 105, so the stroke fits the dial.
                    : Rect.fromCircle(
                        center:
                            Offset(size.width / 2, size.height - stroke / 2),
                        radius: size.width / 2 - stroke / 2,
                      );
    trackPaint.strokeWidth = stroke;
    fillPaint
      ..strokeWidth = stroke
      ..shader = LinearGradient(colors: [liquidStart, fill]).createShader(rect);
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
      oldDelegate.liquidStart != liquidStart ||
      oldDelegate.track != track ||
      oldDelegate.mockSize != mockSize ||
      oldDelegate.wideMock != wideMock ||
      oldDelegate.wideAssessment != wideAssessment ||
      oldDelegate.web != web;
}
