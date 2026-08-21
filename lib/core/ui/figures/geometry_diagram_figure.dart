import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A labeled geometry construction whose authored labels stay in the spec.
class GeometryDiagramFigure extends StatelessWidget {
  const GeometryDiagramFigure({
    required this.type,
    required this.labels,
    super.key,
  });

  static const kind = 'geometry-diagram';
  static const _types = {
    'triangle',
    'right-triangle',
    'circle',
    'angle',
    'transversal',
    'quadrilateral',
    'polygon',
    'unit-circle',
  };

  final String type;
  final List<String> labels;

  static GeometryDiagramFigure? fromSpec(Map<String, Object?> spec) {
    final type = spec['type'];
    final rawLabels = spec['labels'];
    if (type is! String || !_types.contains(type)) return null;
    if (rawLabels is! List || rawLabels.length < 2 || rawLabels.length > 12) {
      return null;
    }
    final labels = <String>[];
    for (final label in rawLabels) {
      if (label is! String || label.trim().isEmpty || label.length > 24) {
        return null;
      }
      labels.add(label);
    }
    return GeometryDiagramFigure(type: type, labels: labels);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A $type diagram labeled ${labels.join(', ')}.',
      child: SizedBox(
        height: 190,
        child: CustomPaint(
          size: Size.infinite,
          painter: _GeometryDiagramPainter(
            type: type,
            labels: labels,
            ink: colors.ink,
            faint: colors.ruleFaint,
            labelStyle: context.textStyles.bodySmall.copyWith(
              color: colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _GeometryDiagramPainter extends CustomPainter {
  _GeometryDiagramPainter({
    required this.type,
    required this.labels,
    required this.ink,
    required this.faint,
    required this.labelStyle,
  });

  final String type;
  final List<String> labels;
  final Color ink;
  final Color faint;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final helper = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final bounds = Rect.fromLTWH(24, 18, size.width - 48, size.height - 38);

    final anchors = switch (type) {
      'circle' || 'unit-circle' => _drawCircle(canvas, bounds, stroke, helper),
      'angle' => _drawAngle(canvas, bounds, stroke),
      'transversal' => _drawTransversal(canvas, bounds, stroke),
      'quadrilateral' => _drawPolygon(canvas, bounds, stroke, 4),
      'polygon' => _drawPolygon(
          canvas,
          bounds,
          stroke,
          labels.length.clamp(3, 8),
        ),
      'right-triangle' => _drawTriangle(canvas, bounds, stroke, right: true),
      _ => _drawTriangle(canvas, bounds, stroke),
    };

    for (var i = 0; i < labels.length; i++) {
      final anchor = anchors[i % anchors.length];
      TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(maxWidth: 72)
        ..paint(canvas, anchor + const Offset(5, -16));
    }
  }

  List<Offset> _drawTriangle(
    Canvas canvas,
    Rect bounds,
    Paint stroke, {
    bool right = false,
  }) {
    final points = [
      Offset(bounds.left + bounds.width * 0.18, bounds.bottom),
      Offset(bounds.right - bounds.width * 0.12, bounds.bottom),
      Offset(
        right ? bounds.left + bounds.width * 0.18 : bounds.center.dx,
        bounds.top,
      ),
    ];
    canvas.drawPath(
      Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[1].dx, points[1].dy)
        ..lineTo(points[2].dx, points[2].dy)
        ..close(),
      stroke,
    );
    if (right) {
      const side = 13.0;
      canvas.drawRect(
        Rect.fromLTWH(points[0].dx, points[0].dy - side, side, side),
        stroke,
      );
    }
    return points;
  }

  List<Offset> _drawCircle(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final radius = math.min(bounds.width, bounds.height) * 0.4;
    final center = bounds.center;
    canvas
      ..drawCircle(center, radius, stroke)
      ..drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        helper,
      )
      ..drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        helper,
      );
    return [
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      center,
    ];
  }

  List<Offset> _drawAngle(Canvas canvas, Rect bounds, Paint stroke) {
    final vertex = Offset(bounds.center.dx, bounds.bottom - 12);
    final left = Offset(bounds.left + 22, bounds.top + 24);
    final right = Offset(bounds.right - 10, bounds.center.dy);
    canvas
      ..drawLine(vertex, left, stroke)
      ..drawLine(vertex, right, stroke)
      ..drawArc(
        Rect.fromCircle(center: vertex, radius: 30),
        -2.1,
        1.55,
        false,
        stroke,
      );
    return [left, vertex, right];
  }

  List<Offset> _drawTransversal(Canvas canvas, Rect bounds, Paint stroke) {
    final y1 = bounds.top + bounds.height * 0.3;
    final y2 = bounds.top + bounds.height * 0.7;
    final start = Offset(bounds.left + bounds.width * 0.3, bounds.bottom);
    final end = Offset(bounds.left + bounds.width * 0.7, bounds.top);
    canvas
      ..drawLine(Offset(bounds.left, y1), Offset(bounds.right, y1), stroke)
      ..drawLine(Offset(bounds.left, y2), Offset(bounds.right, y2), stroke)
      ..drawLine(start, end, stroke);
    return [
      Offset(bounds.center.dx + bounds.width * 0.1, y1),
      Offset(bounds.center.dx - bounds.width * 0.1, y2),
      start,
      end,
    ];
  }

  List<Offset> _drawPolygon(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    int sides,
  ) {
    final radius = math.min(bounds.width, bounds.height) * 0.42;
    final points = <Offset>[];
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      points.add(
        bounds.center +
            Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      );
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), stroke);
    return points;
  }

  @override
  bool shouldRepaint(_GeometryDiagramPainter oldDelegate) =>
      oldDelegate.type != type ||
      !listEquals(oldDelegate.labels, labels) ||
      oldDelegate.ink != ink ||
      oldDelegate.faint != faint;
}
