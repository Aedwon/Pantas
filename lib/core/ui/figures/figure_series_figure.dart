import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A sequence of figures that change by a rule, with a blank at the end.
///
/// ```yaml
///     figureSpec:
///       kind: figure-series
///       items:
///         - form: square
///           line: 0          # a line inside, in degrees clockwise from up
///         - form: square
///           line: 45
///         - form: square
///           line: 90
///       blank: true
/// ```
///
/// An item may carry `size` (`small`, `medium`, `large`), `fill` (`black`,
/// `white`, or a fraction from 0 to 1), `dot` (a corner: `top-left`,
/// `top-right`, `bottom-left`, `bottom-right`, `top`), `dots` (a count),
/// `arrow` (`up`, `right`, `down`, `left`) and `edgeLines` (a count drawn
/// along the bottom edge).
///
/// **`blank` draws an empty frame with a question mark.** It is the cell the
/// student is answering about, and it must never contain the answer.
class FigureSeriesFigure extends StatelessWidget {
  const FigureSeriesFigure({
    required this.items,
    required this.blank,
    super.key,
  });

  static const kind = 'figure-series';

  static const forms = {'square', 'circle', 'triangle', 'pentagon', 'star'};
  static const sizes = {'small': 0.62, 'medium': 0.82, 'large': 1.0};
  static const corners = {
    'top-left',
    'top-right',
    'bottom-left',
    'bottom-right',
    'top',
  };
  static const arrows = {
    'up': 0.0,
    'right': 90.0,
    'down': 180.0,
    'left': 270.0,
  };

  final List<SeriesItem> items;
  final bool blank;

  /// Null when the spec cannot be read.
  static FigureSeriesFigure? fromSpec(Map<String, Object?> spec) {
    final raw = spec['items'];
    if (raw is! List || raw.length < 2 || raw.length > 5) return null;

    final blank = spec['blank'] ?? true;
    if (blank is! bool) return null;

    final items = <SeriesItem>[];
    for (final entry in raw) {
      if (entry is! Map) return null;
      final form = entry['form'];
      if (form is! String || !forms.contains(form)) return null;

      final size = entry['size'] ?? 'large';
      if (size is! String || !sizes.containsKey(size)) return null;

      double fill;
      final rawFill = entry['fill'] ?? 'white';
      if (rawFill == 'white') {
        fill = 0;
      } else if (rawFill == 'black') {
        fill = 1;
      } else if (rawFill is num && rawFill >= 0 && rawFill <= 1) {
        fill = rawFill.toDouble();
      } else {
        return null;
      }

      final dot = entry['dot'];
      if (dot != null && (dot is! String || !corners.contains(dot))) {
        return null;
      }

      final dots = entry['dots'] ?? 0;
      if (dots is! int || dots < 0 || dots > 5) return null;

      final edgeLines = entry['edgeLines'] ?? 0;
      if (edgeLines is! int || edgeLines < 0 || edgeLines > 5) return null;

      final line = entry['line'];
      if (line != null && line is! num) return null;

      final arrow = entry['arrow'];
      if (arrow != null && (arrow is! String || !arrows.containsKey(arrow))) {
        return null;
      }

      items.add(
        SeriesItem(
          form: form,
          scale: sizes[size]!,
          fill: fill,
          dotCorner: dot as String?,
          dots: dots,
          edgeLines: edgeLines,
          lineDegrees: (line as num?)?.toDouble(),
          arrowDegrees: arrow == null ? null : arrows[arrow],
        ),
      );
    }
    return FigureSeriesFigure(items: items, blank: blank);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Semantics(
      label: 'A sequence of ${items.length} figures'
          '${blank ? ', then an empty frame for the next one' : ''}.',
      child: SizedBox(
        height: 110,
        child: CustomPaint(
          painter: _SeriesPainter(
            items: items,
            blank: blank,
            ink: colors.ink,
            faint: colors.ruleFaint,
            markStyle: styles.headlineSmall.copyWith(color: colors.inkMuted),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// One figure in the sequence.
class SeriesItem {
  const SeriesItem({
    required this.form,
    required this.scale,
    required this.fill,
    required this.dots,
    required this.edgeLines,
    this.dotCorner,
    this.lineDegrees,
    this.arrowDegrees,
  });

  final String form;
  final double scale;
  final double fill;
  final String? dotCorner;
  final int dots;
  final int edgeLines;
  final double? lineDegrees;
  final double? arrowDegrees;
}

class _SeriesPainter extends CustomPainter {
  _SeriesPainter({
    required this.items,
    required this.blank,
    required this.ink,
    required this.faint,
    required this.markStyle,
  });

  final List<SeriesItem> items;
  final bool blank;
  final Color ink;
  final Color faint;
  final TextStyle markStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;
    final solid = Paint()
      ..style = PaintingStyle.fill
      ..color = ink;
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = faint;

    final cells = items.length + (blank ? 1 : 0);
    final slot = size.width / cells;
    final radius = math.min(slot * 0.34, size.height * 0.36);
    final cy = size.height / 2;

    for (var i = 0; i < items.length; i++) {
      _drawItem(
        canvas,
        items[i],
        Offset(slot * (i + 0.5), cy),
        radius,
        stroke,
        solid,
      );
    }

    if (!blank) return;
    // The empty frame, and a question mark inside it. It never holds the
    // answer: working that out is the question.
    final centre = Offset(slot * (cells - 0.5), cy);
    canvas.drawRect(
      Rect.fromCenter(center: centre, width: radius * 2, height: radius * 2),
      frame,
    );
    final mark = TextPainter(
      text: TextSpan(text: '?', style: markStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    mark.paint(
      canvas,
      centre - Offset(mark.width / 2, mark.height / 2),
    );
  }

  void _drawItem(
    Canvas canvas,
    SeriesItem item,
    Offset centre,
    double baseRadius,
    Paint stroke,
    Paint solid,
  ) {
    final r = baseRadius * item.scale;
    final path = _formPath(item.form, centre, r);

    if (item.fill >= 1) {
      canvas.drawPath(path, solid);
    } else if (item.fill > 0) {
      // A part-filled shape: clip to the shape and fill from the bottom up,
      // which is how these questions describe a quarter or a half full.
      canvas
        ..save()
        ..clipPath(path)
        ..drawRect(
          Rect.fromLTRB(
            centre.dx - r,
            centre.dy + r - (r * 2 * item.fill),
            centre.dx + r,
            centre.dy + r,
          ),
          solid,
        )
        ..restore();
    }
    canvas.drawPath(path, stroke);

    final line = item.lineDegrees;
    if (line != null) {
      final angle = (line - 90) * math.pi / 180;
      canvas.drawLine(
        centre,
        centre + Offset(math.cos(angle) * r * 0.8, math.sin(angle) * r * 0.8),
        stroke,
      );
    }

    final arrow = item.arrowDegrees;
    if (arrow != null) {
      final angle = (arrow - 90) * math.pi / 180;
      final tip =
          centre + Offset(math.cos(angle) * r * 0.7, math.sin(angle) * r * 0.7);
      canvas.drawLine(centre, tip, stroke);
      for (final spread in [2.5, -2.5]) {
        canvas.drawLine(
          tip,
          tip +
              Offset(
                math.cos(angle + spread) * r * 0.3,
                math.sin(angle + spread) * r * 0.3,
              ),
          stroke,
        );
      }
    }

    final corner = item.dotCorner;
    if (corner != null) {
      final offset = switch (corner) {
        'top-left' => Offset(-r * 0.6, -r * 0.6),
        'top-right' => Offset(r * 0.6, -r * 0.6),
        'bottom-left' => Offset(-r * 0.6, r * 0.6),
        'bottom-right' => Offset(r * 0.6, r * 0.6),
        _ => Offset(0, -r * 0.6),
      };
      canvas.drawCircle(centre + offset, 3, solid);
    }

    if (item.dots > 0) {
      final spread = r * 0.5;
      final first = centre.dx - spread * (item.dots - 1) / 2;
      for (var i = 0; i < item.dots; i++) {
        canvas.drawCircle(Offset(first + spread * i, centre.dy), 2.5, solid);
      }
    }

    if (item.edgeLines > 0) {
      final step = (r * 1.4) / (item.edgeLines + 1);
      for (var i = 1; i <= item.edgeLines; i++) {
        final x = centre.dx - r * 0.7 + step * i;
        canvas.drawLine(
          Offset(x, centre.dy + r),
          Offset(x, centre.dy + r + 6),
          stroke,
        );
      }
    }
  }

  Path _formPath(String form, Offset centre, double r) {
    switch (form) {
      case 'circle':
        return Path()..addOval(Rect.fromCircle(center: centre, radius: r));
      case 'square':
        return Path()..addRect(Rect.fromCircle(center: centre, radius: r));
      case 'triangle':
        return _polygon(centre, r, 3, -math.pi / 2);
      case 'pentagon':
        return _polygon(centre, r, 5, -math.pi / 2);
      default:
        return _star(centre, r);
    }
  }

  Path _polygon(Offset centre, double r, int sides, double start) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = start + i * 2 * math.pi / sides;
      final point = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Path _star(Offset centre, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final radius = i.isEven ? r : r * 0.42;
      final point =
          centre + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_SeriesPainter old) =>
      old.ink != ink || old.items.length != items.length || old.blank != blank;
}
