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
    'right-triangle-trig',
    'similar-triangles',
    'special-right-triangles',
    'triangle-exterior',
    'circle',
    'circle-elements',
    'circle-sector',
    'circle-arc',
    'circle-inscribed-central',
    'circle-inscribed-triangle',
    'circle-tangent',
    'unit-circle',
    'unit-circle-quadrants',
    'angle',
    'angle-gallery',
    'complementary-angles',
    'supplementary-angles',
    'vertical-angles',
    'angles-on-line',
    'coterminal-angles',
    'transversal',
    'parallel-zigzag',
    'quadrilateral',
    'parallelogram',
    'rectangle',
    'trapezoid',
    'quadrilateral-tree',
    'polygon',
    'polygon-triangulation',
    'polygon-exterior',
    'basic-concepts',
    'segment-midpoint',
    'coordinate-geometry',
    '3d-box',
    '3d-cylinder',
    '3d-cone',
    'inscribed-circle-square',
    'shape-gallery',
    'elevation-depression',
    'two-triangles-elevation',
  };

  final String type;
  final List<String> labels;

  static GeometryDiagramFigure? fromSpec(Map<String, Object?> spec) {
    final type = spec['type'];
    final rawLabels = spec['labels'];
    if (type is! String || !_types.contains(type)) return null;
    if (rawLabels is! List || rawLabels.isEmpty || rawLabels.length > 16) {
      return null;
    }
    final labels = <String>[];
    for (final label in rawLabels) {
      if (label is! String || label.trim().isEmpty || label.length > 64) {
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
            board: colors.board,
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
    required this.board,
    required this.labelStyle,
  });

  final String type;
  final List<String> labels;
  final Color ink;
  final Color faint;
  final Color board;
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
      ..strokeWidth = 1.0;
    final fillFaint = Paint()
      ..color = faint.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final bounds = Rect.fromLTWH(24, 18, size.width - 48, size.height - 38);

    final anchors = switch (type) {
      'basic-concepts' => _drawBasicConcepts(canvas, bounds, stroke, helper),
      'angle-gallery' => _drawAngleGallery(canvas, bounds, stroke),
      'vertical-angles' => _drawVerticalAngles(canvas, bounds, stroke),
      'complementary-angles' =>
        _drawComplementaryAngles(canvas, bounds, stroke),
      'supplementary-angles' =>
        _drawSupplementaryAngles(canvas, bounds, stroke),
      'segment-midpoint' => _drawSegmentMidpoint(canvas, bounds, stroke),
      'angles-on-line' => _drawAnglesOnLine(canvas, bounds, stroke),
      'circle-elements' => _drawCircleElements(canvas, bounds, stroke, helper),
      'circle-inscribed-central' =>
        _drawCircleInscribedCentral(canvas, bounds, stroke, helper),
      'circle-sector' =>
        _drawCircleSector(canvas, bounds, stroke, helper, fillFaint),
      'circle-inscribed-triangle' =>
        _drawCircleInscribedTriangle(canvas, bounds, stroke, helper),
      'circle-tangent' => _drawCircleTangent(canvas, bounds, stroke, helper),
      'circle-arc' => _drawCircleArc(canvas, bounds, stroke, helper),
      'coordinate-geometry' =>
        _drawCoordinateGeometry(canvas, bounds, stroke, helper),
      'shape-gallery' => _drawShapeGallery(canvas, bounds, stroke),
      'rectangle' => _drawRectangle(canvas, bounds, stroke),
      'trapezoid' => _drawTrapezoid(canvas, bounds, stroke, helper),
      'inscribed-circle-square' =>
        _drawInscribedCircleSquare(canvas, bounds, stroke, fillFaint),
      '3d-box' => _draw3DBox(canvas, bounds, stroke, helper),
      '3d-cylinder' => _draw3DCylinder(canvas, bounds, stroke, helper),
      '3d-cone' => _draw3DCone(canvas, bounds, stroke, helper),
      'transversal' => _drawTransversal(canvas, bounds, stroke),
      'parallel-zigzag' => _drawParallelZigzag(canvas, bounds, stroke, helper),
      'polygon-triangulation' =>
        _drawPolygonTriangulation(canvas, bounds, stroke, helper),
      'quadrilateral-tree' => _drawQuadTree(canvas, bounds, stroke, helper),
      'polygon-exterior' =>
        _drawPolygonExterior(canvas, bounds, stroke, helper),
      'parallelogram' => _drawParallelogram(canvas, bounds, stroke),
      'quadrilateral' => _drawPolygon(canvas, bounds, stroke, 4),
      'polygon' => _drawPolygon(canvas, bounds, stroke, 8),
      'triangle-exterior' =>
        _drawTriangleExterior(canvas, bounds, stroke, helper),
      'similar-triangles' =>
        _drawSimilarTriangles(canvas, bounds, stroke, helper),
      'special-right-triangles' =>
        _drawSpecialRightTriangles(canvas, bounds, stroke),
      'coterminal-angles' =>
        _drawCoterminalAngles(canvas, bounds, stroke, helper),
      'unit-circle-quadrants' =>
        _drawUnitCircleQuadrants(canvas, bounds, stroke, helper),
      'unit-circle' => _drawUnitCircle(canvas, bounds, stroke, helper),
      'elevation-depression' =>
        _drawElevationDepression(canvas, bounds, stroke, helper),
      'two-triangles-elevation' =>
        _drawTwoTrianglesElevation(canvas, bounds, stroke, helper),
      'right-triangle-trig' ||
      'right-triangle' =>
        _drawTriangle(canvas, bounds, stroke, right: true),
      'circle' => _drawCircle(canvas, bounds, stroke, helper),
      'angle' => _drawAngle(canvas, bounds, stroke),
      _ => _drawTriangle(canvas, bounds, stroke),
    };

    _drawLabels(canvas, labels, anchors);
  }

  void _drawLabels(Canvas canvas, List<String> labels, List<Offset> anchors) {
    if (anchors.isEmpty) return;
    for (var i = 0; i < labels.length; i++) {
      final anchor = anchors[i % anchors.length];
      TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(maxWidth: 110)
        ..paint(
          canvas,
          anchor + const Offset(-10, -14),
        );
    }
  }

  List<Offset> _drawTriangle(
    Canvas canvas,
    Rect bounds,
    Paint stroke, {
    bool right = false,
  }) {
    final points = [
      Offset(bounds.left + bounds.width * 0.15, bounds.bottom - 4),
      Offset(bounds.right - bounds.width * 0.15, bounds.bottom - 4),
      Offset(
        right ? bounds.left + bounds.width * 0.15 : bounds.center.dx,
        bounds.top + 6,
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
      const side = 12.0;
      canvas.drawRect(
        Rect.fromLTWH(points[0].dx, points[0].dy - side, side, side),
        stroke,
      );
    }
    return [
      Offset(points[0].dx - 12, points[0].dy - 10),
      Offset(points[1].dx + 6, points[1].dy - 10),
      Offset(points[2].dx - 10, points[2].dy - 16),
      Offset(
        (points[0].dx + points[1].dx) / 2,
        points[0].dy + 4,
      ),
      Offset(
        (points[1].dx + points[2].dx) / 2 + 8,
        (points[1].dy + points[2].dy) / 2,
      ),
      Offset(
        (points[0].dx + points[2].dx) / 2 - 16,
        (points[0].dy + points[2].dy) / 2,
      ),
    ];
  }

  List<Offset> _drawBasicConcepts(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final yMid = bounds.center.dy;
    // Line AB and Segment CD
    canvas
      ..drawLine(
        Offset(bounds.left, yMid - 30),
        Offset(bounds.left + bounds.width * 0.45, yMid - 30),
        stroke,
      )
      ..drawLine(
        Offset(bounds.left, yMid + 30),
        Offset(bounds.left + bounds.width * 0.45, yMid + 30),
        stroke,
      );
    // Plane
    final planePath = Path()
      ..moveTo(bounds.left + bounds.width * 0.55, bounds.top + 10)
      ..lineTo(bounds.right, bounds.top + 10)
      ..lineTo(bounds.right - 20, bounds.bottom - 10)
      ..lineTo(bounds.left + bounds.width * 0.55 - 20, bounds.bottom - 10)
      ..close();
    canvas.drawPath(planePath, stroke);

    return [
      Offset(bounds.left + 10, bounds.top + 4),
      Offset(bounds.left + 20, yMid - 46),
      Offset(bounds.left + 20, yMid + 14),
      Offset(bounds.left + bounds.width * 0.25, yMid - 10),
      Offset(bounds.left + bounds.width * 0.65, bounds.center.dy),
    ];
  }

  List<Offset> _drawAngleGallery(Canvas canvas, Rect bounds, Paint stroke) {
    final step = bounds.width / 5;
    for (var i = 0; i < 5; i++) {
      final cx = bounds.left + step * i + step * 0.5;
      final cy = bounds.center.dy;
      final vertex = Offset(cx, cy + 15);
      canvas.drawLine(vertex, Offset(cx + 20, cy + 15), stroke);
      final angleRad = switch (i) {
        0 => -0.6,
        1 => -math.pi / 2,
        2 => -2.2,
        3 => -math.pi,
        _ => 0.8,
      };
      canvas.drawLine(
        vertex,
        Offset(cx + math.cos(angleRad) * 20, cy + 15 + math.sin(angleRad) * 20),
        stroke,
      );
      if (i == 1) {
        canvas.drawRect(Rect.fromLTWH(cx, cy + 5, 8, 10), stroke);
      }
    }
    return List.generate(
      5,
      (i) => Offset(bounds.left + step * i + 4, bounds.bottom - 20),
    );
  }

  List<Offset> _drawVerticalAngles(Canvas canvas, Rect bounds, Paint stroke) {
    final center = bounds.center;
    canvas
      ..drawLine(
        Offset(bounds.left + 20, bounds.top + 10),
        Offset(bounds.right - 20, bounds.bottom - 10),
        stroke,
      )
      ..drawLine(
        Offset(bounds.left + 20, bounds.bottom - 10),
        Offset(bounds.right - 20, bounds.top + 10),
        stroke,
      );
    return [
      Offset(center.dx - 10, bounds.top + 8),
      Offset(center.dx - 10, bounds.bottom - 16),
      Offset(bounds.right - 60, center.dy - 10),
    ];
  }

  List<Offset> _drawComplementaryAngles(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
  ) {
    final vertex = Offset(bounds.left + bounds.width * 0.3, bounds.bottom - 10);
    canvas
      ..drawLine(
        vertex,
        Offset(bounds.left + bounds.width * 0.8, vertex.dy),
        stroke,
      )
      ..drawLine(vertex, Offset(vertex.dx, bounds.top + 10), stroke)
      ..drawLine(
        vertex,
        Offset(vertex.dx + bounds.width * 0.35, bounds.top + 25),
        stroke,
      )
      ..drawRect(Rect.fromLTWH(vertex.dx, vertex.dy - 12, 12, 12), stroke);
    return [
      Offset(vertex.dx + 25, vertex.dy - 25),
      Offset(vertex.dx + 8, bounds.top + 30),
      Offset(bounds.left + bounds.width * 0.5, bounds.top + 8),
    ];
  }

  List<Offset> _drawSupplementaryAngles(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
  ) {
    final vertex = Offset(bounds.center.dx, bounds.bottom - 15);
    canvas
      ..drawLine(
        Offset(bounds.left + 10, vertex.dy),
        Offset(bounds.right - 10, vertex.dy),
        stroke,
      )
      ..drawLine(
        vertex,
        Offset(vertex.dx - bounds.width * 0.25, bounds.top + 20),
        stroke,
      );
    return [
      Offset(vertex.dx - 45, vertex.dy - 35),
      Offset(vertex.dx + 20, vertex.dy - 35),
      Offset(bounds.center.dx - 20, bounds.top + 6),
    ];
  }

  List<Offset> _drawSegmentMidpoint(Canvas canvas, Rect bounds, Paint stroke) {
    final y = bounds.center.dy;
    final p1 = Offset(bounds.left + 20, y);
    final p2 = Offset(bounds.right - 20, y);
    final mid = Offset(bounds.center.dx, y);
    canvas
      ..drawLine(p1, p2, stroke)
      ..drawCircle(p1, 2.5, stroke)
      ..drawCircle(p2, 2.5, stroke)
      ..drawCircle(mid, 2.5, stroke)
      ..drawLine(Offset(mid.dx - 20, y - 6), Offset(mid.dx - 20, y + 6), stroke)
      ..drawLine(
        Offset(mid.dx + 20, y - 6),
        Offset(mid.dx + 20, y + 6),
        stroke,
      );
    return [
      Offset(p1.dx - 6, y - 20),
      Offset(mid.dx - 4, y - 20),
      Offset(p2.dx - 6, y - 20),
      Offset((p1.dx + mid.dx) / 2 - 12, y + 10),
      Offset((mid.dx + p2.dx) / 2 - 12, y + 10),
    ];
  }

  List<Offset> _drawAnglesOnLine(Canvas canvas, Rect bounds, Paint stroke) {
    final vertex = Offset(bounds.center.dx, bounds.bottom - 15);
    canvas
      ..drawLine(
        Offset(bounds.left + 10, vertex.dy),
        Offset(bounds.right - 10, vertex.dy),
        stroke,
      )
      ..drawLine(
        vertex,
        Offset(vertex.dx - bounds.width * 0.25, bounds.top + 20),
        stroke,
      )
      ..drawLine(
        vertex,
        Offset(vertex.dx + bounds.width * 0.2, bounds.top + 15),
        stroke,
      );
    return [
      Offset(vertex.dx - 65, vertex.dy - 30),
      Offset(vertex.dx - 8, vertex.dy - 50),
      Offset(vertex.dx + 35, vertex.dy - 30),
      Offset(bounds.center.dx - 15, bounds.top + 6),
    ];
  }

  List<Offset> _drawCircleElements(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.38;
    canvas
      ..drawCircle(center, radius, stroke)
      ..drawLine(center, Offset(center.dx + radius, center.dy), stroke)
      ..drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        helper,
      )
      ..drawLine(
        Offset(center.dx - radius * 0.7, center.dy - radius * 0.7),
        Offset(center.dx + radius * 0.7, center.dy - radius * 0.7),
        stroke,
      )
      ..drawLine(
        Offset(bounds.left + 10, center.dy - radius * 0.3),
        Offset(bounds.right - 10, center.dy + radius * 0.6),
        stroke,
      )
      ..drawLine(
        Offset(center.dx + radius, bounds.top + 10),
        Offset(center.dx + radius, bounds.bottom - 10),
        stroke,
      );
    return [
      Offset(center.dx + 10, center.dy - 14),
      Offset(center.dx - 30, center.dy + 8),
      Offset(center.dx - 10, center.dy - radius * 0.7 - 16),
      Offset(bounds.left + 10, center.dy - radius * 0.3 - 14),
      Offset(center.dx + radius + 6, center.dy),
      Offset(center.dx - 8, center.dy + 4),
    ];
  }

  List<Offset> _drawCircleInscribedCentral(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.4;
    final pA = Offset(center.dx - radius * 0.7, center.dy + radius * 0.7);
    final pB = Offset(center.dx + radius * 0.7, center.dy + radius * 0.7);
    final pTop = Offset(center.dx, center.dy - radius);
    canvas
      ..drawCircle(center, radius, stroke)
      ..drawLine(center, pA, stroke)
      ..drawLine(center, pB, stroke)
      ..drawLine(pTop, pA, helper)
      ..drawLine(pTop, pB, helper);
    return [
      Offset(center.dx - 20, center.dy - 4),
      Offset(pTop.dx - 15, pTop.dy - 16),
      Offset(center.dx - 15, bounds.bottom - 16),
    ];
  }

  List<Offset> _drawCircleSector(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
    Paint fillFaint,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas
      ..drawCircle(center, radius, stroke)
      ..drawArc(rect, -math.pi / 3, math.pi / 3, true, fillFaint)
      ..drawLine(center, Offset(center.dx + radius, center.dy), stroke)
      ..drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(-math.pi / 3),
          center.dy + radius * math.sin(-math.pi / 3),
        ),
        stroke,
      );
    return [
      Offset(center.dx + 12, center.dy + 6),
      Offset(center.dx + 24, center.dy - 18),
      Offset(center.dx + radius * 0.4, center.dy - 32),
      Offset(bounds.right - 45, center.dy - 15),
    ];
  }

  List<Offset> _drawCircleInscribedTriangle(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.4;
    final pA = Offset(center.dx - radius, center.dy);
    final pB = Offset(center.dx + radius, center.dy);
    final pC = Offset(center.dx + radius * 0.2, center.dy - radius * 0.98);
    canvas
      ..drawCircle(center, radius, stroke)
      ..drawLine(pA, pB, stroke)
      ..drawLine(pA, pC, stroke)
      ..drawLine(pB, pC, stroke);
    return [
      Offset(pA.dx - 12, pA.dy - 8),
      Offset(pB.dx + 6, pB.dy - 8),
      Offset(pC.dx - 4, pC.dy - 16),
      Offset(center.dx - 20, pA.dy + 8),
      Offset((pA.dx + pC.dx) / 2 - 18, (pA.dy + pC.dy) / 2),
      Offset((pB.dx + pC.dx) / 2 + 6, (pB.dy + pC.dy) / 2),
      Offset(pC.dx - 8, pC.dy + 10),
    ];
  }

  List<Offset> _drawCircleTangent(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = Offset(bounds.left + bounds.width * 0.3, bounds.center.dy);
    final radius = bounds.height * 0.35;
    final pP = Offset(bounds.right - 20, bounds.center.dy);
    final pT = Offset(center.dx + radius * 0.6, center.dy - radius * 0.8);
    canvas
      ..drawCircle(center, radius, stroke)
      ..drawLine(center, pP, helper)
      ..drawLine(pP, pT, stroke)
      ..drawLine(center, pT, stroke);
    return [
      Offset(center.dx - 16, center.dy - 16),
      Offset(pP.dx + 4, pP.dy - 8),
      Offset(pT.dx - 4, pT.dy - 16),
      Offset((center.dx + pT.dx) / 2 - 14, (center.dy + pT.dy) / 2),
      Offset((center.dx + pP.dx) / 2 - 10, center.dy + 6),
      Offset((pP.dx + pT.dx) / 2, (pP.dy + pT.dy) / 2 - 14),
      Offset(pT.dx + 4, pT.dy + 4),
    ];
  }

  List<Offset> _drawCircleArc(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final boldStroke = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas
      ..drawCircle(center, radius, helper)
      ..drawArc(rect, -0.8, 1.2, false, boldStroke)
      ..drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(-0.8),
          center.dy + radius * math.sin(-0.8),
        ),
        stroke,
      )
      ..drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(0.4),
          center.dy + radius * math.sin(0.4),
        ),
        stroke,
      );
    return [
      Offset(center.dx + 12, center.dy - 10),
      Offset(bounds.right - 45, center.dy - 4),
      Offset(center.dx - 30, bounds.bottom - 16),
    ];
  }

  List<Offset> _drawCoordinateGeometry(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    canvas
      ..drawLine(
        Offset(bounds.left, center.dy),
        Offset(bounds.right, center.dy),
        helper,
      )
      ..drawLine(
        Offset(center.dx, bounds.top),
        Offset(center.dx, bounds.bottom),
        helper,
      );
    final p1 = Offset(
      center.dx - bounds.width * 0.28,
      center.dy + bounds.height * 0.25,
    );
    final p2 = Offset(
      center.dx + bounds.width * 0.28,
      center.dy - bounds.height * 0.25,
    );
    canvas
      ..drawLine(p1, p2, stroke)
      ..drawLine(p1, Offset(p2.dx, p1.dy), helper)
      ..drawLine(Offset(p2.dx, p1.dy), p2, helper)
      ..drawCircle(p1, 2.5, stroke)
      ..drawCircle(p2, 2.5, stroke);
    return [
      Offset(p1.dx - 18, p1.dy + 4),
      Offset(p2.dx + 4, p2.dy - 12),
      Offset((p1.dx + p2.dx) / 2 - 10, p1.dy + 4),
      Offset(p2.dx + 6, (p1.dy + p2.dy) / 2),
      Offset((p1.dx + p2.dx) / 2 - 10, (p1.dy + p2.dy) / 2 - 16),
    ];
  }

  List<Offset> _drawShapeGallery(Canvas canvas, Rect bounds, Paint stroke) {
    final step = bounds.width / 6;
    for (var i = 0; i < 6; i++) {
      final cx = bounds.left + step * i + step * 0.5;
      final cy = bounds.center.dy - 10;
      switch (i) {
        case 0:
          canvas.drawRect(
            Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 22),
            stroke,
          );
        case 1:
          canvas.drawRect(
            Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 18),
            stroke,
          );
        case 2:
          canvas.drawPath(
            Path()
              ..moveTo(cx, cy - 12)
              ..lineTo(cx - 14, cy + 12)
              ..lineTo(cx + 14, cy + 12)
              ..close(),
            stroke,
          );
        case 3:
          canvas.drawPath(
            Path()
              ..moveTo(cx - 10, cy - 10)
              ..lineTo(cx + 16, cy - 10)
              ..lineTo(cx + 10, cy + 10)
              ..lineTo(cx - 16, cy + 10)
              ..close(),
            stroke,
          );
        case 4:
          canvas.drawPath(
            Path()
              ..moveTo(cx - 8, cy - 10)
              ..lineTo(cx + 8, cy - 10)
              ..lineTo(cx + 14, cy + 10)
              ..lineTo(cx - 14, cy + 10)
              ..close(),
            stroke,
          );
        default:
          canvas.drawCircle(Offset(cx, cy), 12, stroke);
      }
    }
    return List.generate(
      6,
      (i) => Offset(bounds.left + step * i + 2, bounds.bottom - 22),
    );
  }

  List<Offset> _drawRectangle(Canvas canvas, Rect bounds, Paint stroke) {
    final rect = Rect.fromLTWH(
      bounds.left + bounds.width * 0.2,
      bounds.top + bounds.height * 0.2,
      bounds.width * 0.6,
      bounds.height * 0.5,
    );
    canvas.drawRect(rect, stroke);
    return [
      Offset(rect.center.dx - 20, rect.top - 16),
      Offset(rect.right + 6, rect.center.dy - 8),
      Offset(rect.center.dx - 25, rect.bottom + 8),
    ];
  }

  List<Offset> _drawTrapezoid(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final topL = Offset(bounds.left + bounds.width * 0.28, bounds.top + 20);
    final topR = Offset(bounds.right - bounds.width * 0.28, bounds.top + 20);
    final botL = Offset(bounds.left + bounds.width * 0.12, bounds.bottom - 20);
    final botR = Offset(bounds.right - bounds.width * 0.12, bounds.bottom - 20);
    canvas
      ..drawPath(
        Path()
          ..moveTo(topL.dx, topL.dy)
          ..lineTo(topR.dx, topR.dy)
          ..lineTo(botR.dx, botR.dy)
          ..lineTo(botL.dx, botL.dy)
          ..close(),
        stroke,
      )
      ..drawLine(topL, Offset(topL.dx, botL.dy), helper)
      ..drawRect(Rect.fromLTWH(topL.dx, botL.dy - 10, 10, 10), helper);
    return [
      Offset(bounds.center.dx - 15, topL.dy - 16),
      Offset(bounds.center.dx - 15, botL.dy + 6),
      Offset(topL.dx - 18, (topL.dy + botL.dy) / 2),
      Offset(topL.dx + 4, botL.dy - 12),
    ];
  }

  List<Offset> _drawInscribedCircleSquare(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint fillFaint,
  ) {
    final size = math.min(bounds.width, bounds.height) * 0.75;
    final rect =
        Rect.fromCenter(center: bounds.center, width: size, height: size);
    canvas
      ..drawRect(rect, fillFaint)
      ..drawRect(rect, stroke)
      ..drawCircle(rect.center, size / 2, stroke);
    return [
      Offset(rect.left - 12, rect.top - 16),
      Offset(rect.center.dx - 10, rect.center.dy - 8),
      Offset(rect.center.dx - 30, rect.bottom + 6),
    ];
  }

  List<Offset> _draw3DBox(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final fLeft = bounds.left + bounds.width * 0.2;
    final fTop = bounds.top + bounds.height * 0.35;
    final width = bounds.width * 0.45;
    final height = bounds.height * 0.45;
    const depthX = 28.0;
    const depthY = -18.0;

    final front = Rect.fromLTWH(fLeft, fTop, width, height);
    const depth = Offset(depthX, depthY);
    canvas
      ..drawRect(front, stroke)
      ..drawLine(front.topLeft, front.topLeft + depth, stroke)
      ..drawLine(front.topRight, front.topRight + depth, stroke)
      ..drawLine(front.bottomRight, front.bottomRight + depth, stroke)
      ..drawLine(front.topLeft + depth, front.topRight + depth, stroke)
      ..drawLine(front.topRight + depth, front.bottomRight + depth, stroke);
    return [
      Offset(front.center.dx - 15, front.bottom + 6),
      Offset(front.right + 12, front.center.dy),
      Offset(front.left - 24, front.center.dy),
    ];
  }

  List<Offset> _draw3DCylinder(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final cx = bounds.center.dx;
    final topY = bounds.top + 30;
    final botY = bounds.bottom - 30;
    final rx = bounds.width * 0.25;
    const ry = 12.0;

    canvas
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx, topY),
          width: rx * 2,
          height: ry * 2,
        ),
        stroke,
      )
      ..drawLine(Offset(cx - rx, topY), Offset(cx - rx, botY), stroke)
      ..drawLine(Offset(cx + rx, topY), Offset(cx + rx, botY), stroke)
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx, botY),
          width: rx * 2,
          height: ry * 2,
        ),
        0,
        math.pi,
        false,
        stroke,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx, botY),
          width: rx * 2,
          height: ry * 2,
        ),
        math.pi,
        math.pi,
        false,
        helper,
      )
      ..drawLine(Offset(cx, topY), Offset(cx + rx, topY), stroke);
    return [
      Offset(cx + 4, topY - 14),
      Offset(cx + rx + 8, bounds.center.dy),
    ];
  }

  List<Offset> _draw3DCone(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final cx = bounds.center.dx;
    final apexY = bounds.top + 15;
    final botY = bounds.bottom - 25;
    final rx = bounds.width * 0.3;
    const ry = 14.0;

    canvas
      ..drawLine(Offset(cx, apexY), Offset(cx - rx, botY), stroke)
      ..drawLine(Offset(cx, apexY), Offset(cx + rx, botY), stroke)
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx, botY),
          width: rx * 2,
          height: ry * 2,
        ),
        0,
        math.pi,
        false,
        stroke,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx, botY),
          width: rx * 2,
          height: ry * 2,
        ),
        math.pi,
        math.pi,
        false,
        helper,
      )
      ..drawLine(Offset(cx, apexY), Offset(cx, botY), helper)
      ..drawLine(Offset(cx, botY), Offset(cx + rx, botY), stroke)
      ..drawRect(Rect.fromLTWH(cx, botY - 8, 8, 8), helper);
    return [
      Offset(cx + 10, botY + 4),
      Offset(cx - 24, bounds.center.dy),
      Offset(cx + rx * 0.5 + 8, bounds.center.dy),
      Offset(cx + 4, botY - 12),
    ];
  }

  List<Offset> _drawTransversal(Canvas canvas, Rect bounds, Paint stroke) {
    final y1 = bounds.top + bounds.height * 0.32;
    final y2 = bounds.top + bounds.height * 0.68;
    final start = Offset(bounds.left + bounds.width * 0.25, bounds.bottom - 8);
    final end = Offset(bounds.left + bounds.width * 0.75, bounds.top + 8);
    canvas
      ..drawLine(Offset(bounds.left, y1), Offset(bounds.right, y1), stroke)
      ..drawLine(Offset(bounds.left, y2), Offset(bounds.right, y2), stroke)
      ..drawLine(start, end, stroke);
    return [
      Offset(bounds.left + 6, y1 - 14),
      Offset(bounds.left + 6, y2 - 14),
      Offset(bounds.center.dx + bounds.width * 0.12, y1 - 16),
      Offset(bounds.center.dx - bounds.width * 0.12, y1 + 4),
      Offset(bounds.center.dx + bounds.width * 0.05, y2 - 16),
      Offset(bounds.center.dx - bounds.width * 0.2, y2 + 4),
      start,
      end,
    ];
  }

  List<Offset> _drawParallelZigzag(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final y1 = bounds.top + 20;
    final y2 = bounds.bottom - 20;
    final pP = Offset(bounds.center.dx, bounds.center.dy);
    canvas
      ..drawLine(Offset(bounds.left, y1), Offset(bounds.right, y1), stroke)
      ..drawLine(Offset(bounds.left, y2), Offset(bounds.right, y2), stroke)
      ..drawLine(Offset(bounds.left + bounds.width * 0.25, y1), pP, stroke)
      ..drawLine(pP, Offset(bounds.right - bounds.width * 0.25, y2), stroke)
      ..drawLine(
        Offset(bounds.left + 20, pP.dy),
        Offset(bounds.right - 20, pP.dy),
        helper,
      );
    return [
      Offset(bounds.left + 6, y1 - 14),
      Offset(bounds.left + 6, y2 + 4),
      Offset(pP.dx + 8, pP.dy - 8),
      Offset(pP.dx - 30, pP.dy - 16),
      Offset(pP.dx - 30, pP.dy + 8),
      Offset(bounds.center.dx - 20, bounds.bottom - 4),
    ];
  }

  List<Offset> _drawPolygonTriangulation(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.42;
    const sides = 6;
    final points = <Offset>[];
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      points.add(
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      );
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), stroke);
    // Diagonals from vertex 0
    for (var i = 2; i < sides - 1; i++) {
      canvas.drawLine(points[0], points[i], helper);
    }
    return [
      Offset(center.dx - 20, bounds.top - 16),
      Offset(center.dx - 15, center.dy),
      Offset(center.dx - 30, bounds.bottom + 4),
    ];
  }

  List<Offset> _drawQuadTree(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final top = Offset(bounds.center.dx, bounds.top + 15);
    final trap = Offset(bounds.left + bounds.width * 0.2, bounds.top + 55);
    final para = Offset(bounds.right - bounds.width * 0.35, bounds.top + 55);
    final rect = Offset(bounds.center.dx - 30, bounds.top + 105);
    final rhom = Offset(bounds.right - 30, bounds.top + 105);
    final sq = Offset(bounds.center.dx + 25, bounds.bottom - 15);

    canvas
      ..drawLine(top, trap, helper)
      ..drawLine(top, para, helper)
      ..drawLine(para, rect, helper)
      ..drawLine(para, rhom, helper)
      ..drawLine(rect, sq, helper)
      ..drawLine(rhom, sq, helper);
    return [
      Offset(top.dx - 30, top.dy - 12),
      Offset(trap.dx - 25, trap.dy - 6),
      Offset(para.dx - 20, para.dy - 6),
      Offset(rect.dx - 25, rect.dy - 6),
      Offset(rhom.dx - 25, rhom.dy - 6),
      Offset(sq.dx - 18, sq.dy - 6),
    ];
  }

  List<Offset> _drawPolygonExterior(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.38;
    const sides = 6;
    final points = <Offset>[];
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      points.add(
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      );
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), stroke);
    // Extend side from points[3] to points[4]
    final p3 = points[3];
    final p4 = points[4];
    final ext = p4 + (p4 - p3) * 0.6;
    canvas.drawLine(p4, ext, helper);
    return [
      Offset(p4.dx + 12, p4.dy - 12),
      Offset(center.dx - 20, bounds.top - 16),
      Offset(center.dx - 25, bounds.bottom + 4),
    ];
  }

  List<Offset> _drawParallelogram(Canvas canvas, Rect bounds, Paint stroke) {
    final pA = Offset(bounds.left + bounds.width * 0.15, bounds.bottom - 15);
    final pB = Offset(bounds.right - bounds.width * 0.25, bounds.bottom - 15);
    final pC = Offset(bounds.right - bounds.width * 0.15, bounds.top + 15);
    final pD = Offset(bounds.left + bounds.width * 0.25, bounds.top + 15);
    canvas.drawPath(
      Path()
        ..moveTo(pA.dx, pA.dy)
        ..lineTo(pB.dx, pB.dy)
        ..lineTo(pC.dx, pC.dy)
        ..lineTo(pD.dx, pD.dy)
        ..close(),
      stroke,
    );
    return [
      Offset(pA.dx - 12, pA.dy + 4),
      Offset(pB.dx + 6, pB.dy + 4),
      Offset(pC.dx + 6, pC.dy - 14),
      Offset(pD.dx - 12, pD.dy - 14),
      Offset(pA.dx + 8, pA.dy - 20),
      Offset(pC.dx - 28, pC.dy + 8),
      Offset(pB.dx - 24, pB.dy - 20),
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
    return [
      ...points,
      Offset(bounds.center.dx - 15, bounds.center.dy),
    ];
  }

  List<Offset> _drawTriangleExterior(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final pA = Offset(bounds.left + bounds.width * 0.15, bounds.bottom - 15);
    final pB = Offset(bounds.left + bounds.width * 0.65, bounds.bottom - 15);
    final pC = Offset(bounds.left + bounds.width * 0.4, bounds.top + 20);
    final pExt = Offset(bounds.right - 10, bounds.bottom - 15);
    canvas
      ..drawPath(
        Path()
          ..moveTo(pA.dx, pA.dy)
          ..lineTo(pB.dx, pB.dy)
          ..lineTo(pC.dx, pC.dy)
          ..close(),
        stroke,
      )
      ..drawLine(pB, pExt, helper);
    return [
      Offset(pA.dx + 8, pA.dy - 20),
      Offset(pC.dx - 4, pC.dy + 10),
      Offset(pB.dx + 12, pB.dy - 20),
    ];
  }

  List<Offset> _drawSimilarTriangles(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    // Small triangle
    final sA = Offset(bounds.left + 15, bounds.bottom - 15);
    final sB = Offset(bounds.left + bounds.width * 0.3, bounds.bottom - 15);
    final sC = Offset(sA.dx, bounds.bottom - bounds.height * 0.45);
    canvas
      ..drawPath(
        Path()
          ..moveTo(sA.dx, sA.dy)
          ..lineTo(sB.dx, sB.dy)
          ..lineTo(sC.dx, sC.dy)
          ..close(),
        stroke,
      )
      ..drawRect(Rect.fromLTWH(sA.dx, sA.dy - 8, 8, 8), stroke);

    // Large triangle
    final lA = Offset(bounds.left + bounds.width * 0.45, bounds.bottom - 15);
    final lB = Offset(bounds.right - 15, bounds.bottom - 15);
    final lC = Offset(lA.dx, bounds.top + 15);
    canvas
      ..drawPath(
        Path()
          ..moveTo(lA.dx, lA.dy)
          ..lineTo(lB.dx, lB.dy)
          ..lineTo(lC.dx, lC.dy)
          ..close(),
        stroke,
      )
      ..drawRect(Rect.fromLTWH(lA.dx, lA.dy - 10, 10, 10), stroke);

    return [
      Offset(sA.dx - 14, (sA.dy + sC.dy) / 2),
      Offset((sA.dx + sB.dx) / 2 - 10, sA.dy + 6),
      Offset(lA.dx - 14, (lA.dy + lC.dy) / 2),
      Offset((lA.dx + lB.dx) / 2 - 10, lA.dy + 6),
      Offset(bounds.center.dx - 20, bounds.top - 12),
    ];
  }

  List<Offset> _drawSpecialRightTriangles(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
  ) {
    // 45-45-90
    final t1A = Offset(bounds.left + 20, bounds.bottom - 15);
    final t1B = Offset(bounds.left + bounds.width * 0.38, bounds.bottom - 15);
    final t1C = Offset(t1A.dx, bounds.bottom - 15 - bounds.width * 0.38);
    canvas
      ..drawPath(
        Path()
          ..moveTo(t1A.dx, t1A.dy)
          ..lineTo(t1B.dx, t1B.dy)
          ..lineTo(t1C.dx, t1C.dy)
          ..close(),
        stroke,
      )
      ..drawRect(Rect.fromLTWH(t1A.dx, t1A.dy - 8, 8, 8), stroke);

    // 30-60-90
    final t2A = Offset(bounds.left + bounds.width * 0.55, bounds.bottom - 15);
    final t2B = Offset(bounds.right - 15, bounds.bottom - 15);
    final t2C = Offset(t2A.dx, bounds.top + 15);
    canvas
      ..drawPath(
        Path()
          ..moveTo(t2A.dx, t2A.dy)
          ..lineTo(t2B.dx, t2B.dy)
          ..lineTo(t2C.dx, t2C.dy)
          ..close(),
        stroke,
      )
      ..drawRect(Rect.fromLTWH(t2A.dx, t2A.dy - 8, 8, 8), stroke);

    return [
      Offset(bounds.left + 15, bounds.top - 12),
      Offset(bounds.left + bounds.width * 0.5, bounds.top - 12),
    ];
  }

  List<Offset> _drawCoterminalAngles(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    // Plane 1
    final c1 = Offset(bounds.left + bounds.width * 0.25, bounds.center.dy);
    canvas
      ..drawLine(
        Offset(bounds.left + 10, c1.dy),
        Offset(bounds.left + bounds.width * 0.45, c1.dy),
        helper,
      )
      ..drawLine(
        Offset(c1.dx, bounds.top + 15),
        Offset(c1.dx, bounds.bottom - 15),
        helper,
      )
      ..drawLine(c1, Offset(c1.dx + 28, c1.dy - 24), stroke);

    // Plane 2
    final c2 = Offset(bounds.left + bounds.width * 0.75, bounds.center.dy);
    canvas
      ..drawLine(
        Offset(bounds.left + bounds.width * 0.55, c2.dy),
        Offset(bounds.right - 10, c2.dy),
        helper,
      )
      ..drawLine(
        Offset(c2.dx, bounds.top + 15),
        Offset(c2.dx, bounds.bottom - 15),
        helper,
      )
      ..drawLine(c2, Offset(c2.dx - 18, c2.dy + 30), stroke);

    return [
      Offset(bounds.left + 15, bounds.top - 12),
      Offset(bounds.left + bounds.width * 0.55, bounds.top - 12),
    ];
  }

  List<Offset> _drawUnitCircleQuadrants(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.4;
    canvas
      ..drawCircle(center, radius, stroke)
      ..drawLine(
        Offset(bounds.left + 10, center.dy),
        Offset(bounds.right - 10, center.dy),
        helper,
      )
      ..drawLine(
        Offset(center.dx, bounds.top + 10),
        Offset(center.dx, bounds.bottom - 10),
        helper,
      );
    return [
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.5),
      Offset(center.dx - radius * 0.8, center.dy - radius * 0.5),
      Offset(center.dx - radius * 0.8, center.dy + radius * 0.4),
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.4),
    ];
  }

  List<Offset> _drawUnitCircle(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final center = bounds.center;
    final radius = math.min(bounds.width, bounds.height) * 0.38;
    canvas
      ..drawCircle(center, radius, stroke)
      ..drawLine(
        Offset(bounds.left + 10, center.dy),
        Offset(bounds.right - 10, center.dy),
        helper,
      )
      ..drawLine(
        Offset(center.dx, bounds.top + 10),
        Offset(center.dx, bounds.bottom - 10),
        helper,
      )
      ..drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(-0.8),
          center.dy + radius * math.sin(-0.8),
        ),
        stroke,
      );
    return [
      Offset(center.dx + 10, center.dy - 12),
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.7),
      Offset(center.dx + radius + 4, center.dy + 4),
      Offset(center.dx + 4, bounds.top + 4),
      Offset(center.dx - 25, bounds.bottom - 14),
    ];
  }

  List<Offset> _drawElevationDepression(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final gL = Offset(bounds.left + 15, bounds.bottom - 15);
    final gR = Offset(bounds.right - 15, bounds.bottom - 15);
    final topL = Offset(bounds.left + 15, bounds.top + 20);
    final topR = Offset(bounds.right - 15, bounds.top + 20);

    canvas
      ..drawLine(gL, gR, helper)
      ..drawLine(topL, topR, helper)
      ..drawLine(
        gL,
        Offset(bounds.right - bounds.width * 0.3, bounds.top + 20),
        stroke,
      )
      ..drawLine(
        topL,
        Offset(bounds.right - bounds.width * 0.3, bounds.bottom - 15),
        stroke,
      );

    return [
      Offset(gL.dx + 10, gL.dy - 30),
      Offset(topL.dx + 10, topL.dy + 15),
      Offset(bounds.center.dx - 15, bounds.top - 12),
    ];
  }

  List<Offset> _drawTwoTrianglesElevation(
    Canvas canvas,
    Rect bounds,
    Paint stroke,
    Paint helper,
  ) {
    final groundL = Offset(bounds.left + 15, bounds.bottom - 15);
    final buildingBase = Offset(bounds.right - 25, bounds.bottom - 15);
    final buildingTop = Offset(buildingBase.dx, bounds.top + 15);
    final pA = Offset(bounds.left + 25, bounds.bottom - 15);
    final pB = Offset(bounds.left + bounds.width * 0.45, bounds.bottom - 15);

    canvas
      ..drawLine(groundL, buildingBase, helper)
      ..drawLine(buildingBase, buildingTop, stroke)
      ..drawLine(pA, buildingTop, stroke)
      ..drawLine(pB, buildingTop, stroke)
      ..drawRect(
        Rect.fromLTWH(buildingBase.dx - 10, buildingBase.dy - 10, 10, 10),
        stroke,
      );

    return [
      Offset(pA.dx - 6, pA.dy - 20),
      Offset(pB.dx - 6, pB.dy - 20),
      Offset((pA.dx + pB.dx) / 2 - 15, pA.dy + 4),
      Offset(buildingBase.dx - 25, (buildingBase.dy + buildingTop.dy) / 2),
    ];
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

  @override
  bool shouldRepaint(_GeometryDiagramPainter oldDelegate) =>
      oldDelegate.type != type ||
      !listEquals(oldDelegate.labels, labels) ||
      oldDelegate.ink != ink ||
      oldDelegate.faint != faint;
}
