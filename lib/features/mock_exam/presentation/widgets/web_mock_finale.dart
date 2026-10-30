import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_finale_tracks.dart';

//  The desktop submission sequence plays once. The board's loop reset is a
// demo.
class WebMockFinale extends StatefulWidget {
  const WebMockFinale({
    required this.input,
    required this.name,
    required this.resultsBuilder,
    super.key,
  });
  final MockFinaleInput input;
  final String name;
  final Widget Function(BuildContext, Animation<double>) resultsBuilder;

  @override
  State<WebMockFinale> createState() => _WebMockFinaleState();
}

class _WebMockFinaleState extends State<WebMockFinale>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 11350),
  );
  late final _clock = _controller.drive(Tween<double>(begin: 0, end: 11350));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            AbsorbPointer(
              absorbing: _clock.value < 6450,
              child: Transform.translate(
                offset: sampleWebFinale('k-shake', _clock.value).offset,
                child: widget.resultsBuilder(context, _clock),
              ),
            ),
            if (_clock.value < 4900)
              IgnorePointer(
                child: CustomPaint(
                  key: const ValueKey('web-finale-scene'),
                  painter: _WebFinaleScene(
                    input: widget.input,
                    name: widget.name,
                    milliseconds: _clock.value,
                    tokens: context.webTokens,
                  ),
                ),
              ),
          ],
        ),
      );
}

class _WebFinaleScene extends CustomPainter {
  _WebFinaleScene({
    required this.input,
    required this.name,
    required this.milliseconds,
    required this.tokens,
  });
  final MockFinaleInput input;
  final String name;
  final double milliseconds;
  final WebTokens tokens;

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    double size,
    double opacity, {
    bool strong = false,
    bool centered = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: tokens.style(
          size,
          weight: strong ? FontWeight.w700 : FontWeight.w400,
          color: tokens.colors.label.withValues(alpha: opacity.clamp(0, 1)),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 1200);
    painter.paint(canvas, at - Offset(centered ? painter.width / 2 : 0, 0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = tokens.colors;
    canvas
      ..save()
      ..translate((size.width - 1440) / 2, 0);
    final time = milliseconds;
    final first = sampleWebFinale('k-t1', time);
    final checking = sampleWebFinale('k-t2', time);
    _text(
      canvas,
      input.reason == MockSubmitReason.timeUp
          ? 'Time is up.'
          : 'Mock submitted',
      const Offset(720, 294) + first.offset,
      38,
      first.opacity,
      strong: true,
      centered: true,
    );
    _text(
      canvas,
      'Checking your answers',
      const Offset(720, 294) + checking.offset,
      38,
      checking.opacity,
      strong: true,
      centered: true,
    );
    _text(
      canvas,
      name,
      const Offset(720, 342) + checking.offset,
      17,
      checking.opacity,
      centered: true,
    );
    final reflow = const Cubic(.65, 0, .35, 1)
        .transform(((time - 820.0375) / (1460.0005 - 820.0375)).clamp(0, 1));
    final fade = 1 - ((time - 3420) / 200).clamp(0.0, 1.0);
    if (fade > 0) {
      final rect = Rect.lerp(
        const Rect.fromLTWH(717, 404, 450, 377),
        const Rect.fromLTWH(108, 404, 1224, 302),
        reflow,
      )!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(22)),
        Paint()..color = c.surface.withValues(alpha: fade),
      );
    }
    final questions = [for (final part in input.parts) ...part.questions];
    final correct =
        questions.where((q) => q.outcome == MockFinaleOutcome.correct).length;
    var ordinal = 0;
    for (var partIndex = 0; partIndex < input.parts.length; partIndex++) {
      final part = input.parts[partIndex];
      final left = (1440 - input.parts.length * 300 + 48) / 2 + partIndex * 300;
      final label = sampleWebFinale(
        partIndex == input.currentPartIndex ? 'k-gls' : 'k-gl',
        time,
      );
      _text(
        canvas,
        part.name,
        Offset(left, 440),
        14,
        label.opacity,
        strong: true,
      );
      for (var i = 0; i < part.questions.length; i++) {
        final q = part.questions[i];
        final row = i ~/ 10;
        final target = Offset(left + i % 10 * 26 + 9, 479 + row * 26);
        final start = Offset(753 + i % 10 * 39 + 13.5, 479 + row * 39);
        final base = partIndex == input.currentPartIndex
            ? Offset.lerp(start, target, reflow)!
            : target;
        final pop = sampleWebFinale('k-pop', time - (1620 + row * 35));
        var position = base;
        var sx =
            partIndex == input.currentPartIndex ? 1.5 - .5 * reflow : pop.sx;
        var sy = sx;
        var opacity = partIndex == input.currentPartIndex ? 1.0 : pop.opacity;
        var rotation = 0.0;
        if (q.outcome == MockFinaleOutcome.correct) {
          final index =
              correct <= 1 ? 0 : (ordinal * 170 / (correct - 1)).round();
          ordinal++;
          final flight = sampleWebFinale('kd$index', time);
          final end = sampleWebFinale('kd$index', 4500).offset;
          final travel = ((time - 3200) / 800).clamp(0.0, 1.0);
          position +=
              flight.offset + (const Offset(720, 555) - base - end) * travel;
          sx *= flight.sx;
          sy *= flight.sy;
          rotation = flight.rotation;
          opacity *= flight.opacity;
        } else {
          opacity *= sampleWebFinale('k-wfade', time).opacity;
        }
        final scanTime = 2150 + row * 90;
        final scanned = ((time - scanTime) / 60).clamp(0.0, 1.0);
        final color = q.outcome == MockFinaleOutcome.correct
            ? Color.lerp(tokens.strongDivider, c.accent, scanned)!
            : tokens.strongDivider;
        canvas
          ..save()
          ..translate(position.dx, position.dy)
          ..rotate(rotation * math.pi / 180)
          ..scale(sx, sy)
          ..drawCircle(
            Offset.zero,
            9,
            Paint()
              ..color = color.withValues(alpha: opacity.clamp(0, 1))
              ..style = q.outcome == MockFinaleOutcome.blank
                  ? PaintingStyle.stroke
                  : PaintingStyle.fill
              ..strokeWidth = 1.5,
          )
          ..restore();
      }
    }
    final scan = sampleWebFinale('k-scan', time);
    if (scan.opacity > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(126, 470 + scan.offset.dy, 1188, 3),
          const Radius.circular(2),
        ),
        Paint()..color = c.accent.withValues(alpha: scan.opacity),
      );
    }
    if (correct > 0) {
      // The desktop gauge starts at x=24 of its 300px box, at y=146.
      const ringStart =
          Offset((1440 - 1040) / 2 + 24 + (1040 * 10 / 23 - 300) / 2 + 24, 357);
      for (final track in ['k-gh3', 'k-gh2', 'k-gh1', 'k-orb']) {
        final ball = sampleWebFinale(
          track,
          time,
          target: ringStart - const Offset(720, 555),
        );
        canvas
          ..save()
          ..translate(720 + ball.offset.dx, 555 + ball.offset.dy)
          ..scale(ball.sx, ball.sy)
          ..drawCircle(
            Offset.zero,
            28,
            Paint()
              ..color = c.accent.withValues(alpha: ball.opacity.clamp(0, 1)),
          )
          ..restore();
      }
      final burst = sampleWebFinale('k-bring', time);
      canvas.drawCircle(
        ringStart,
        60 * burst.sx,
        Paint()
          ..color = c.accent.withValues(alpha: burst.opacity.clamp(0, 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6;
        final spark = sampleWebFinale(
          'k-spk',
          time,
          target: Offset(math.cos(angle) * 65, math.sin(angle) * 65),
        );
        canvas.drawCircle(
          ringStart + spark.offset,
          3 * spark.sx,
          Paint()
            ..color = c.accent.withValues(alpha: spark.opacity.clamp(0, 1)),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WebFinaleScene old) =>
      old.milliseconds != milliseconds || old.tokens != tokens;
}

/// Uses the same submission clock for each part of the live results page.
class WebFinaleEffect extends StatelessWidget {
  const WebFinaleEffect({
    required this.child,
    required this.track,
    required this.milliseconds,
    super.key,
  });
  final Widget child;
  final String track;
  final double? milliseconds;

  @override
  Widget build(BuildContext context) {
    final time = milliseconds;
    if (time == null) return child;
    final frame = sampleWebFinale(track, time);
    return IgnorePointer(
      ignoring: frame.opacity < 1,
      child: Opacity(
        opacity: frame.opacity.clamp(0, 1),
        child: Transform.translate(
          offset: frame.offset,
          child: Transform.scale(scale: frame.sx, child: child),
        ),
      ),
    );
  }
}
