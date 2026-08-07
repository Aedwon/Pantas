import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A row of meshed gears, with an arrow on the first one.
///
/// The spec:
///
/// ```yaml
///     figureSpec:
///       kind: gear-train
///       gears: 3
///       firstTurns: clockwise
/// ```
///
/// `gears` is how many sit in the row, two to eight. `firstTurns` is
/// `clockwise` or `counter-clockwise` and only the first gear is marked,
/// because working out the rest is the question.
///
/// An optional `teeth` list sizes them relative to each other, for the
/// questions that turn on one gear being bigger than another:
///
/// ```yaml
///       teeth: [10, 30]
/// ```
///
/// **The tooth counts are drawn as sizes, never printed.** The stem states
/// them, and a number on a drawing this project did not measure is a figure
/// it must not print.
class GearTrainFigure extends StatelessWidget {
  const GearTrainFigure({
    required this.gears,
    required this.firstTurnsClockwise,
    this.teeth,
    super.key,
  });

  static const kind = 'gear-train';

  final int gears;
  final bool firstTurnsClockwise;

  /// Relative sizes. Null draws them all the same.
  final List<int>? teeth;

  /// Null when the spec cannot be read. The caller draws the missing box.
  static GearTrainFigure? fromSpec(Map<String, Object?> spec) {
    final count = spec['gears'];
    final turns = spec['firstTurns'];
    if (count is! int || count < 2 || count > 8) return null;
    if (turns is! String) return null;
    final clockwise = switch (turns) {
      'clockwise' => true,
      'counter-clockwise' => false,
      _ => null,
    };
    if (clockwise == null) return null;

    final rawTeeth = spec['teeth'];
    List<int>? teeth;
    if (rawTeeth != null) {
      if (rawTeeth is! List || rawTeeth.length != count) return null;
      teeth = <int>[];
      for (final value in rawTeeth) {
        if (value is! int || value < 4 || value > 200) return null;
        teeth.add(value);
      }
    }

    return GearTrainFigure(
      gears: count,
      firstTurnsClockwise: clockwise,
      teeth: teeth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A row of $gears gears, each meshing with the next. The first '
          'turns ${firstTurnsClockwise ? 'clockwise' : 'counter-clockwise'}.',
      child: SizedBox(
        height: 96,
        child: CustomPaint(
          painter: _GearTrainPainter(
            gears: gears,
            firstTurnsClockwise: firstTurnsClockwise,
            teeth: teeth,
            ink: colors.ink,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GearTrainPainter extends CustomPainter {
  _GearTrainPainter({
    required this.gears,
    required this.firstTurnsClockwise,
    required this.ink,
    this.teeth,
  });

  final int gears;
  final bool firstTurnsClockwise;
  final List<int>? teeth;
  final Color ink;

  static const _teeth = 12;

  @override
  void paint(Canvas canvas, Size size) {
    // Gears touch, so the spacing is twice the radius less one tooth's
    // depth. Everything is derived from the width so the row fits whatever
    // it is given.
    // Relative sizes come from the tooth counts when the question turns on
    // one gear being bigger. Otherwise every gear is the same.
    final counts = teeth ?? List<int>.filled(gears, 1);
    final largest = counts.reduce(math.max).toDouble();
    final scales = [for (final c in counts) c / largest];

    final unit = math.min(
      size.height / 2 - 6,
      size.width / (scales.fold<double>(0, (a, b) => a + b) * 1.9 + 0.4),
    );
    if (unit <= 4) return;

    final radii = [for (final s in scales) math.max<double>(unit * s, 8)];
    var totalWidth = radii.first + radii.last;
    for (var i = 0; i < gears - 1; i++) {
      totalWidth += radii[i] + radii[i + 1] - unit * 0.16;
    }

    var cx = (size.width - totalWidth) / 2 + radii.first;
    final cy = size.height / 2;

    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;

    for (var i = 0; i < gears; i++) {
      final radius = radii[i];
      _drawGear(canvas, Offset(cx, cy), radius, radius * 0.16, hairline);
      if (i == 0) {
        _drawTurnArrow(canvas, Offset(cx, cy), radius * 0.52, hairline);
      }
      if (i < gears - 1) {
        // Meshed, so the centres sit one tooth's depth closer than the two
        // radii would put them.
        cx += radius + radii[i + 1] - unit * 0.16;
      }
    }
  }

  void _drawGear(
    Canvas canvas,
    Offset centre,
    double radius,
    double toothDepth,
    Paint paint,
  ) {
    final path = Path();
    final inner = radius - toothDepth;
    // Alternate between the tooth radius and the root radius. Two points per
    // tooth gives the square-topped look a printed diagram has.
    const steps = _teeth * 4;
    for (var i = 0; i <= steps; i++) {
      final angle = i * 2 * math.pi / steps;
      final onTooth = (i ~/ 2).isEven;
      final r = onTooth ? radius : inner;
      final point = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    // The hub, so a gear reads as a wheel rather than as a star.
    canvas
      ..drawPath(path, paint)
      ..drawCircle(centre, radius * 0.22, paint);
  }

  /// An arc with a head, drawn inside the first gear only.
  void _drawTurnArrow(
    Canvas canvas,
    Offset centre,
    double radius,
    Paint paint,
  ) {
    const sweep = math.pi * 1.25;
    final start = firstTurnsClockwise ? -math.pi * 0.75 : math.pi * 0.75;
    final direction = firstTurnsClockwise ? 1.0 : -1.0;

    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      start,
      sweep * direction,
      false,
      paint,
    );

    final endAngle = start + sweep * direction;
    final tip = centre +
        Offset(math.cos(endAngle) * radius, math.sin(endAngle) * radius);
    // The head points along the tangent at the tip, which is the direction
    // the gear is turning.
    final quarter = firstTurnsClockwise ? math.pi / 2 : -math.pi / 2;
    final tangent = endAngle + quarter;
    final head = radius * 0.42;
    for (final spread in [2.6, -2.6]) {
      canvas.drawLine(
        tip,
        tip +
            Offset(
              math.cos(tangent + spread) * head,
              math.sin(tangent + spread) * head,
            ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GearTrainPainter old) =>
      old.gears != gears ||
      old.firstTurnsClockwise != firstTurnsClockwise ||
      old.ink != ink;
}
