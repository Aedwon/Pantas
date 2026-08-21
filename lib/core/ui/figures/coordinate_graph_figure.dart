import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Axes and authored curves for algebra, calculus, and conic lessons.
class CoordinateGraphFigure extends StatelessWidget {
  const CoordinateGraphFigure({
    required this.type,
    required this.points,
    this.formula,
    super.key,
  });

  static const kind = 'coordinate-graph';
  static const _types = {
    'axes',
    'line',
    'parabola',
    'linear-inequality',
    'system',
    'integral-area',
    'circle',
    'ellipse',
    'hyperbola',
    'function-gallery',
  };

  final String type;
  final String? formula;
  final List<Offset> points;

  static CoordinateGraphFigure? fromSpec(Map<String, Object?> spec) {
    final type = spec['type'];
    if (type is! String || !_types.contains(type)) return null;

    final formula = spec['formula'];
    if (formula != null && formula is! String) return null;

    final rawPoints = spec['points'];
    final points = <Offset>[];
    if (rawPoints != null) {
      if (rawPoints is! List || rawPoints.length > 24) return null;
      for (final rawPoint in rawPoints) {
        if (rawPoint is! List || rawPoint.length != 2) return null;
        final x = rawPoint[0];
        final y = rawPoint[1];
        if (x is! num || y is! num || !x.isFinite || !y.isFinite) {
          return null;
        }
        points.add(Offset(x.toDouble(), y.toDouble()));
      }
    }

    return CoordinateGraphFigure(
      type: type,
      formula: formula as String?,
      points: points,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: formula == null
          ? 'A $type coordinate graph.'
          : 'A $type coordinate graph of $formula.',
      child: SizedBox(
        height: 220,
        child: CustomPaint(
          size: Size.infinite,
          painter: _CoordinateGraphPainter(
            type: type,
            formula: formula,
            points: points,
            ink: colors.ink,
            faint: colors.ruleFaint,
            labelStyle: context.textStyles.bodySmall.copyWith(
              color: colors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CoordinateGraphPainter extends CustomPainter {
  _CoordinateGraphPainter({
    required this.type,
    required this.points,
    required this.ink,
    required this.faint,
    required this.labelStyle,
    this.formula,
  });

  final String type;
  final String? formula;
  final List<Offset> points;
  final Color ink;
  final Color faint;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 22.0;
    final graph =
        Rect.fromLTRB(inset, 12, size.width - 12, size.height - inset);
    final grid = Paint()
      ..color = faint
      ..strokeWidth = 1;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final fill = Paint()
      ..color = ink
      ..style = PaintingStyle.fill;

    for (var i = 1; i < 10; i++) {
      final x = graph.left + graph.width * i / 10;
      final y = graph.top + graph.height * i / 10;
      canvas
        ..drawLine(Offset(x, graph.top), Offset(x, graph.bottom), grid)
        ..drawLine(Offset(graph.left, y), Offset(graph.right, y), grid);
    }
    final origin = graph.center;
    canvas
      ..drawLine(
        Offset(graph.left, origin.dy),
        Offset(graph.right, origin.dy),
        stroke,
      )
      ..drawLine(
        Offset(origin.dx, graph.top),
        Offset(origin.dx, graph.bottom),
        stroke,
      );

    Offset map(double x, double y) => Offset(
          origin.dx + x * graph.width / 12,
          origin.dy - y * graph.height / 12,
        );

    switch (type) {
      case 'circle':
        canvas.drawCircle(
          origin,
          math.min(graph.width, graph.height) * 0.3,
          stroke,
        );
      case 'ellipse':
        canvas.drawOval(
          Rect.fromCenter(
            center: origin,
            width: graph.width * 0.58,
            height: graph.height * 0.36,
          ),
          stroke,
        );
      case 'hyperbola':
        _drawHyperbola(canvas, graph, origin, stroke);
      case 'parabola' || 'integral-area':
        final path = Path();
        for (var i = 0; i <= 80; i++) {
          final x = -4 + i / 10;
          final point = map(x, x * x / 2 - 2);
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(path, stroke);
      case 'line' || 'linear-inequality' || 'system':
        final drawn =
            points.length >= 2 ? points : const [Offset(-4, -2), Offset(4, 2)];
        canvas.drawLine(
          map(drawn.first.dx, drawn.first.dy),
          map(drawn.last.dx, drawn.last.dy),
          stroke,
        );
      case 'function-gallery' || 'axes':
        break;
    }

    for (final point in points) {
      canvas.drawCircle(map(point.dx, point.dy), 3, fill);
    }

    final label = formula;
    if (label != null && label.isNotEmpty) {
      TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(maxWidth: graph.width)
        ..paint(canvas, Offset(graph.left + 4, graph.top + 4));
    }
  }

  void _drawHyperbola(
    Canvas canvas,
    Rect graph,
    Offset origin,
    Paint stroke,
  ) {
    for (final side in [-1.0, 1.0]) {
      final path = Path();
      for (var i = 0; i <= 40; i++) {
        final t = -1.5 + i * 3 / 40;
        final positive = math.exp(t);
        final negative = math.exp(-t);
        final x = side * (positive + negative) / 2 * graph.width * 0.16;
        final y = (positive - negative) / 2 * graph.height * 0.12;
        final point = origin + Offset(x, y);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_CoordinateGraphPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.formula != formula ||
      !listEquals(oldDelegate.points, points) ||
      oldDelegate.ink != ink ||
      oldDelegate.faint != faint;
}
