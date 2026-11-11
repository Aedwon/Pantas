import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The pause hourglass, drawn as MK_PauseA draws it (viewBox 100 by 132).
///
/// The sand on top is as much as there is time left in the part. The two
/// chambers share 52 units of sand between them, so the top holds 52 times
/// the fraction left and the bottom holds the rest.
class MockHourglass extends StatelessWidget {
  const MockHourglass({
    required this.remainingFraction,
    required this.sandColor,
    required this.outlineColor,
    this.size = const Size(width, height),
    this.streamOffset = 0,
    this.streamOpacity = 0,
    this.streamCut = 0,
    super.key,
  });

  /// Time left in the part over the part's length, from 0 to 1.
  final double remainingFraction;
  final Color sandColor;
  final Color outlineColor;
  final Size size;

  /// The board's stroke-dashoffset for the falling grains.
  final double streamOffset;
  final double streamOpacity;

  /// Fraction of the stream cleared from the neck as the last grains fall.
  final double streamCut;

  static const width = 76.0;
  static const height = 100.0;

  @override
  Widget build(BuildContext context) => CustomPaint(
        key: const ValueKey('pause-hourglass'),
        size: size,
        painter: HourglassPainter(
          remainingFraction: remainingFraction,
          sandColor: sandColor,
          outlineColor: outlineColor,
          streamOffset: streamOffset,
          streamOpacity: streamOpacity,
          streamCut: streamCut,
        ),
      );
}

class HourglassPainter extends CustomPainter {
  HourglassPainter({
    required double remainingFraction,
    required this.sandColor,
    required this.outlineColor,
    this.streamOffset = 0,
    this.streamOpacity = 0,
    this.streamCut = 0,
  }) : remainingFraction = remainingFraction.clamp(0.0, 1.0);

  final double remainingFraction;
  final Color sandColor;
  final Color outlineColor;
  final double streamOffset;
  final double streamOpacity;

  /// Fraction of the stream cleared from the neck as the last grains fall.
  final double streamCut;

  static const sandSpan = 52.0;
  static const _dash = 1.6;
  static const _gap = 4.0;

  /// Height of the sand in the top chamber, in viewBox units.
  double get topSandHeight => sandSpan * remainingFraction;

  /// Height of the sand in the bottom chamber, in viewBox units.
  double get bottomSandHeight => sandSpan * (1 - remainingFraction);

  static Path get _top => Path()
    ..moveTo(22, 12)
    ..cubicTo(22, 38, 44, 52, 48.5, 66)
    ..lineTo(51.5, 66)
    ..cubicTo(56, 52, 78, 38, 78, 12)
    ..close();

  static Path get _bottom => Path()
    ..moveTo(48.5, 66)
    ..cubicTo(44, 80, 22, 94, 22, 120)
    ..lineTo(78, 120)
    ..cubicTo(78, 94, 56, 80, 51.5, 66)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 100, size.height / 132);
    canvas
      ..save()
      ..translate((size.width - 100 * scale) / 2, 0)
      ..scale(scale);

    final sand = Paint()..color = sandColor;
    canvas
      ..save()
      ..clipPath(_top)
      ..drawRect(Rect.fromLTWH(0, 66 - topSandHeight, 100, topSandHeight), sand)
      ..restore()
      ..save()
      ..clipPath(_bottom)
      ..drawRect(
        Rect.fromLTWH(0, 120 - bottomSandHeight, 100, bottomSandHeight),
        sand,
      )
      ..restore();

    if (streamOpacity > 0) _paintStream(canvas);

    final outline = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.6;
    canvas
      ..drawPath(_top, outline)
      ..drawPath(_bottom, outline)
      ..drawPath(
        Path()
          ..moveTo(12, 7)
          ..lineTo(88, 7)
          ..moveTo(12, 125)
          ..lineTo(88, 125),
        outline..strokeWidth = 4.5,
      )
      ..restore();
  }

  /// A dotted line from the neck to the pile, 1.6 on and 4 off. CSS shifts
  /// the pattern by the negative of the dash offset along the line.
  void _paintStream(Canvas canvas) {
    final line = Path()
      ..moveTo(50, 66 + (54 - bottomSandHeight) * streamCut)
      ..lineTo(50, 120 - bottomSandHeight);
    final paint = Paint()
      ..color = sandColor.withValues(alpha: streamOpacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;
    const period = _dash + _gap;
    for (final metric in line.computeMetrics()) {
      var start = (-streamOffset) % period - period;
      while (start < metric.length) {
        final from = math.max<double>(start, 0);
        final to = math.min(start + _dash, metric.length);
        if (to > from) canvas.drawPath(metric.extractPath(from, to), paint);
        start += period;
      }
    }
  }

  @override
  bool shouldRepaint(HourglassPainter old) =>
      old.remainingFraction != remainingFraction ||
      old.sandColor != sandColor ||
      old.outlineColor != outlineColor ||
      old.streamOffset != streamOffset ||
      old.streamOpacity != streamOpacity ||
      old.streamCut != streamCut;
}
