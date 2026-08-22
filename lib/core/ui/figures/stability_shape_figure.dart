import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// One or two shapes standing on the ground, with the centre of gravity
/// marked and a plumb line dropped from it.
///
/// ```yaml
///     figureSpec:
///       kind: stability-shape
///       shapes:
///         - form: pyramid
///           baseWidth: 3
///           height: 1
///         - form: pyramid
///           baseWidth: 1
///           height: 3
///       tilt: 0
/// ```
///
/// `form` is `pyramid` or `box`. `baseWidth` and `height` are proportions
/// against each other, never measurements. `tilt` leans every shape by that
/// many degrees, for the questions about tipping.
///
/// **The plumb line is the point of the whole family**: a shape stays up
/// while that line lands inside its base.
class StabilityShapeFigure extends StatelessWidget {
  const StabilityShapeFigure({
    required this.shapes,
    required this.tiltDegrees,
    super.key,
  });

  static const kind = 'stability-shape';

  final List<StabilityShape> shapes;
  final double tiltDegrees;

  /// Null when the spec cannot be read.
  static StabilityShapeFigure? fromSpec(Map<String, Object?> spec) {
    final raw = spec['shapes'];
    if (raw is! List || raw.isEmpty || raw.length > 3) return null;

    final tilt = spec['tilt'] ?? 0;
    if (tilt is! num || tilt < -45 || tilt > 45) return null;

    const forms = {'pyramid', 'box', 'truck', 'person'};
    final shapes = <StabilityShape>[];
    for (final entry in raw) {
      if (entry is! Map) return null;
      final form = entry['form'];
      final width = entry['baseWidth'];
      final height = entry['height'];
      if (form is! String || !forms.contains(form)) return null;
      if (width is! num || width <= 0) return null;
      if (height is! num || height <= 0) return null;
      final shapeTilt = entry['tilt'] ?? tilt;
      if (shapeTilt is! num || shapeTilt < -45 || shapeTilt > 45) return null;
      shapes.add(
        StabilityShape(
          form: form,
          baseWidth: width.toDouble(),
          height: height.toDouble(),
          tiltDegrees: shapeTilt.toDouble(),
        ),
      );
    }
    return StabilityShapeFigure(shapes: shapes, tiltDegrees: tilt.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: shapes.length == 1
          ? 'A shape on the ground with its centre of gravity marked and a '
              'vertical line dropped from it.'
          : '${shapes.length} shapes side by side on the ground, each with '
              'its centre of gravity marked.',
      child: SizedBox(
        height: 140,
        child: CustomPaint(
          painter: _StabilityPainter(
            shapes: shapes,
            tiltDegrees: tiltDegrees,
            ink: colors.ink,
            faint: colors.ruleFaint,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// One shape in the figure.
class StabilityShape {
  const StabilityShape({
    required this.form,
    required this.baseWidth,
    required this.height,
    required this.tiltDegrees,
  });

  final String form;
  final double baseWidth;
  final double height;
  final double tiltDegrees;

  bool get isPyramid => form == 'pyramid';
}

class _StabilityPainter extends CustomPainter {
  _StabilityPainter({
    required this.shapes,
    required this.tiltDegrees,
    required this.ink,
    required this.faint,
  });

  final List<StabilityShape> shapes;
  final double tiltDegrees;
  final Color ink;
  final Color faint;

  @override
  void paint(Canvas canvas, Size size) {
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;
    final plumb = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = faint;

    final groundY = size.height - 24;
    canvas.drawLine(
      Offset(8, groundY),
      Offset(size.width - 8, groundY),
      hairline,
    );

    final widest =
        shapes.map((s) => s.baseWidth).reduce((a, b) => a > b ? a : b);
    final tallest = shapes.map((s) => s.height).reduce((a, b) => a > b ? a : b);
    final slot = size.width / shapes.length;
    final unitWidth = (slot * 0.55) / widest;
    final unitHeight = (groundY - 22) / tallest;

    for (var i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final cx = slot * (i + 0.5);
      final halfBase = shape.baseWidth * unitWidth / 2;
      final height = shape.height * unitHeight;

      final pivot = Offset(cx + halfBase, groundY);
      final angle = shape.tiltDegrees * 3.1415926535 / 180;
      canvas.save();
      if (angle != 0) {
        canvas
          ..translate(pivot.dx, pivot.dy)
          ..rotate(angle)
          ..translate(-pivot.dx, -pivot.dy);
      }

      final cgY = switch (shape.form) {
        'pyramid' => groundY - height / 3,
        'truck' => groundY - height * 0.48,
        'person' => groundY - height * 0.56,
        _ => groundY - height / 2,
      };
      switch (shape.form) {
        case 'pyramid':
          canvas.drawPath(
            Path()
              ..moveTo(cx - halfBase, groundY)
              ..lineTo(cx, groundY - height)
              ..lineTo(cx + halfBase, groundY)
              ..close(),
            hairline,
          );
        case 'box':
          canvas.drawRect(
            Rect.fromLTRB(
              cx - halfBase,
              groundY - height,
              cx + halfBase,
              groundY,
            ),
            hairline,
          );
        case 'truck':
          _drawTruck(canvas, cx, groundY, halfBase, height, hairline);
        case 'person':
          _drawPerson(canvas, cx, groundY, halfBase, height, hairline);
      }
      canvas.restore();

      final cg = _rotatePoint(Offset(cx, cgY), pivot, angle);
      canvas
        ..drawCircle(cg, 3, hairline)
        ..drawLine(cg, Offset(cg.dx, groundY + 10), plumb);
    }
  }

  void _drawTruck(
    Canvas canvas,
    double cx,
    double groundY,
    double halfBase,
    double height,
    Paint paint,
  ) {
    final wheelY = groundY - 5;
    final bodyTop = groundY - 18;
    canvas
      ..drawRect(
        Rect.fromLTRB(cx - halfBase, bodyTop, cx + halfBase, groundY - 6),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(
          cx - halfBase * 0.55,
          groundY - height,
          cx + halfBase * 0.7,
          bodyTop,
        ),
        paint,
      )
      ..drawCircle(Offset(cx - halfBase * 0.55, wheelY), 5, paint)
      ..drawCircle(Offset(cx + halfBase * 0.55, wheelY), 5, paint);
  }

  void _drawPerson(
    Canvas canvas,
    double cx,
    double groundY,
    double halfBase,
    double height,
    Paint paint,
  ) {
    final head = Offset(cx, groundY - height + 7);
    final shouldersY = groundY - height * 0.68;
    final hipsY = groundY - height * 0.35;
    canvas
      ..drawCircle(head, 7, paint)
      ..drawLine(Offset(cx, head.dy + 7), Offset(cx, hipsY), paint)
      ..drawLine(
        Offset(cx - halfBase * 0.45, shouldersY),
        Offset(cx + halfBase * 0.45, shouldersY),
        paint,
      )
      ..drawLine(Offset(cx, hipsY), Offset(cx - halfBase, groundY), paint)
      ..drawLine(Offset(cx, hipsY), Offset(cx + halfBase, groundY), paint)
      ..drawLine(
        Offset(cx - halfBase - 5, groundY),
        Offset(cx - halfBase + 5, groundY),
        paint,
      )
      ..drawLine(
        Offset(cx + halfBase - 5, groundY),
        Offset(cx + halfBase + 5, groundY),
        paint,
      );
  }

  Offset _rotatePoint(Offset point, Offset pivot, double angle) {
    if (angle == 0) return point;
    final translated = point - pivot;
    final cosAngle = math.cos(angle);
    final sinAngle = math.sin(angle);
    return pivot +
        Offset(
          translated.dx * cosAngle - translated.dy * sinAngle,
          translated.dx * sinAngle + translated.dy * cosAngle,
        );
  }

  @override
  bool shouldRepaint(_StabilityPainter old) =>
      old.tiltDegrees != tiltDegrees ||
      old.shapes != shapes ||
      old.ink != ink ||
      old.faint != faint;
}
