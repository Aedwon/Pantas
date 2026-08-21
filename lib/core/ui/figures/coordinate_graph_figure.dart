import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Axes and authored curves for algebra, calculus, projectile,
/// and conic lessons.
class CoordinateGraphFigure extends StatelessWidget {
  const CoordinateGraphFigure({
    required this.type,
    required this.points,
    this.formula,
    this.shaded,
    this.radius,
    this.hole,
    this.asymptoteSlopes,
    this.functions,
    this.conics,
    this.discontinuities,
    this.initialVelocity,
    this.labels,
    this.velocityVectors,
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
    'vertical-line-test',
    'rational',
    'conic-gallery',
    'limits-gallery',
    'limit-hole',
    'piecewise',
    'projectile-motion',
    'horizontal-projectile',
  };

  final String type;
  final String? formula;
  final List<Offset> points;
  final String? shaded;
  final double? radius;
  final Offset? hole;
  final List<double>? asymptoteSlopes;
  final List<String>? functions;
  final List<String>? conics;
  final List<String>? discontinuities;
  final String? initialVelocity;
  final Map<String, String>? labels;
  final bool? velocityVectors;

  static CoordinateGraphFigure? fromSpec(Map<String, Object?> spec) {
    final type = spec['type'];
    if (type is! String || !_types.contains(type)) return null;

    final formula = spec['formula'];
    if (formula != null && formula is! String) return null;

    final shaded = spec['shaded'];
    if (shaded != null && shaded is! String) return null;

    final rawRadius = spec['radius'];
    final double? radius;
    if (rawRadius != null) {
      if (rawRadius is! num || !rawRadius.isFinite) return null;
      radius = rawRadius.toDouble();
    } else {
      radius = null;
    }

    final rawHole = spec['hole'];
    final Offset? hole;
    if (rawHole != null) {
      if (rawHole is! List || rawHole.length != 2) return null;
      final x = rawHole[0];
      final y = rawHole[1];
      if (x is! num || y is! num || !x.isFinite || !y.isFinite) return null;
      hole = Offset(x.toDouble(), y.toDouble());
    } else {
      hole = null;
    }

    final rawSlopes = spec['asymptoteSlopes'];
    List<double>? asymptoteSlopes;
    if (rawSlopes != null) {
      if (rawSlopes is! List) return null;
      asymptoteSlopes = <double>[];
      for (final s in rawSlopes) {
        if (s is! num || !s.isFinite) return null;
        asymptoteSlopes.add(s.toDouble());
      }
    }

    final rawFunctions = spec['functions'];
    List<String>? functions;
    if (rawFunctions != null) {
      if (rawFunctions is! List) return null;
      functions = <String>[];
      for (final f in rawFunctions) {
        if (f is! String) return null;
        functions.add(f);
      }
    }

    final rawConics = spec['conics'];
    List<String>? conics;
    if (rawConics != null) {
      if (rawConics is! List) return null;
      conics = <String>[];
      for (final c in rawConics) {
        if (c is! String) return null;
        conics.add(c);
      }
    }

    final rawDiscontinuities = spec['discontinuities'];
    List<String>? discontinuities;
    if (rawDiscontinuities != null) {
      if (rawDiscontinuities is! List) return null;
      discontinuities = <String>[];
      for (final d in rawDiscontinuities) {
        if (d is! String) return null;
        discontinuities.add(d);
      }
    }

    final initialVelocity = spec['initialVelocity'];
    if (initialVelocity != null && initialVelocity is! String) return null;

    final rawLabels = spec['labels'];
    Map<String, String>? labels;
    if (rawLabels != null) {
      if (rawLabels is! Map) return null;
      labels = <String, String>{};
      for (final entry in rawLabels.entries) {
        if (entry.key is! String || entry.value is! String) return null;
        labels[entry.key as String] = entry.value as String;
      }
    }

    final velocityVectors = spec['velocityVectors'];
    if (velocityVectors != null && velocityVectors is! bool) return null;

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
      shaded: shaded as String?,
      radius: radius,
      hole: hole,
      asymptoteSlopes: asymptoteSlopes,
      functions: functions,
      conics: conics,
      discontinuities: discontinuities,
      initialVelocity: initialVelocity as String?,
      labels: labels,
      velocityVectors: velocityVectors as bool?,
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
            shaded: shaded,
            radius: radius,
            hole: hole,
            asymptoteSlopes: asymptoteSlopes,
            functions: functions,
            conics: conics,
            discontinuities: discontinuities,
            initialVelocity: initialVelocity,
            labels: labels,
            velocityVectors: velocityVectors,
            ink: colors.ink,
            faint: colors.ruleFaint,
            background: colors.background,
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
    required this.background,
    required this.labelStyle,
    this.formula,
    this.shaded,
    this.radius,
    this.hole,
    this.asymptoteSlopes,
    this.functions,
    this.conics,
    this.discontinuities,
    this.initialVelocity,
    this.labels,
    this.velocityVectors,
  });

  final String type;
  final String? formula;
  final List<Offset> points;
  final String? shaded;
  final double? radius;
  final Offset? hole;
  final List<double>? asymptoteSlopes;
  final List<String>? functions;
  final List<String>? conics;
  final List<String>? discontinuities;
  final String? initialVelocity;
  final Map<String, String>? labels;
  final bool? velocityVectors;

  final Color ink;
  final Color faint;
  final Color background;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'vertical-line-test':
        _drawVerticalLineTest(canvas, size);
        return;
      case 'function-gallery':
        _drawFunctionGallery(canvas, size);
        return;
      case 'conic-gallery':
        _drawConicGallery(canvas, size);
        return;
      case 'limits-gallery':
        _drawLimitsGallery(canvas, size);
        return;
      case 'projectile-motion':
        _drawProjectileMotion(canvas, size);
        return;
      case 'horizontal-projectile':
        _drawHorizontalProjectile(canvas, size);
        return;
    }

    const inset = 24.0;
    final graph =
        Rect.fromLTRB(inset, 16, size.width - 16, size.height - inset);
    final grid = Paint()
      ..color = faint
      ..strokeWidth = 1;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final dashedStroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final fill = Paint()
      ..color = ink
      ..style = PaintingStyle.fill;
    final faintFill = Paint()
      ..color = faint
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
        final r = radius ?? 5.0;
        final c = points.isNotEmpty ? points.first : Offset.zero;
        final centerMapped = map(c.dx, c.dy);
        final rPx = r * graph.width / 12;
        canvas.drawCircle(centerMapped, rPx, stroke);
        canvas.drawLine(
          centerMapped,
          Offset(centerMapped.dx + rPx, centerMapped.dy),
          stroke,
        );
        _drawText(
          canvas,
          'r = ${r.toInt()}',
          Offset(centerMapped.dx + rPx / 2, centerMapped.dy - 14),
        );
        if (points.isNotEmpty) {
          _drawText(
            canvas,
            '(${c.dx.toInt()}, ${c.dy.toInt()})',
            Offset(centerMapped.dx + 4, centerMapped.dy + 4),
          );
        }

      case 'ellipse':
        canvas.drawOval(
          Rect.fromCenter(
            center: origin,
            width: graph.width * 0.75,
            height: graph.height * 0.45,
          ),
          stroke,
        );

      case 'hyperbola':
        _drawHyperbola(canvas, graph, origin, stroke);
        if (asymptoteSlopes != null) {
          for (final s in asymptoteSlopes!) {
            _drawDashedLine(
              canvas,
              map(-5, -5 * s),
              map(5, 5 * s),
              grid,
            );
          }
        }

      case 'parabola':
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

      case 'integral-area':
        final path = Path();
        final xStart = points.isNotEmpty ? points.first.dx : 1.0;
        final xEnd = points.length > 1 ? points[1].dx : 4.0;
        final pStart = map(xStart, 0);
        path.moveTo(pStart.dx, pStart.dy);
        for (var i = 0; i <= 40; i++) {
          final x = xStart + (xEnd - xStart) * i / 40;
          final y = -(x - 1) * (x - 5) * 0.6;
          final p = map(x, math.max(0, y));
          path.lineTo(p.dx, p.dy);
        }
        final pEnd = map(xEnd, 0);
        path
          ..lineTo(pEnd.dx, pEnd.dy)
          ..close();
        canvas.drawPath(path, faintFill);

        final fullCurve = Path();
        for (var i = 0; i <= 60; i++) {
          final x = 0.5 + i * 5.0 / 60;
          final y = -(x - 1) * (x - 5) * 0.6;
          final p = map(x, y);
          if (i == 0) {
            fullCurve.moveTo(p.dx, p.dy);
          } else {
            fullCurve.lineTo(p.dx, p.dy);
          }
        }
        canvas.drawPath(fullCurve, stroke);
        _drawText(canvas, 'x = a', Offset(pStart.dx - 10, pStart.dy + 4));
        _drawText(canvas, 'x = b', Offset(pEnd.dx - 10, pEnd.dy + 4));

      case 'linear-inequality':
        final p1 = points.isNotEmpty ? points.first : const Offset(0, 3);
        final p2 = points.length > 1 ? points[1] : const Offset(3, 0);
        final shadePath = Path()
          ..moveTo(graph.left, origin.dy)
          ..lineTo(map(p1.dx, p1.dy).dx, map(p1.dx, p1.dy).dy)
          ..lineTo(map(p2.dx, p2.dy).dx, map(p2.dx, p2.dy).dy)
          ..lineTo(graph.left, graph.bottom)
          ..close();
        canvas.drawPath(shadePath, faintFill);
        _drawDashedLine(
          canvas,
          map(-2, 5),
          map(5, -2),
          dashedStroke,
        );

      case 'system':
        if (points.length == 1) {
          canvas
            ..drawLine(map(-2, -1), map(5, 6), stroke)
            ..drawLine(map(-1, 8), map(6, 1), stroke);
        } else {
          final parabolaPath = Path();
          for (var i = 0; i <= 80; i++) {
            final x = -3.0 + i * 6.0 / 80;
            final y = x * x - 4;
            final pt = map(x, y);
            if (i == 0) {
              parabolaPath.moveTo(pt.dx, pt.dy);
            } else {
              parabolaPath.lineTo(pt.dx, pt.dy);
            }
          }
          canvas
            ..drawPath(parabolaPath, stroke)
            ..drawLine(map(-0.5, -7.5), map(3.5, 4.5), stroke);
        }

      case 'rational':
        _drawDashedLine(
          canvas,
          Offset(map(2, 0).dx, graph.top),
          Offset(map(2, 0).dx, graph.bottom),
          grid,
        );
        _drawDashedLine(
          canvas,
          Offset(graph.left, map(0, 1).dy),
          Offset(graph.right, map(0, 1).dy),
          grid,
        );
        final leftBranch = Path();
        for (var i = 0; i <= 40; i++) {
          final x = -5.0 + i * 6.8 / 40;
          final y = (x + 1) / (x - 2);
          final pt = map(x, y);
          if (i == 0) {
            leftBranch.moveTo(pt.dx, pt.dy);
          } else {
            leftBranch.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(leftBranch, stroke);

        final rightBranch = Path();
        for (var i = 0; i <= 40; i++) {
          final x = 2.2 + i * 4.0 / 40;
          final y = (x + 1) / (x - 2);
          final pt = map(x, y);
          if (i == 0) {
            rightBranch.moveTo(pt.dx, pt.dy);
          } else {
            rightBranch.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(rightBranch, stroke);
        _drawText(canvas, 'x = 2', Offset(map(2, 0).dx + 4, graph.top + 4));
        _drawText(canvas, 'y = 1', Offset(graph.left + 4, map(0, 1).dy - 16));

      case 'limit-hole':
        canvas.drawLine(map(-3, 0), map(5, 8), stroke);
        final h =
            hole ?? (points.isNotEmpty ? points.first : const Offset(3, 6));
        final holePt = map(h.dx, h.dy);
        _drawDashedLine(canvas, holePt, Offset(holePt.dx, origin.dy), grid);
        _drawDashedLine(canvas, holePt, Offset(origin.dx, holePt.dy), grid);
        canvas
          ..drawCircle(holePt, 4, Paint()..color = background)
          ..drawCircle(holePt, 4, stroke);
        _drawText(
          canvas,
          '(${h.dx.toInt()}, ${h.dy.toInt()})',
          Offset(holePt.dx + 6, holePt.dy - 6),
        );

      case 'piecewise':
        final leftPiece = Path();
        for (var i = 0; i <= 40; i++) {
          final x = -3.0 + i * 4.0 / 40;
          final y = x * x + 1;
          final pt = map(x, y);
          if (i == 0) {
            leftPiece.moveTo(pt.dx, pt.dy);
          } else {
            leftPiece.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(leftPiece, stroke);
        canvas.drawLine(map(1, 2), map(4, 5), stroke);
        canvas.drawCircle(map(1, 2), 3.5, fill);
        _drawText(canvas, '(1, 2)', Offset(map(1, 2).dx + 6, map(1, 2).dy - 6));

      case 'line' || 'axes':
        final drawn =
            points.length >= 2 ? points : const [Offset(-4, -2), Offset(4, 2)];
        canvas.drawLine(
          map(drawn.first.dx, drawn.first.dy),
          map(drawn.last.dx, drawn.last.dy),
          stroke,
        );
    }

    if (type != 'limit-hole' && type != 'circle') {
      for (final point in points) {
        final pt = map(point.dx, point.dy);
        canvas.drawCircle(pt, 3, fill);
        _drawText(
          canvas,
          '(${point.dx.toInt()}, ${point.dy.toInt()})',
          Offset(pt.dx + 4, pt.dy - 12),
        );
      }
    }

    final label = formula;
    if (label != null && label.isNotEmpty) {
      _drawText(canvas, label, Offset(graph.left + 4, graph.top + 4));
    }
  }

  void _drawVerticalLineTest(Canvas canvas, Size size) {
    final halfWidth = size.width / 2;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint()
      ..color = ink
      ..style = PaintingStyle.fill;

    // Left graph (Passes)
    final leftRect = Rect.fromLTWH(12, 28, halfWidth - 24, size.height - 44);
    _drawMiniAxes(canvas, leftRect, faintStroke);
    _drawText(canvas, 'Passes (Function)', Offset(leftRect.left, 8));
    final passPath = Path();
    for (var i = 0; i <= 30; i++) {
      final t = -1.5 + i * 3.0 / 30;
      final x = leftRect.center.dx + t * (leftRect.width * 0.28);
      final y =
          leftRect.center.dy - (t * t * 0.8 - 0.8) * (leftRect.height * 0.35);
      if (i == 0) {
        passPath.moveTo(x, y);
      } else {
        passPath.lineTo(x, y);
      }
    }
    canvas.drawPath(passPath, stroke);
    final vLineX = leftRect.center.dx + leftRect.width * 0.15;
    _drawDashedLine(
      canvas,
      Offset(vLineX, leftRect.top),
      Offset(vLineX, leftRect.bottom),
      stroke,
    );
    canvas.drawCircle(
      Offset(
        vLineX,
        leftRect.center.dy -
            (0.15 * 0.15 * 0.8 - 0.8) * (leftRect.height * 0.35),
      ),
      3,
      fill,
    );

    // Right graph (Fails)
    final rightRect =
        Rect.fromLTWH(halfWidth + 12, 28, halfWidth - 24, size.height - 44);
    _drawMiniAxes(canvas, rightRect, faintStroke);
    _drawText(
      canvas,
      'Fails (Not a function)',
      Offset(rightRect.left, 8),
    );
    final failPath = Path();
    for (var i = 0; i <= 30; i++) {
      final t = -1.5 + i * 3.0 / 30;
      final y = rightRect.center.dy + t * (rightRect.height * 0.28);
      final x =
          rightRect.center.dx + (t * t * 0.8 - 0.8) * (rightRect.width * 0.35);
      if (i == 0) {
        failPath.moveTo(x, y);
      } else {
        failPath.lineTo(x, y);
      }
    }
    canvas.drawPath(failPath, stroke);
    final vLineX2 = rightRect.center.dx + rightRect.width * 0.15;
    _drawDashedLine(
      canvas,
      Offset(vLineX2, rightRect.top),
      Offset(vLineX2, rightRect.bottom),
      stroke,
    );
    final yHit1 = rightRect.center.dy -
        math.sqrt((0.15 + 0.8 / (rightRect.width * 0.35)) / 0.8) *
            (rightRect.height * 0.28);
    final yHit2 = rightRect.center.dy +
        math.sqrt((0.15 + 0.8 / (rightRect.width * 0.35)) / 0.8) *
            (rightRect.height * 0.28);
    canvas
      ..drawCircle(
        Offset(vLineX2, yHit1.isFinite ? yHit1 : rightRect.center.dy - 18),
        3,
        fill,
      )
      ..drawCircle(
        Offset(vLineX2, yHit2.isFinite ? yHit2 : rightRect.center.dy + 18),
        3,
        fill,
      );
  }

  void _drawFunctionGallery(Canvas canvas, Size size) {
    final names = functions ??
        [
          'Linear',
          'Quadratic',
          'Rational',
          'Abs Val',
          'Exp',
          'Log',
          'Piecewise',
        ];
    final count = names.length;
    final slotW = size.width / count;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < count; i++) {
      final box = Rect.fromLTWH(slotW * i + 4, 10, slotW - 8, size.height - 36);
      _drawMiniAxes(canvas, box, faintStroke);
      _drawText(canvas, names[i], Offset(box.left + 2, size.height - 20));
      final path = Path();
      final c = box.center;
      switch (i) {
        case 0:
          canvas.drawLine(
            Offset(box.left + 4, box.bottom - 4),
            Offset(box.right - 4, box.top + 4),
            stroke,
          );
        case 1:
          for (var j = 0; j <= 20; j++) {
            final t = -1.0 + j * 2.0 / 20;
            final pt = Offset(
              c.dx + t * box.width * 0.38,
              c.dy - (t * t - 0.5) * box.height * 0.6,
            );
            if (j == 0) {
              path.moveTo(pt.dx, pt.dy);
            } else {
              path.lineTo(pt.dx, pt.dy);
            }
          }
          canvas.drawPath(path, stroke);
        case 2:
          canvas.drawLine(
            Offset(c.dx, box.top),
            Offset(c.dx, box.bottom),
            faintStroke,
          );
          final p1 = Path()
            ..moveTo(box.left + 2, c.dy + box.height * 0.25)
            ..quadraticBezierTo(c.dx - 4, c.dy + 4, c.dx - 4, box.bottom - 2);
          final p2 = Path()
            ..moveTo(c.dx + 4, box.top + 2)
            ..quadraticBezierTo(
              c.dx + 4,
              c.dy - 4,
              box.right - 2,
              c.dy - box.height * 0.25,
            );
          canvas
            ..drawPath(p1, stroke)
            ..drawPath(p2, stroke);
        case 3:
          path
            ..moveTo(box.left + 4, box.top + 8)
            ..lineTo(c.dx, box.bottom - 6)
            ..lineTo(box.right - 4, box.top + 8);
          canvas.drawPath(path, stroke);
        case 4:
          for (var j = 0; j <= 20; j++) {
            final t = -1.0 + j * 2.0 / 20;
            final pt = Offset(
              c.dx + t * box.width * 0.38,
              c.dy - (math.exp(t * 1.5) - 1.0) * box.height * 0.3,
            );
            if (j == 0) {
              path.moveTo(pt.dx, pt.dy);
            } else {
              path.lineTo(pt.dx, pt.dy);
            }
          }
          canvas.drawPath(path, stroke);
        case 5:
          for (var j = 1; j <= 20; j++) {
            final t = j / 20;
            final pt = Offset(
              c.dx + (t * 2.0 - 1.0) * box.width * 0.38,
              c.dy - math.log(t * 3.0) * box.height * 0.25,
            );
            if (j == 1) {
              path.moveTo(pt.dx, pt.dy);
            } else {
              path.lineTo(pt.dx, pt.dy);
            }
          }
          canvas.drawPath(path, stroke);
        case 6:
          canvas
            ..drawLine(
              Offset(box.left + 4, c.dy + 10),
              Offset(c.dx, c.dy + 10),
              stroke,
            )
            ..drawLine(
              Offset(c.dx, c.dy - 10),
              Offset(box.right - 4, box.top + 4),
              stroke,
            );
      }
    }
  }

  void _drawConicGallery(Canvas canvas, Size size) {
    final names = conics ?? ['Circle', 'Parabola', 'Ellipse', 'Hyperbola'];
    final slotW = size.width / names.length;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < names.length; i++) {
      final box =
          Rect.fromLTWH(slotW * i + 8, 16, slotW - 16, size.height - 48);
      _drawMiniAxes(canvas, box, faintStroke);
      _drawText(canvas, names[i], Offset(box.left + 4, size.height - 24));
      final c = box.center;
      switch (i) {
        case 0:
          canvas.drawCircle(c, box.height * 0.3, stroke);
        case 1:
          final p = Path();
          for (var j = 0; j <= 20; j++) {
            final t = -1.0 + j * 2.0 / 20;
            final pt = Offset(
              c.dx + t * box.width * 0.35,
              c.dy - (t * t - 0.5) * box.height * 0.55,
            );
            if (j == 0) {
              p.moveTo(pt.dx, pt.dy);
            } else {
              p.lineTo(pt.dx, pt.dy);
            }
          }
          canvas.drawPath(p, stroke);
        case 2:
          canvas.drawOval(
            Rect.fromCenter(
              center: c,
              width: box.width * 0.7,
              height: box.height * 0.42,
            ),
            stroke,
          );
        case 3:
          for (final side in [-1.0, 1.0]) {
            final hp = Path();
            for (var j = 0; j <= 20; j++) {
              final t = -1.0 + j * 2.0 / 20;
              final cosht = (math.exp(t) + math.exp(-t)) / 2;
              final sinht = (math.exp(t) - math.exp(-t)) / 2;
              final pt = Offset(
                c.dx + side * (cosht * 0.3) * box.width,
                c.dy - (sinht * 0.3) * box.height,
              );
              if (j == 0) {
                hp.moveTo(pt.dx, pt.dy);
              } else {
                hp.lineTo(pt.dx, pt.dy);
              }
            }
            canvas.drawPath(hp, stroke);
          }
      }
    }
  }

  void _drawLimitsGallery(Canvas canvas, Size size) {
    final names = discontinuities ?? ['Hole', 'Jump', 'Asymptote'];
    final slotW = size.width / names.length;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < names.length; i++) {
      final box =
          Rect.fromLTWH(slotW * i + 8, 16, slotW - 16, size.height - 48);
      _drawMiniAxes(canvas, box, faintStroke);
      _drawText(canvas, names[i], Offset(box.left + 4, size.height - 24));
      final c = box.center;
      switch (i) {
        case 0:
          canvas
            ..drawLine(
              Offset(box.left + 4, box.bottom - 8),
              Offset(box.right - 4, box.top + 8),
              stroke,
            )
            ..drawCircle(c, 4, Paint()..color = background)
            ..drawCircle(c, 4, stroke);
        case 1:
          canvas
            ..drawLine(
              Offset(box.left + 4, c.dy + 12),
              Offset(c.dx, c.dy + 12),
              stroke,
            )
            ..drawCircle(Offset(c.dx, c.dy + 12), 3, Paint()..color = ink)
            ..drawLine(
              Offset(c.dx, c.dy - 12),
              Offset(box.right - 4, c.dy - 12),
              stroke,
            )
            ..drawCircle(
              Offset(c.dx, c.dy - 12),
              3,
              Paint()..color = background,
            )
            ..drawCircle(Offset(c.dx, c.dy - 12), 3, stroke);
        case 2:
          _drawDashedLine(
            canvas,
            Offset(c.dx, box.top),
            Offset(c.dx, box.bottom),
            faintStroke,
          );
          final p1 = Path()
            ..moveTo(box.left + 4, c.dy + 10)
            ..quadraticBezierTo(c.dx - 3, c.dy + 10, c.dx - 3, box.bottom - 4);
          final p2 = Path()
            ..moveTo(c.dx + 3, box.top + 4)
            ..quadraticBezierTo(c.dx + 3, c.dy - 10, box.right - 4, c.dy - 10);
          canvas
            ..drawPath(p1, stroke)
            ..drawPath(p2, stroke);
      }
    }
  }

  void _drawProjectileMotion(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final groundY = size.height - 30;
    canvas.drawLine(
      Offset(20, groundY),
      Offset(size.width - 20, groundY),
      faintStroke,
    );

    final path = Path();
    final start = Offset(40, groundY);
    final peak = Offset(size.width / 2, 45);
    final end = Offset(size.width - 40, groundY);

    path
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        peak.dx,
        peak.dy - (groundY - peak.dy),
        end.dx,
        end.dy,
      );
    canvas.drawPath(path, stroke);

    // Draw velocity vector components along the trajectory
    final points = [
      (Offset(80, groundY - 50), 30.0, -25.0),
      (Offset(size.width / 2, peak.dy), 30.0, 0.0),
      (Offset(size.width - 80, groundY - 50), 30.0, 25.0),
    ];

    for (final (pt, vx, vy) in points) {
      _drawArrow(canvas, pt, Offset(pt.dx + vx, pt.dy), stroke);
      _drawText(canvas, 'vx', Offset(pt.dx + vx + 2, pt.dy - 8));
      if (vy.abs() > 1) {
        _drawArrow(canvas, pt, Offset(pt.dx, pt.dy + vy), stroke);
        _drawText(canvas, 'vy', Offset(pt.dx + 4, pt.dy + vy - 4));
      }
    }
  }

  void _drawHorizontalProjectile(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final groundY = size.height - 24;
    const tableTopY = 60.0;
    const tableRightX = 90.0;

    // Table
    canvas
      ..drawRect(
        Rect.fromLTRB(20, tableTopY, tableRightX, groundY),
        faintStroke,
      )
      ..drawLine(
        Offset(20, groundY),
        Offset(size.width - 20, groundY),
        stroke,
      )
      ..drawCircle(
        const Offset(84, 54),
        6,
        Paint()..color = ink,
      );
    // Launch arrow
    _drawArrow(
      canvas,
      const Offset(90, 54),
      const Offset(135, 54),
      stroke,
    );
    _drawText(canvas, '3 m/s', const Offset(102, 38));

    // Projectile curve
    final landingX = size.width - 60;
    final curve = Path()
      ..moveTo(tableRightX, tableTopY)
      ..quadraticBezierTo(landingX - 30, tableTopY, landingX, groundY);
    canvas.drawPath(curve, stroke);

    // Height dimension '?'
    _drawDashedLine(
      canvas,
      const Offset(100, 60),
      Offset(100, groundY),
      faintStroke,
    );
    _drawText(
      canvas,
      'h = ?',
      Offset(tableRightX + 14, (tableTopY + groundY) / 2),
    );

    // Range dimension '?'
    _drawDashedLine(
      canvas,
      Offset(tableRightX, groundY + 12),
      Offset(landingX, groundY + 12),
      faintStroke,
    );
    _drawText(
      canvas,
      'd = ?',
      Offset((tableRightX + landingX) / 2, groundY + 8),
    );
  }

  void _drawMiniAxes(Canvas canvas, Rect box, Paint paint) {
    canvas
      ..drawLine(
        Offset(box.left, box.center.dy),
        Offset(box.right, box.center.dy),
        paint,
      )
      ..drawLine(
        Offset(box.center.dx, box.top),
        Offset(box.center.dx, box.bottom),
        paint,
      );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final distance = (p2 - p1).distance;
    final count = (distance / 6).floor();
    for (var i = 0; i < count; i += 2) {
      final start = p1 + (p2 - p1) * (i / count);
      final end = p1 + (p2 - p1) * ((i + 1) / count);
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const len = 6.0;
    for (final turn in [-0.4, 0.4]) {
      canvas.drawLine(
        to,
        to - Offset(math.cos(angle + turn) * len, math.sin(angle + turn) * len),
        paint,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, offset);
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
      oldDelegate.shaded != shaded ||
      oldDelegate.radius != radius ||
      oldDelegate.hole != hole ||
      !listEquals(oldDelegate.asymptoteSlopes, asymptoteSlopes) ||
      !listEquals(oldDelegate.functions, functions) ||
      !listEquals(oldDelegate.conics, conics) ||
      !listEquals(oldDelegate.discontinuities, discontinuities) ||
      oldDelegate.initialVelocity != initialVelocity ||
      !mapEquals(oldDelegate.labels, labels) ||
      oldDelegate.velocityVectors != velocityVectors ||
      oldDelegate.ink != ink ||
      oldDelegate.faint != faint ||
      oldDelegate.background != background;
}
