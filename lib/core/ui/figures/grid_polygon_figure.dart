import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A polygon traced on a unit square grid, for area questions.
///
/// ```yaml
///     figureSpec:
///       kind: grid-polygon
///       width: 8
///       height: 4
///       vertices: [[0, 0], [8, 0], [5, 4], [0, 4]]
///       xTicks: [0, 5, 8]              # optional, labels along the bottom
///       splits: [[[5, 0], [5, 4]]]     # optional, dashed lines
///       labels:                        # optional, text at a point
///         - { at: [2.5, 2], text: "5 × 4 = 20" }
///       gridWithinPolygon: true        # optional, grid only inside the shape
/// ```
///
/// The grid runs 0..`width` by 0..`height`, with `(0, 0)` at the bottom
/// left. Vertices are joined in the order given and the shape is closed.
///
/// **Before the solution, draw the shape only.** A split or a label such as
/// `5 × 4 = 20` gives the method away, so a question figure leaves out
/// `splits` and `labels`. They are for a figure shown after the solution.
///
/// Two shapes side by side use `panels`, each panel carrying the same keys
/// and an optional `title`:
///
/// ```yaml
///     figureSpec:
///       kind: grid-polygon
///       panels:
///         - { title: "P", width: 6, height: 4, vertices: [[0, 0], ...] }
///         - { title: "Q", width: 5, height: 5, vertices: [[0, 0], ...] }
/// ```
class GridPolygonFigure extends StatelessWidget {
  const GridPolygonFigure({required this.panels, super.key});

  static const kind = 'grid-polygon';

  static const _maxSide = 12;
  static const _maxVertices = 12;
  static const _maxPanels = 3;

  final List<GridPolygonPanel> panels;

  /// Null when the spec cannot be read.
  static GridPolygonFigure? fromSpec(Map<String, Object?> spec) {
    final rawPanels = spec['panels'];
    if (rawPanels == null) {
      final panel = GridPolygonPanel.fromSpec(spec);
      return panel == null ? null : GridPolygonFigure(panels: [panel]);
    }
    if (rawPanels is! List ||
        rawPanels.length < 2 ||
        rawPanels.length > _maxPanels) {
      return null;
    }
    final panels = <GridPolygonPanel>[];
    for (final raw in rawPanels) {
      if (raw is! Map) return null;
      final panel = GridPolygonPanel.fromSpec(raw.cast<String, Object?>());
      if (panel == null) return null;
      panels.add(panel);
    }
    return GridPolygonFigure(panels: panels);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = context.type.subhead.copyWith(
      color: colors.secondaryLabel,
    );
    final titleStyle = context.type.subhead.copyWith(
      color: colors.label,
      fontWeight: FontWeight.w600,
    );
    final first = panels.first;
    final semantics = panels.length == 1
        ? 'A polygon with ${first.vertices.length} corners on a '
            '${first.width} by ${first.height} unit grid.'
        : '${panels.length} polygons, each on its own unit grid.';
    return Semantics(
      label: semantics,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available =
              constraints.hasBoundedWidth ? constraints.maxWidth : 358.0;
          // Panels share the width. A gap of 16 separates them.
          final panelWidth =
              (available - 16 * (panels.length - 1)) / panels.length;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < panels.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                SizedBox(
                  width: panelWidth,
                  child: _PanelView(
                    panel: panels[i],
                    width: panelWidth,
                    accent: colors.accent,
                    ink: colors.label,
                    gridColor: colors.fill,
                    labelStyle: labelStyle,
                    titleStyle: titleStyle,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// One grid with its polygon.
@immutable
class GridPolygonPanel {
  const GridPolygonPanel({
    required this.width,
    required this.height,
    required this.vertices,
    this.title,
    this.splits = const [],
    this.labels = const [],
    this.xTicks = const [],
    this.gridWithinPolygon = false,
  });

  final int width;
  final int height;
  final List<Offset> vertices;
  final String? title;
  final List<(Offset, Offset)> splits;
  final List<(Offset, String)> labels;
  final List<int> xTicks;
  final bool gridWithinPolygon;

  static GridPolygonPanel? fromSpec(Map<String, Object?> spec) {
    final width = spec['width'];
    final height = spec['height'];
    if (width is! int || height is! int) return null;
    if (width < 1 || height < 1) return null;
    if (width > GridPolygonFigure._maxSide ||
        height > GridPolygonFigure._maxSide) {
      return null;
    }

    bool inside(Offset p) =>
        p.dx >= 0 && p.dx <= width && p.dy >= 0 && p.dy <= height;

    Offset? point(Object? raw) {
      if (raw is! List || raw.length != 2) return null;
      final x = raw[0];
      final y = raw[1];
      if (x is! num || y is! num || !x.isFinite || !y.isFinite) return null;
      final p = Offset(x.toDouble(), y.toDouble());
      return inside(p) ? p : null;
    }

    final rawVertices = spec['vertices'];
    if (rawVertices is! List ||
        rawVertices.length < 3 ||
        rawVertices.length > GridPolygonFigure._maxVertices) {
      return null;
    }
    final vertices = <Offset>[];
    for (final raw in rawVertices) {
      final p = point(raw);
      if (p == null) return null;
      vertices.add(p);
    }

    final splits = <(Offset, Offset)>[];
    final rawSplits = spec['splits'];
    if (rawSplits != null) {
      if (rawSplits is! List || rawSplits.length > 6) return null;
      for (final raw in rawSplits) {
        if (raw is! List || raw.length != 2) return null;
        final a = point(raw[0]);
        final b = point(raw[1]);
        if (a == null || b == null || a == b) return null;
        splits.add((a, b));
      }
    }

    final labels = <(Offset, String)>[];
    final rawLabels = spec['labels'];
    if (rawLabels != null) {
      if (rawLabels is! List || rawLabels.length > 6) return null;
      for (final raw in rawLabels) {
        if (raw is! Map) return null;
        final at = point(raw['at']);
        final text = raw['text'];
        if (at == null || text is! String) return null;
        if (text.trim().isEmpty || text.length > 24) return null;
        labels.add((at, text));
      }
    }

    final xTicks = <int>[];
    final rawTicks = spec['xTicks'];
    if (rawTicks != null) {
      if (rawTicks is! List || rawTicks.length > width + 1) return null;
      for (final raw in rawTicks) {
        if (raw is! int || raw < 0 || raw > width) return null;
        xTicks.add(raw);
      }
    }

    final title = spec['title'];
    if (title != null && (title is! String || title.trim().isEmpty)) {
      return null;
    }
    final within = spec['gridWithinPolygon'] ?? false;
    if (within is! bool) return null;

    return GridPolygonPanel(
      width: width,
      height: height,
      vertices: vertices,
      title: title as String?,
      splits: splits,
      labels: labels,
      xTicks: xTicks,
      gridWithinPolygon: within,
    );
  }
}

const _pad = 8.0;
const _tickRow = 22.0;
const _maxCell = 48.0;

class _PanelView extends StatelessWidget {
  const _PanelView({
    required this.panel,
    required this.width,
    required this.accent,
    required this.ink,
    required this.gridColor,
    required this.labelStyle,
    required this.titleStyle,
  });

  final GridPolygonPanel panel;
  final double width;
  final Color accent;
  final Color ink;
  final Color gridColor;
  final TextStyle labelStyle;
  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    final cell = math.min(
      _maxCell,
      math.max(1, (width - 2 * _pad) / panel.width),
    );
    final height =
        panel.height * cell + 2 * _pad + (panel.xTicks.isEmpty ? 0 : _tickRow);
    final title = panel.title;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(title, style: titleStyle),
          ),
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            size: Size(width, height),
            painter: GridPolygonPainter(
              panel: panel,
              accent: accent,
              ink: ink,
              gridColor: gridColor,
              labelStyle: labelStyle,
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws one panel. Public so the render tests can hold it to account.
class GridPolygonPainter extends CustomPainter {
  GridPolygonPainter({
    required this.panel,
    required this.accent,
    required this.ink,
    required this.gridColor,
    required this.labelStyle,
  });

  final GridPolygonPanel panel;
  final Color accent;
  final Color ink;
  final Color gridColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = math.min(
      _maxCell,
      math.max(1, (size.width - 2 * _pad) / panel.width),
    );
    final gridWidth = cell * panel.width;
    final left = (size.width - gridWidth) / 2;
    const top = _pad;
    Offset map(Offset p) =>
        Offset(left + p.dx * cell, top + (panel.height - p.dy) * cell);

    final shape = Path()..addPolygon([...panel.vertices.map(map)], true);

    final grid = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.save();
    if (panel.gridWithinPolygon) canvas.clipPath(shape);
    for (var x = 0; x <= panel.width; x++) {
      canvas.drawLine(
        map(Offset(x.toDouble(), 0)),
        map(Offset(x.toDouble(), panel.height.toDouble())),
        grid,
      );
    }
    for (var y = 0; y <= panel.height; y++) {
      canvas.drawLine(
        map(Offset(0, y.toDouble())),
        map(Offset(panel.width.toDouble(), y.toDouble())),
        grid,
      );
    }
    canvas
      ..restore()
      ..drawPath(
        shape,
        Paint()
          ..color = accent.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        shape,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );

    final dash = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (final (a, b) in panel.splits) {
      _dashed(canvas, map(a), map(b), dash);
    }

    for (final (at, text) in panel.labels) {
      _text(canvas, text, map(at), labelStyle.copyWith(color: ink));
    }

    final baseline = top + panel.height * cell;
    for (final x in panel.xTicks) {
      _text(
        canvas,
        '$x',
        Offset(left + x * cell, baseline + _tickRow / 2 + 2),
        labelStyle,
      );
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0;
    const gap = 5.0;
    final length = (b - a).distance;
    if (length == 0) return;
    final dir = (b - a) / length;
    for (var d = 0.0; d < length; d += dash + gap) {
      final end = math.min(d + dash, length);
      canvas.drawLine(a + dir * d, a + dir * end, paint);
    }
  }

  void _text(Canvas canvas, String text, Offset center, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(GridPolygonPainter old) =>
      old.accent != accent ||
      old.ink != ink ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle ||
      old.panel != panel;
}
