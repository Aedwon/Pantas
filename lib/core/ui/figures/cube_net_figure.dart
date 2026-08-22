import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A flat pattern of squares, the kind that may or may not fold into a cube.
///
/// ```yaml
///     figureSpec:
///       kind: cube-net
///       cells:
///         - [0, 1]
///         - [1, 0]
///         - [1, 1]
///         - [1, 2]
///         - [2, 1]
///         - [3, 1]
/// ```
///
/// Each cell is a `[row, column]` pair on a grid. **Nothing says whether it
/// folds**: that is the question, and a drawing that hinted at the answer
/// would give it away.
class CubeNetFigure extends StatelessWidget {
  const CubeNetFigure({
    required this.cells,
    required this.labels,
    required this.showFolded,
    super.key,
  });

  static const kind = 'cube-net';

  final List<(int, int)> cells;
  final List<String?> labels;
  final bool showFolded;

  /// Null when the spec cannot be read.
  static CubeNetFigure? fromSpec(Map<String, Object?> spec) {
    final raw = spec['cells'];
    if (raw is! List || raw.length < 2 || raw.length > 8) return null;

    final cells = <(int, int)>[];
    for (final entry in raw) {
      if (entry is! List || entry.length != 2) return null;
      final row = entry[0];
      final col = entry[1];
      if (row is! int || col is! int) return null;
      if (row < 0 || row > 5 || col < 0 || col > 5) return null;
      if (cells.contains((row, col))) return null;
      cells.add((row, col));
    }
    final rawLabels = spec['labels'];
    final labels = <String?>[];
    if (rawLabels == null) {
      labels.addAll(List<String?>.filled(cells.length, null));
    } else {
      if (rawLabels is! List || rawLabels.length != cells.length) return null;
      for (final value in rawLabels) {
        if (value is! String || value.isEmpty || value.length > 12) return null;
        labels.add(value);
      }
    }

    final showFolded = spec['showFolded'] ?? false;
    if (showFolded is! bool) return null;
    return CubeNetFigure(
      cells: cells,
      labels: labels,
      showFolded: showFolded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Semantics(
      label: 'A flat pattern of ${cells.length} squares joined edge to edge'
          '${showFolded ? ', beside a folded cube' : ''}.',
      child: SizedBox(
        height: 160,
        child: CustomPaint(
          painter: _NetPainter(
            cells: cells,
            labels: labels,
            showFolded: showFolded,
            ink: colors.ink,
            labelStyle: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _NetPainter extends CustomPainter {
  _NetPainter({
    required this.cells,
    required this.labels,
    required this.showFolded,
    required this.ink,
    required this.labelStyle,
  });

  final List<(int, int)> cells;
  final List<String?> labels;
  final bool showFolded;
  final Color ink;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;

    final netBounds = showFolded
        ? Rect.fromLTWH(8, 8, size.width * 0.58 - 12, size.height - 16)
        : Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    _paintNet(canvas, netBounds, stroke);
    if (showFolded) {
      _paintFoldedCube(
        canvas,
        Rect.fromLTWH(
          size.width * 0.62,
          size.height * 0.25,
          size.width * 0.32,
          size.height * 0.5,
        ),
        stroke,
      );
    }
  }

  void _paintNet(Canvas canvas, Rect bounds, Paint stroke) {
    final rows = cells.map((c) => c.$1).reduce((a, b) => a > b ? a : b) + 1;
    final cols = cells.map((c) => c.$2).reduce((a, b) => a > b ? a : b) + 1;
    final side = [
      bounds.height / rows,
      bounds.width / cols,
    ].reduce((a, b) => a < b ? a : b);

    final originX = bounds.left + (bounds.width - side * cols) / 2;
    final originY = bounds.top + (bounds.height - side * rows) / 2;

    for (var i = 0; i < cells.length; i++) {
      final (row, col) = cells[i];
      final cell = Rect.fromLTWH(
        originX + col * side,
        originY + row * side,
        side,
        side,
      );
      canvas.drawRect(cell, stroke);
      final label = labels[i];
      if (label != null) _drawLabel(canvas, label, cell.center);
    }
  }

  void _paintFoldedCube(Canvas canvas, Rect bounds, Paint stroke) {
    final front = Rect.fromLTWH(
      bounds.left,
      bounds.top + bounds.height * 0.22,
      bounds.width * 0.68,
      bounds.height * 0.68,
    );
    final depth = Offset(bounds.width * 0.24, -bounds.height * 0.2);
    canvas
      ..drawRect(front, stroke)
      ..drawLine(front.topLeft, front.topLeft + depth, stroke)
      ..drawLine(front.topRight, front.topRight + depth, stroke)
      ..drawLine(front.bottomRight, front.bottomRight + depth, stroke)
      ..drawLine(front.topLeft + depth, front.topRight + depth, stroke)
      ..drawLine(front.topRight + depth, front.bottomRight + depth, stroke);
  }

  void _drawLabel(Canvas canvas, String text, Offset center) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_NetPainter old) =>
      old.ink != ink ||
      old.labelStyle != labelStyle ||
      !listEquals(old.cells, cells) ||
      !listEquals(old.labels, labels) ||
      old.showFolded != showFolded;
}
