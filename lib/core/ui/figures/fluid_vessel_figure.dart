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
    final styles = context.type;
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
            ink: colors.label,
            mark: colors.secondaryLabel,
            labelStyle: styles.subhead.copyWith(color: colors.secondaryLabel),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Where the lines of a set of joined vessels go.
@visibleForTesting
abstract final class FluidVesselGeometry {
  /// The walls, the tube ceilings between neighboring arms, the floor and the
  /// water level in each arm.
  ///
  /// Only the two outer walls reach the floor. Each inner wall stops at the
  /// tube's ceiling, which is what makes the arms one connected tube and not
  /// separate boxes. The floor runs from the first outer wall to the last.
  static ({
    List<(Offset, Offset)> walls,
    List<(Offset, Offset)> ceilings,
    (Offset, Offset) floor,
    List<(Offset, Offset)> levels,
  }) connected(Size size, int columns) {
    const top = 16.0;
    final bottom = size.height - 22;
    final tubeTop = bottom - 14;
    const levelY = top + 18;
    final slot = size.width / columns;
    final halves = [
      for (var i = 0; i < columns; i++) slot * (0.10 + 0.06 * (i % 3)),
    ];
    final centres = [for (var i = 0; i < columns; i++) slot * (i + 0.5)];

    final walls = <(Offset, Offset)>[];
    final ceilings = <(Offset, Offset)>[];
    final levels = <(Offset, Offset)>[];
    for (var i = 0; i < columns; i++) {
      final left = centres[i] - halves[i];
      final right = centres[i] + halves[i];
      walls
        ..add((Offset(left, top), Offset(left, i == 0 ? bottom : tubeTop)))
        ..add(
          (
            Offset(right, top),
            Offset(right, i == columns - 1 ? bottom : tubeTop),
          ),
        );
      levels.add((Offset(left, levelY), Offset(right, levelY)));
      if (i < columns - 1) {
        ceilings.add(
          (
            Offset(right, tubeTop),
            Offset(centres[i + 1] - halves[i + 1], tubeTop),
          ),
        );
      }
    }
    return (
      walls: walls,
      ceilings: ceilings,
      floor: (
        Offset(centres.first - halves.first, bottom),
        Offset(centres.last + halves.last, bottom),
      ),
      levels: levels,
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
    required this.mark,
    required this.labelStyle,
  });

  final String vessel;
  final List<String> points;
  final List<double> widths;
  final int columns;
  final Color ink;

  /// The water line and the flow arrow: marks the student must read, so
  /// they are not drawn in the faintest fill.
  final Color mark;
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
      ..color = mark;

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
    final layout = FluidVesselGeometry.connected(size, columns);
    for (final (from, to) in [
      ...layout.walls,
      ...layout.ceilings,
      layout.floor,
    ]) {
      canvas.drawLine(from, to, ink);
    }
    for (final (from, to) in layout.levels) {
      canvas.drawLine(from, to, water);
    }
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
      old.ink != ink ||
      old.mark != mark;
}
