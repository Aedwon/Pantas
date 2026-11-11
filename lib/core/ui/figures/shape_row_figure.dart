import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Height of the drawing. The design system sets no height for diagrams.
const double _figureHeight = 110;

/// A row of shapes, for the odd-one-out questions.
///
/// ```yaml
///     figureSpec:
///       kind: shape-row
///       shapes:
///         - form: square
///         - form: rectangle
///         - form: rhombus
///         - form: triangle
/// ```
///
/// Each entry may carry `dots` (small filled dots inside the shape) and
/// `lines`, which cuts a circle into regions:
///
/// ```yaml
///         - form: circle
///           lines: 2
///           through: centre    # centre | off
/// ```
///
/// **The odd one out is never marked.** Finding it is the question, and a
/// drawing that gives it away makes the question worthless.
class ShapeRowFigure extends StatelessWidget {
  const ShapeRowFigure({required this.shapes, super.key});

  static const kind = 'shape-row';

  static const forms = {
    'square',
    'rectangle',
    'rhombus',
    'parallelogram',
    'triangle',
    'circle',
    'pentagon',
    'hexagon',
    'blob',
  };

  final List<RowShape> shapes;

  /// Null when the spec cannot be read.
  static ShapeRowFigure? fromSpec(Map<String, Object?> spec) {
    final raw = spec['shapes'];
    if (raw is! List || raw.length < 2 || raw.length > 6) return null;

    final shapes = <RowShape>[];
    for (final entry in raw) {
      if (entry is! Map) return null;
      final form = entry['form'];
      if (form is! String || !forms.contains(form)) return null;

      final dots = entry['dots'] ?? 0;
      if (dots is! int || dots < 0 || dots > 4) return null;

      final lines = entry['lines'] ?? 0;
      if (lines is! int || lines < 0 || lines > 4) return null;

      final through = entry['through'] ?? 'centre';
      if (through is! String || (through != 'centre' && through != 'off')) {
        return null;
      }

      shapes.add(
        RowShape(
          form: form,
          dots: dots,
          lines: lines,
          throughCentre: through == 'centre',
        ),
      );
    }
    return ShapeRowFigure(shapes: shapes);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A row of ${shapes.length} shapes: '
          '${shapes.map((s) => s.form).join(', ')}.',
      child: SizedBox(
        height: _figureHeight,
        child: CustomPaint(
          painter: _ShapeRowPainter(shapes: shapes, ink: colors.label),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// One shape in the row.
class RowShape {
  const RowShape({
    required this.form,
    required this.dots,
    required this.lines,
    required this.throughCentre,
  });

  final String form;
  final int dots;
  final int lines;
  final bool throughCentre;
}

/// Corners of the shapes in a row, shared by the painter and its tests.
@visibleForTesting
abstract final class ShapeRowGeometry {
  /// Top, right, bottom, left: four equal sides that are not a square, so a
  /// rhombus is not mistaken for the square beside it.
  static List<Offset> rhombus(Offset centre, double r) => [
        Offset(centre.dx, centre.dy - r),
        Offset(centre.dx + r * 0.62, centre.dy),
        Offset(centre.dx, centre.dy + r),
        Offset(centre.dx - r * 0.62, centre.dy),
      ];
}

class _ShapeRowPainter extends CustomPainter {
  _ShapeRowPainter({required this.shapes, required this.ink});

  final List<RowShape> shapes;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;
    final filled = Paint()
      ..style = PaintingStyle.fill
      ..color = ink;

    final slot = size.width / shapes.length;
    final radius = math.min(slot * 0.32, size.height * 0.34);
    final cy = size.height / 2;

    for (var i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final centre = Offset(slot * (i + 0.5), cy);
      _drawForm(canvas, shape, centre, radius, stroke);
      _drawDots(canvas, shape, centre, radius, filled);
      _drawLines(canvas, shape, centre, radius, stroke);
    }
  }

  void _drawForm(
    Canvas canvas,
    RowShape shape,
    Offset centre,
    double r,
    Paint paint,
  ) {
    switch (shape.form) {
      case 'circle':
        canvas.drawCircle(centre, r, paint);
      case 'square':
        canvas.drawRect(Rect.fromCircle(center: centre, radius: r), paint);
      case 'rectangle':
        canvas.drawRect(
          Rect.fromCenter(center: centre, width: r * 2.4, height: r * 1.3),
          paint,
        );
      case 'rhombus':
        canvas.drawPath(
          Path()..addPolygon(ShapeRowGeometry.rhombus(centre, r), true),
          paint,
        );
      case 'parallelogram':
        canvas.drawPath(
          Path()
            ..moveTo(centre.dx - r * 0.7, centre.dy - r * 0.65)
            ..lineTo(centre.dx + r, centre.dy - r * 0.65)
            ..lineTo(centre.dx + r * 0.7, centre.dy + r * 0.65)
            ..lineTo(centre.dx - r, centre.dy + r * 0.65)
            ..close(),
          paint,
        );
      case 'triangle':
        canvas.drawPath(_polygon(centre, r, 3, -math.pi / 2), paint);
      case 'pentagon':
        canvas.drawPath(_polygon(centre, r, 5, -math.pi / 2), paint);
      case 'hexagon':
        canvas.drawPath(_polygon(centre, r, 6, 0), paint);
      case 'blob':
        // Deliberately lopsided: this shape exists to have no symmetry. It
        // has one bump and one dent, like the lesson figure.
        canvas.drawPath(_blobPath(centre, r), paint);
    }
  }

  Path _blobPath(Offset centre, double r) {
    final k = r / 32;
    Offset p(double x, double y) =>
        Offset(centre.dx + (x - 315) * k, centre.dy + (y - 110) * k);
    final a = p(298, 83);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(
        p(316, 78).dx,
        p(316, 78).dy,
        p(337, 86).dx,
        p(337, 86).dy,
        p(342, 104).dx,
        p(342, 104).dy,
      )
      ..cubicTo(
        p(345, 118).dx,
        p(345, 118).dy,
        p(334, 124).dx,
        p(334, 124).dy,
        p(330, 131).dx,
        p(330, 131).dy,
      )
      ..cubicTo(
        p(326, 140).dx,
        p(326, 140).dy,
        p(318, 134).dx,
        p(318, 134).dy,
        p(311, 139).dx,
        p(311, 139).dy,
      )
      ..cubicTo(
        p(298, 143).dx,
        p(298, 143).dy,
        p(287, 132).dx,
        p(287, 132).dy,
        p(286, 118).dx,
        p(286, 118).dy,
      )
      ..cubicTo(
        p(285, 108).dx,
        p(285, 108).dy,
        p(290, 100).dx,
        p(290, 100).dy,
        p(291, 94).dx,
        p(291, 94).dy,
      )
      ..cubicTo(
        p(292, 88).dx,
        p(292, 88).dy,
        p(294, 85).dx,
        p(294, 85).dy,
        a.dx,
        a.dy,
      )
      ..close();
  }

  Path _polygon(Offset centre, double r, int sides, double startAngle) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = startAngle + i * 2 * math.pi / sides;
      final point = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  void _drawDots(
    Canvas canvas,
    RowShape shape,
    Offset centre,
    double r,
    Paint paint,
  ) {
    if (shape.dots == 0) return;
    final spread = r * 0.45;
    final first = centre.dx - spread * (shape.dots - 1) / 2;
    for (var i = 0; i < shape.dots; i++) {
      canvas.drawCircle(Offset(first + spread * i, centre.dy), 2.5, paint);
    }
  }

  void _drawLines(
    Canvas canvas,
    RowShape shape,
    Offset centre,
    double r,
    Paint paint,
  ) {
    if (shape.lines == 0) return;
    // A line stops at the outline. An off-centre cut would otherwise run
    // out past the edge of the circle.
    canvas.save();
    if (shape.form == 'circle') {
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: centre, radius: r)),
      );
    }
    for (var i = 0; i < shape.lines; i++) {
      final angle = i * math.pi / shape.lines;
      // An off-centre cut makes uneven regions, which is what those
      // questions turn on.
      final shift = shape.throughCentre ? Offset.zero : Offset(0, r * 0.35);
      final from =
          centre + shift + Offset(math.cos(angle) * r, math.sin(angle) * r);
      final to =
          centre + shift - Offset(math.cos(angle) * r, math.sin(angle) * r);
      canvas.drawLine(from, to, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShapeRowPainter old) =>
      old.ink != ink || old.shapes != shapes;
}
