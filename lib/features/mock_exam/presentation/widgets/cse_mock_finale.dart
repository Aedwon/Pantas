import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_finale_motion.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_finale_tracks.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_mock_finale.dart';

/// A single submission clock, shared by the booklet and actual results.
class CseMockFinale extends StatefulWidget {
  const CseMockFinale({
    required this.input,
    required this.blueprintName,
    required this.resultsBuilder,
    this.dateFormatted = '',
    super.key,
  });
  final MockFinaleInput input;
  final String blueprintName;
  final String dateFormatted;
  final Widget Function(BuildContext, Animation<double>) resultsBuilder;

  @override
  State<CseMockFinale> createState() => _CseMockFinaleState();
}

class _CseMockFinaleState extends State<CseMockFinale>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9650),
  );
  late final Animation<double> _clock =
      _controller.drive(Tween(begin: 0, end: 9650));
  late final _motion = CseFinaleMotion(widget.input);
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.wideWeb ||
        MediaQuery.disableAnimationsOf(context) ||
        _motion.questions.isEmpty) {
      _controller
        ..stop()
        ..value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => context.wideWeb
      ? WebMockFinale(
          input: widget.input,
          name: widget.blueprintName,
          resultsBuilder: widget.resultsBuilder,
        )
      : LayoutBuilder(
          builder: (context, size) {
            final scale = size.maxWidth / 390;
            return FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: 390,
                height: size.maxHeight / scale,
                child: AnimatedBuilder(
                  animation: _clock,
                  builder: (context, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      AbsorbPointer(
                        absorbing: _clock.value < 5850,
                        child: widget.resultsBuilder(context, _clock),
                      ),
                      if (_clock.value < 6450)
                        IgnorePointer(
                          child: Semantics(
                            label: '${_motion.questions.length} questions. '
                                'Checking your answers.',
                            child: CustomPaint(
                              key: const ValueKey('cse-finale-scene'),
                              painter: _CseScene(
                                context: context,
                                motion: _motion,
                                input: widget.input,
                                milliseconds: _clock.value,
                                name: widget.blueprintName,
                                date: widget.dateFormatted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
}

/// The same measured title block positions the live gauge and its impact.
double cseFinaleGaugeTop(BuildContext context, String name, String date) {
  double height(String text, TextStyle style) => (TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: 350))
          .height;
  return 50 +
      height(
        name,
        context.type.pageTitle.copyWith(fontSize: 22, height: 1.35),
      ) +
      2 +
      height(date, context.type.subhead.copyWith(fontSize: 15, height: 1.35)) +
      10;
}

class _CseScene extends CustomPainter {
  _CseScene({
    required this.context,
    required this.motion,
    required this.input,
    required this.milliseconds,
    required this.name,
    required this.date,
  });
  final BuildContext context;
  final CseFinaleMotion motion;
  final MockFinaleInput input;
  final double milliseconds;
  final String name;
  final String date;

  TextPainter _text(
    String value,
    double fontSize,
    FontWeight weight,
    Color color,
    double height,
  ) =>
      TextPainter(
        text: TextSpan(
          text: value,
          style: context.type.body.copyWith(
            fontSize: fontSize,
            fontWeight: weight,
            letterSpacing: fontSize >= 30 ? -.022 * fontSize : 0,
            color: color,
            height: height,
          ),
        ),
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 350);

  void _showText(Canvas canvas, TextPainter text, Offset at, double opacity) {
    if (opacity <= 0) return;
    canvas.saveLayer(
      Offset.zero & const Size(390, 1800),
      Paint()..color = Colors.white.withValues(alpha: opacity.clamp(0, 1)),
    );
    text.paint(canvas, at);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final colors = context.colors;
    final firstTitle = input.reason == MockSubmitReason.timeUp
        ? 'Time is up.'
        : 'Checking your answers';
    final initialTitle =
        _text(firstTitle, 32, FontWeight.w700, colors.label, 1.12);
    final checkingTitle =
        _text('Checking your answers', 30, FontWeight.w700, colors.label, 1.15);
    final subtitle =
        _text(name, 16, FontWeight.w400, colors.secondaryLabel, 1.35);
    final extra = math.max<double>(
      0,
      math.max(
        46 + initialTitle.height + subtitle.height + 24 - 148,
        46 + checkingTitle.height + subtitle.height + 24 - 260,
      ),
    );
    final gaugeDelta = cseFinaleGaugeTop(context, name, date) - 112;
    final gather = Offset(195, 359 + gaugeDelta);
    final opening = cseFinaleInterval(
      milliseconds,
      1007.5395,
      1462.4475,
      const Cubic(.32, .72, 0, 1),
    );
    final fade = sampleCseFinaleEffect(531, milliseconds).opacity;
    final countA = _text(
      '${motion.questions.length - motion.blankCount} answered',
      13,
      FontWeight.w500,
      colors.secondaryLabel,
      1.35,
    );
    final countB = _text(
      '${motion.blankCount} blank',
      13,
      FontWeight.w500,
      colors.secondaryLabel,
      1.35,
    );
    final widthA = 16 + countA.width;
    final widthB = 16 + countB.width;
    final wrap = widthA + widthB + 16 > 330;
    final countHeight = wrap
        ? countA.height + countB.height
        : math.max(countA.height, countB.height);
    final card = motion.cardAt(milliseconds).shift(Offset(0, extra));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          card.left,
          card.top,
          card.width,
          card.height + math.max(0, countHeight - 20) * (1 - opening),
        ),
        const Radius.circular(14),
      ),
      Paint()..color = colors.surface.withValues(alpha: fade),
    );

    final firstOpacity = sampleCseFinaleEffect(534, milliseconds).opacity;
    final checkingOpacity = sampleCseFinaleEffect(535, milliseconds).opacity;
    _showText(canvas, initialTitle, const Offset(20, 46), firstOpacity);
    _showText(
      canvas,
      subtitle,
      Offset(20, 46 + initialTitle.height),
      firstOpacity,
    );
    _showText(canvas, checkingTitle, const Offset(20, 46), checkingOpacity);
    _showText(
      canvas,
      subtitle,
      Offset(20, 46 + checkingTitle.height),
      checkingOpacity,
    );
    final countTop = motion.countY + extra;
    void legend(
      TextPainter text,
      double left,
      double top, {
      required bool blank,
    }) {
      final center = Offset(left + 5, top + text.height / 2);
      if (firstOpacity > 0) {
        canvas.drawCircle(
          center,
          blank ? 4.25 : 5,
          Paint()
            ..color = (blank ? colors.tertiaryLabel : colors.pendingMark)
                .withValues(alpha: firstOpacity)
            ..style = blank ? PaintingStyle.stroke : PaintingStyle.fill
            ..strokeWidth = 1.5,
        );
      }
      _showText(canvas, text, Offset(left + 16, top), firstOpacity);
    }

    if (wrap) {
      legend(countA, (390 - widthA) / 2, countTop, blank: false);
      legend(countB, (390 - widthB) / 2, countTop + countA.height, blank: true);
    } else {
      final left = (390 - widthA - widthB - 16) / 2;
      legend(countA, left, countTop, blank: false);
      legend(countB, left + widthA + 16, countTop, blank: true);
    }
    if (milliseconds >= 2047.54 && milliseconds <= 2937.9475) {
      final alpha = cseFinaleInterval(milliseconds, 2047.54, 2145.0365) *
          (1 - cseFinaleInterval(milliseconds, 2795.051, 2937.9475));
      final y = motion.scanYAt(milliseconds) + extra;
      final scan = Rect.fromLTWH(34, y, 322, 3);
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(scan.inflate(5), const Radius.circular(7)),
          Paint()
            ..color = colors.accent.withValues(alpha: alpha * .35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        )
        ..drawRRect(
          RRect.fromRectAndRadius(scan, const Radius.circular(2)),
          Paint()..color = colors.accent.withValues(alpha: alpha),
        );
    }
    for (var index = 0; index < motion.questions.length; index++) {
      final frame = motion.dotAt(
        index,
        milliseconds,
        verticalOffset: extra,
        gatheringCenter: gather,
      );
      final color = !frame.checked
          ? colors.chevron
          : switch (motion.questions[index].outcome) {
              MockFinaleOutcome.correct => colors.accent,
              MockFinaleOutcome.wrong => colors.wrongText,
              MockFinaleOutcome.blank => colors.chevron,
            };
      if (frame.opacity > 0) {
        canvas.drawCircle(
          frame.position + const Offset(4.5, 4.5),
          4.5 * frame.scale,
          Paint()..color = color.withValues(alpha: frame.opacity.clamp(0, 1)),
        );
      }
    }
    if (!motion.hasBall) return;
    final glow = sampleCseFinaleEffect(558, milliseconds);
    if (glow.opacity > 0) {
      final center = Offset(195, 230 + gaugeDelta);
      final rect = Rect.fromCircle(center: center, radius: 150 * glow.scaleX);
      canvas.drawOval(
        rect,
        Paint()
          ..shader = RadialGradient(
            radius: math.sqrt2 / 2,
            colors: [
              colors.accent.withValues(alpha: .15 * glow.opacity),
              colors.accent.withValues(alpha: 0),
            ],
            stops: const [
              0,
              .65,
            ],
          ).createShader(rect),
      );
    }
    for (final pair in const [(541, 542), (543, 544), (545, 546)]) {
      final box = cseEffectBoxes[pair.$1]!;
      final position = sampleCseFinaleEffect(pair.$1, milliseconds);
      final alpha = sampleCseFinaleEffect(pair.$2, milliseconds).opacity;
      if (alpha > 0) {
        canvas.drawCircle(
          Offset(
            box.left + box.width / 2 + position.x,
            box.top + box.height / 2 + position.y + gaugeDelta,
          ),
          box.width / 2,
          Paint()..color = colors.accent.withValues(alpha: alpha),
        );
      }
    }
    final position = sampleCseFinaleEffect(539, milliseconds);
    final shape = sampleCseFinaleEffect(540, milliseconds);
    if (shape.opacity > 0) {
      canvas
        ..save()
        ..translate(gather.dx + position.x, gather.dy + position.y)
        ..rotate(shape.rotation * math.pi / 180)
        ..scale(shape.scaleX, shape.scaleY)
        ..drawCircle(
          Offset.zero,
          23,
          Paint()..color = colors.accent.withValues(alpha: shape.opacity),
        )
        ..restore();
    }
    final ripple = sampleCseFinaleEffect(547, milliseconds);
    if (ripple.opacity > 0) {
      canvas.drawCircle(
        Offset(87, 230 + gaugeDelta),
        58.5 * ripple.scaleX,
        Paint()
          ..color = colors.accent.withValues(alpha: ripple.opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * ripple.scaleX,
      );
    }
    for (var id = 548; id <= 557; id++) {
      final box = cseEffectBoxes[id];
      if (box == null) continue;
      final frame = sampleCseFinaleEffect(id, milliseconds);
      if (frame.opacity > 0) {
        canvas.drawCircle(
          Offset(
            box.left + box.width / 2 + frame.x,
            box.top + box.height / 2 + frame.y + gaugeDelta,
          ),
          box.width / 2 * frame.scaleX,
          Paint()..color = colors.accent.withValues(alpha: frame.opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CseScene oldDelegate) => true;
}
