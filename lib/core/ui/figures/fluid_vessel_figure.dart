import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Water in a vessel, or water flowing through a pipe that changes width.
///
/// Two shapes, because the family asks two questions.
///
/// ```yaml
///     figureSpec:
///       kind: fluid-vessel
///       vessel: column        # column | connected | pipe
///       points: [A, B]        # marked depths, top to bottom
///       widths: [3, 1, 3]     # pipe only: each section's width
///       columns: 3            # connected only: how many vessels
/// ```
///
/// **A marked point is labelled with the letter the stem uses**, which is
/// safe: those letters name places in the picture, not answer choices, and
/// the reshuffle never touches them.
class FluidVesselFigure extends StatelessWidget {
  const FluidVesselFigure({
    required this.vessel,
    required this.points,
    required this.widths,
    required this.columns,
    super.key,
  });

  static const kind = 'fluid-vessel';

  final String vessel;
  final List<String> points;
  final List<double> widths;
  final int columns;

  /// Null when the spec cannot be read.
  static FluidVesselFigure? fromSpec(Map<String, Object?> spec) {
    final vessel = spec['vessel'];
    if (vessel is! String) return null;
    if (vessel != 'column' && vessel != 'connected' && vessel != 'pipe') {
      return null;
    }

    final points = <String>[];
    final rawPoints = spec['points'];
    if (rawPoints != null) {
      if (rawPoints is! List || rawPoints.length > 4) return null;
      for (final p in rawPoints) {
        if (p is! String || p.isEmpty || p.length > 2) return null;
        points.add(p);
      }
    }

    final widths = <double>[];
    final rawWidths = spec['widths'];
    if (rawWidths != null) {
      if (rawWidths is! List || rawWidths.length < 2 || rawWidths.length > 4) {
        return null;
      }
      for (final w in rawWidths) {
        if (w is! num || w <= 0) return null;
        widths.add(w.toDouble());
      }
    }
    if (vessel == 'pipe' && widths.isEmpty) return null;

    final columns = spec['columns'] ?? 3;
    if (columns is! int || columns < 2 || columns > 4) return null;

    return FluidVesselFigure(
      vessel: vessel,
      points: points,
      widths: widths,
      columns: columns,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Semantics(
      label: switch (vessel) {
        'pipe' => 'A pipe that changes width along its length, with water '
            'flowing through it.',
        'connected' => '$columns open vessels of different widths, joined at '
            'the bottom, with water settled in them.',
        _ => 'A container of water with points marked at different depths.',
      },
      child: SizedBox(
        height: 140,
        child: CustomPaint(
          painter: _FluidPainter(
            vessel: vessel,
            points: points,
            widths: widths,
            columns: columns,
            ink: colors.ink,
            faint: colors.ruleFaint,
            labelStyle: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _FluidPainter extends CustomPainter {
  _FluidPainter({
    required this.vessel,
    required this.points,
    required this.widths,
    required this.columns,
    required this.ink,
    required this.faint,
    required this.labelStyle,
  });

  final String vessel;
  final List<String> points;
  final List<double> widths;
  final int columns;
  final Color ink;
  final Color faint;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;
    final water = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = faint;

    switch (vessel) {
      case 'pipe':
        _paintPipe(canvas, size, hairline, water);
      case 'connected':
        _paintConnected(canvas, size, hairline, water);
      default:
        _paintColumn(canvas, size, hairline, water);
    }
  }

  /// A tank, a water line near the top, and the marked depths down its side.
  void _paintColumn(Canvas canvas, Size size, Paint ink, Paint water) {
    const margin = 40.0;
    const left = margin;
    final right = size.width - margin;
    const top = 16.0;
    final bottom = size.height - 16;

    canvas
      ..drawLine(const Offset(left, top), Offset(left, bottom), ink)
      ..drawLine(Offset(right, top), Offset(right, bottom), ink)
      ..drawLine(Offset(left, bottom), Offset(right, bottom), ink)
      ..drawLine(const Offset(left, top + 10), Offset(right, top + 10), water);

    if (points.isEmpty) return;
    // Spread the marks between just under the surface and just off the floor.
    const first = top + 22;
    final last = bottom - 14;
    final step =
        points.length == 1 ? 0.0 : (last - first) / (points.length - 1);
    for (var i = 0; i < points.length; i++) {
      final y = first + step * i;
      final x = (left + right) / 2;
      canvas.drawCircle(Offset(x, y), 3, ink);
      _label(canvas, points[i], x + 10, y - 8);
    }
  }

  /// Vessels of different widths joined at the bottom. The water finds the
  /// same level in all of them, which is the whole question.
  void _paintConnected(Canvas canvas, Size size, Paint ink, Paint water) {
    const top = 16.0;
    final bottom = size.height - 22;
    final slot = size.width / columns;
    const levelY = top + 18;

    for (var i = 0; i < columns; i++) {
      // Deliberately different widths, so "different shapes" is visible.
      final half = slot * (0.10 + 0.06 * (i % 3));
      final cx = slot * (i + 0.5);
      canvas
        ..drawLine(Offset(cx - half, top), Offset(cx - half, bottom), ink)
        ..drawLine(Offset(cx + half, top), Offset(cx + half, bottom), ink)
        ..drawLine(Offset(cx - half, levelY), Offset(cx + half, levelY), water);
    }
    // The tube along the bottom that joins them.
    canvas.drawLine(
      Offset(slot * 0.5 - slot * 0.10, bottom),
      Offset(slot * (columns - 0.5) + slot * 0.10, bottom),
      ink,
    );
  }

  /// A pipe whose sections change width, drawn as its two walls.
  void _paintPipe(Canvas canvas, Size size, Paint ink, Paint water) {
    final widest = widths.reduce((a, b) => a > b ? a : b);
    final centreY = size.height / 2;
    final maxHalf = (size.height / 2) - 20;
    final sectionWidth = (size.width - 24) / widths.length;

    final topWall = Path();
    final bottomWall = Path();
    for (var i = 0; i < widths.length; i++) {
      final half = maxHalf * (widths[i] / widest);
      final x0 = 12 + sectionWidth * i;
      final x1 = x0 + sectionWidth;
      if (i == 0) {
        topWall.moveTo(x0, centreY - half);
        bottomWall.moveTo(x0, centreY + half);
      } else {
        topWall.lineTo(x0, centreY - half);
        bottomWall.lineTo(x0, centreY + half);
      }
      topWall.lineTo(x1, centreY - half);
      bottomWall.lineTo(x1, centreY + half);
    }
    canvas
      ..drawPath(topWall, ink)
      ..drawPath(bottomWall, ink)
      // An arrow along the middle, so the direction of flow is not a guess.
      ..drawLine(Offset(20, centreY), Offset(size.width - 20, centreY), water)
      ..drawLine(
        Offset(size.width - 20, centreY),
        Offset(size.width - 28, centreY - 5),
        water,
      )
      ..drawLine(
        Offset(size.width - 20, centreY),
        Offset(size.width - 28, centreY + 5),
        water,
      );
  }

  void _label(Canvas canvas, String text, double x, double y) {
    TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(_FluidPainter old) =>
      old.vessel != vessel ||
      old.points.length != points.length ||
      old.widths.length != widths.length ||
      old.columns != columns ||
      old.ink != ink;
}
