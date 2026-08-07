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

    final shapes = <StabilityShape>[];
    for (final entry in raw) {
      if (entry is! Map) return null;
      final form = entry['form'];
      final width = entry['baseWidth'];
      final height = entry['height'];
      if (form is! String || (form != 'pyramid' && form != 'box')) return null;
      if (width is! num || width <= 0) return null;
      if (height is! num || height <= 0) return null;
      shapes.add(
        StabilityShape(
          isPyramid: form == 'pyramid',
          baseWidth: width.toDouble(),
          height: height.toDouble(),
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
    required this.isPyramid,
    required this.baseWidth,
    required this.height,
  });

  final bool isPyramid;
  final double baseWidth;
  final double height;
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

      canvas.save();
      if (tiltDegrees != 0) {
        // Pivot on the bottom right corner, which is the edge a tilting box
        // turns on.
        canvas
          ..translate(cx + halfBase, groundY)
          ..rotate(tiltDegrees * 3.1415926535 / 180)
          ..translate(-(cx + halfBase), -groundY);
      }

      final path = Path()..moveTo(cx - halfBase, groundY);
      if (shape.isPyramid) {
        path
          ..lineTo(cx, groundY - height)
          ..lineTo(cx + halfBase, groundY);
      } else {
        path
          ..lineTo(cx - halfBase, groundY - height)
          ..lineTo(cx + halfBase, groundY - height)
          ..lineTo(cx + halfBase, groundY);
      }
      path.close();

      // The centre of gravity: a third of the way up a pyramid, half way up
      // a box. The plumb line falls from it.
      final cgY = groundY - (shape.isPyramid ? height / 3 : height / 2);
      canvas
        ..drawPath(path, hairline)
        ..drawCircle(Offset(cx, cgY), 3, hairline)
        ..drawLine(Offset(cx, cgY), Offset(cx, groundY + 10), plumb)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_StabilityPainter old) =>
      old.tiltDegrees != tiltDegrees ||
      old.shapes.length != shapes.length ||
      old.ink != ink;
}
