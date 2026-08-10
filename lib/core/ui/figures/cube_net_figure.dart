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
  const CubeNetFigure({required this.cells, super.key});

  static const kind = 'cube-net';

  final List<(int, int)> cells;

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
    return CubeNetFigure(cells: cells);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A flat pattern of ${cells.length} squares joined edge to edge.',
      child: SizedBox(
        height: 160,
        child: CustomPaint(
          painter: _NetPainter(cells: cells, ink: colors.ink),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _NetPainter extends CustomPainter {
  _NetPainter({required this.cells, required this.ink});

  final List<(int, int)> cells;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;

    final rows = cells.map((c) => c.$1).reduce((a, b) => a > b ? a : b) + 1;
    final cols = cells.map((c) => c.$2).reduce((a, b) => a > b ? a : b) + 1;
    final side = [
      (size.height - 16) / rows,
      (size.width - 16) / cols,
    ].reduce((a, b) => a < b ? a : b);

    final originX = (size.width - side * cols) / 2;
    final originY = (size.height - side * rows) / 2;

    for (final (row, col) in cells) {
      canvas.drawRect(
        Rect.fromLTWH(
          originX + col * side,
          originY + row * side,
          side,
          side,
        ),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_NetPainter old) =>
      old.ink != ink || old.cells.length != cells.length;
}
