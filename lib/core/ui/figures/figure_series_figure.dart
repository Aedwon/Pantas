import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

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
      final item = parseItem(entry);
      if (item == null) return null;
      items.add(item);
    }
    return FigureSeriesFigure(items: items, blank: blank);
  }

  /// Draws one figure, shared with the matrix so both look the same.
  static void paintItem(
    Canvas canvas,
    SeriesItem item,
    Offset centre,
    double radius,
    SeriesPalette palette,
  ) {
    _SeriesPainter(
      items: const [],
      blank: false,
      palette: palette,
      markStyle: const TextStyle(),
    )._drawItem(canvas, item, centre, radius);
  }

  /// One cell, shared with the matrix figure so both read the same shape.
  /// Null when it cannot be read.
  static SeriesItem? parseItem(Object? entry) {
    {
      if (entry is! Map) return null;
      final form = entry['form'];
      if (form is! String || !forms.contains(form)) return null;

      final size = entry['size'] ?? 'large';
      if (size is! String || !sizes.containsKey(size)) return null;

      double fill;
      final rawFill = entry['fill'] ?? 'white';
      final namesFill = rawFill == 'white' || rawFill == 'black';
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
      final rawLines = entry['lines'];
      if (line != null && rawLines != null) return null;
      final lineDegrees = <double>[];
      if (line != null) {
        if (line is! num || !line.toDouble().isFinite) return null;
        lineDegrees.add(line.toDouble());
      }
      if (rawLines != null) {
        if (rawLines is! List || rawLines.isEmpty || rawLines.length > 4) {
          return null;
        }
        for (final value in rawLines) {
          if (value is! num || !value.toDouble().isFinite) return null;
          lineDegrees.add(value.toDouble());
        }
      }

      final rotation = entry['rotation'] ?? 0;
      if (rotation is! num || !rotation.toDouble().isFinite) return null;

      final arrow = entry['arrow'];
      if (arrow != null && (arrow is! String || !arrows.containsKey(arrow))) {
        return null;
      }

      return SeriesItem(
        form: form,
        scale: sizes[size]!,
        fill: fill,
        namesFill: namesFill && entry.containsKey('fill'),
        dotCorner: dot as String?,
        dots: dots,
        edgeLines: edgeLines,
        allLineDegrees: lineDegrees,
        rotationDegrees: rotation.toDouble(),
        arrowDegrees: arrow == null ? null : arrows[arrow],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.type;
    final palette = SeriesPalette.of(context, items);
    return Semantics(
      label: 'A sequence of ${items.length} figures'
          '${blank ? ', then an empty frame for the next one' : ''}.',
      child: SizedBox(
        height: 110,
        child: CustomPaint(
          painter: _SeriesPainter(
            items: items,
            blank: blank,
            palette: palette,
            markStyle: styles.emphasized.copyWith(color: palette.mark),
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
    required this.allLineDegrees,
    required this.rotationDegrees,
    this.namesFill = false,
    this.dotCorner,
    this.arrowDegrees,
  });

  final String form;
  final double scale;
  final double fill;

  /// True when the spec says `black` or `white` in words. Those figures
  /// are drawn on a fixed panel so the words stay true in dark mode.
  final bool namesFill;
  final String? dotCorner;
  final int dots;
  final int edgeLines;
  final List<double> allLineDegrees;
  final double rotationDegrees;
  final double? arrowDegrees;

  double? get lineDegrees =>
      allLineDegrees.isEmpty ? null : allLineDegrees.first;
}

/// The colors a series or a matrix is drawn in.
///
/// **Words stay true in dark mode.** A spec that says `black` or `white`
/// is drawn on a fixed light panel, because theme ink is near white in dark
/// mode and a "black circle" would turn into a white one.
class SeriesPalette {
  const SeriesPalette({
    required this.ink,
    required this.paper,
    required this.frame,
    required this.mark,
    this.panel = false,
  });

  /// The theme palette, or the fixed panel in dark mode when [items] name
  /// black or white fill.
  factory SeriesPalette.of(BuildContext context, Iterable<SeriesItem?> items) {
    final colors = context.colors;
    final dark = colors.background.computeLuminance() < 0.5;
    if (dark && items.any((item) => item != null && item.namesFill)) {
      return fixed;
    }
    return SeriesPalette(
      ink: colors.label,
      paper: colors.background,
      frame: colors.fill,
      mark: colors.secondaryLabel,
    );
  }

  /// Outlines, marks and black fill.
  final Color ink;

  /// The ground. Marks that lie over fill are drawn in this color.
  final Color paper;

  /// The empty frame and the matrix grid, faint as in light mode.
  final Color frame;

  /// The question mark.
  final Color mark;

  /// True when the figure sits on its own fixed panel.
  final bool panel;

  static const panelInk = Color(0xFF1D1D1F);
  static const panelPaper = Color(0xFFFFFFFF);
  static const panelFrame = Color(0xFF8A8A8E);

  /// The fixed panel colors.
  static final fixed = SeriesPalette(
    ink: panelInk,
    paper: panelPaper,
    frame: PantasColors.light.fill,
    mark: panelFrame,
    panel: true,
  );

  /// Paints the panel behind the figure, when it has one.
  void paintPanel(Canvas canvas, Size size) {
    if (!panel) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      Paint()..color = paper,
    );
  }
}

/// Where the parts of one figure go, measured from its own outline so that
/// nothing lands on the outline or crosses it.
@visibleForTesting
abstract final class SeriesGeometry {
  /// The corners of a polygon form, or null for a circle.
  static List<Offset>? corners(String form, Offset centre, double r) {
    switch (form) {
      case 'circle':
        return null;
      case 'square':
        return [
          centre + Offset(-r, -r),
          centre + Offset(r, -r),
          centre + Offset(r, r),
          centre + Offset(-r, r),
        ];
      case 'triangle':
        return _ring(centre, r, 3, -math.pi / 2);
      case 'pentagon':
        return _ring(centre, r, 5, -math.pi / 2);
      default:
        return [
          for (var i = 0; i < 10; i++)
            centre +
                Offset(
                      math.cos(-math.pi / 2 + i * math.pi / 5),
                      math.sin(-math.pi / 2 + i * math.pi / 5),
                    ) *
                    (i.isEven ? r : r * 0.42),
        ];
    }
  }

  static List<Offset> _ring(Offset centre, double r, int sides, double start) {
    return [
      for (var i = 0; i < sides; i++)
        centre +
            Offset(
                  math.cos(start + i * 2 * math.pi / sides),
                  math.sin(start + i * 2 * math.pi / sides),
                ) *
                r,
    ];
  }

  static Path formPath(String form, Offset centre, double r) {
    final points = corners(form, centre, r);
    if (points == null) {
      return Path()..addOval(Rect.fromCircle(center: centre, radius: r));
    }
    return Path()..addPolygon(points, true);
  }

  /// How far the outline is from the centre along [angle] (radians, canvas
  /// axes: 0 is right and a quarter turn is down).
  static double boundary(String form, double r, double angle) {
    final points = corners(form, Offset.zero, r);
    if (points == null) return r;
    final dx = math.cos(angle);
    final dy = math.sin(angle);
    var best = r * 2;
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      final ex = b.dx - a.dx;
      final ey = b.dy - a.dy;
      final denom = dx * ey - dy * ex;
      if (denom.abs() < 1e-9) continue;
      final t = (a.dx * ey - a.dy * ex) / denom;
      final u = (a.dx * dy - a.dy * dx) / denom;
      if (t > 0 && u >= 0 && u <= 1 && t < best) best = t;
    }
    return best;
  }

  /// How wide the outline is either side of the centre line, at [dy] below
  /// the centre: the nearer of the two edges.
  static double halfWidthAt(String form, double r, double dy) {
    final points = corners(form, Offset.zero, r);
    if (points == null) return math.sqrt(math.max(r * r - dy * dy, 0));
    var right = r * 2;
    var left = r * 2;
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      if ((a.dy - dy) * (b.dy - dy) > 0 || a.dy == b.dy) continue;
      final x = a.dx + (b.dx - a.dx) * (dy - a.dy) / (b.dy - a.dy);
      if (x >= 0) {
        right = math.min(right, x);
      } else {
        left = math.min(left, -x);
      }
    }
    return math.min(left, right);
  }

  /// Where a row of dots sits: through the middle, but lower in a triangle
  /// and higher in a star, which are wider there.
  static double dotRowOffset(String form, double r) => switch (form) {
        'triangle' => r * 0.2,
        'star' => -r * 0.1,
        _ => 0,
      };

  /// The centres of [count] dots in a row, spread no wider than the outline
  /// allows, and the radius to draw them at. Dots shrink only when the
  /// outline is too narrow for full-size ones.
  static ({List<Offset> centres, double radius}) dotRow(
    String form,
    Offset centre,
    double r,
    int count,
  ) {
    if (count == 0) return (centres: const [], radius: 2.5);
    final dy = dotRowOffset(form, r);
    final half = halfWidthAt(form, r, dy);
    var radius = 2.5;
    var spread = 0.0;
    for (final (candidate, margin) in [(2.5, 4.0), (1.9, 3.5), (1.4, 2.5)]) {
      radius = candidate;
      final room = math.max(half - radius - margin, 0);
      spread = count == 1 ? 0.0 : math.min(r * 0.5, 2 * room / (count - 1));
      if (count == 1 || spread >= radius * 2 + 1.2) break;
    }
    final first = centre.dx - spread * (count - 1) / 2;
    return (
      centres: [
        for (var i = 0; i < count; i++)
          Offset(first + spread * i, centre.dy + dy),
      ],
      radius: radius,
    );
  }

  /// The centre of a corner dot, a fixed share of the way to the outline.
  static Offset cornerDot(String form, String corner, Offset centre, double r) {
    final angle = switch (corner) {
      'top-left' => -3 * math.pi / 4,
      'top-right' => -math.pi / 4,
      'bottom-left' => 3 * math.pi / 4,
      'bottom-right' => math.pi / 4,
      _ => -math.pi / 2,
    };
    final distance = 0.6 * boundary(form, r, angle);
    return centre + Offset(math.cos(angle), math.sin(angle)) * distance;
  }

  /// How long a mark from the centre may run along [angle] and stay inside.
  static double reach(String form, double r, double angle, double share) {
    return math.min(share * r, 0.8 * boundary(form, r, angle));
  }
}

class _SeriesPainter extends CustomPainter {
  _SeriesPainter({
    required this.items,
    required this.blank,
    required this.palette,
    required this.markStyle,
  });

  final List<SeriesItem> items;
  final bool blank;
  final SeriesPalette palette;
  final TextStyle markStyle;

  @override
  void paint(Canvas canvas, Size size) {
    palette.paintPanel(canvas, size);
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.frame;

    final cells = items.length + (blank ? 1 : 0);
    final slot = size.width / cells;
    final radius = math.min(slot * 0.34, size.height * 0.36);
    final cy = size.height / 2;

    for (var i = 0; i < items.length; i++) {
      _drawItem(canvas, items[i], Offset(slot * (i + 0.5), cy), radius);
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
  ) {
    final r = baseRadius * item.scale;
    final path = SeriesGeometry.formPath(item.form, centre, r);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.ink;
    final solid = Paint()
      ..style = PaintingStyle.fill
      ..color = palette.ink;

    canvas.save();
    if (item.rotationDegrees != 0) {
      canvas
        ..translate(centre.dx, centre.dy)
        ..rotate(item.rotationDegrees * math.pi / 180)
        ..translate(-centre.dx, -centre.dy);
    }

    // A part-filled figure that also carries marks is filled at mid gray,
    // so that a dot or a line on the edge of the fill stays readable.
    final hasMarks = item.allLineDegrees.isNotEmpty ||
        item.arrowDegrees != null ||
        item.dotCorner != null ||
        item.dots > 0;
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
          hasMarks
              ? (Paint()..color = Color.lerp(palette.paper, palette.ink, 0.3)!)
              : solid,
        )
        ..restore();
    }
    canvas.drawPath(path, outline);

    // Marks inside the figure. Over a full fill they are drawn in the paper
    // color, or they would vanish into it.
    _drawMarks(
      canvas,
      item,
      centre,
      r,
      item.fill >= 1 ? palette.paper : palette.ink,
    );

    if (item.edgeLines > 0) {
      final step = (r * 1.4) / (item.edgeLines + 1);
      for (var i = 1; i <= item.edgeLines; i++) {
        final x = centre.dx - r * 0.7 + step * i;
        canvas.drawLine(
          Offset(x, centre.dy + r),
          Offset(x, centre.dy + r + 6),
          outline,
        );
      }
    }
    canvas.restore();
  }

  void _drawMarks(
    Canvas canvas,
    SeriesItem item,
    Offset centre,
    double r,
    Color color,
  ) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final solid = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    for (final line in item.allLineDegrees) {
      final angle = (line - 90) * math.pi / 180;
      final length = SeriesGeometry.reach(item.form, r, angle, 0.8);
      canvas.drawLine(
        centre,
        centre + Offset(math.cos(angle) * length, math.sin(angle) * length),
        stroke,
      );
    }

    final arrow = item.arrowDegrees;
    if (arrow != null) {
      final angle = (arrow - 90) * math.pi / 180;
      final length = SeriesGeometry.reach(item.form, r, angle, 0.7);
      final tip =
          centre + Offset(math.cos(angle) * length, math.sin(angle) * length);
      canvas.drawLine(centre, tip, stroke);
      // The head keeps its size unless the arrow had to be shortened.
      final head = r * 0.3 * math.min(1, length / (r * 0.7));
      for (final spread in [2.5, -2.5]) {
        canvas.drawLine(
          tip,
          tip +
              Offset(
                math.cos(angle + spread) * head,
                math.sin(angle + spread) * head,
              ),
          stroke,
        );
      }
    }

    final corner = item.dotCorner;
    if (corner != null) {
      canvas.drawCircle(
        SeriesGeometry.cornerDot(item.form, corner, centre, r),
        3,
        solid,
      );
    }

    final row = SeriesGeometry.dotRow(item.form, centre, r, item.dots);
    for (final dot in row.centres) {
      canvas.drawCircle(dot, row.radius, solid);
    }
  }

  @override
  bool shouldRepaint(_SeriesPainter old) =>
      old.palette != palette ||
      old.markStyle != markStyle ||
      old.items != items ||
      old.blank != blank;
}
