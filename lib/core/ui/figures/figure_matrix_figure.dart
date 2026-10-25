import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A grid of figures with one cell left blank.
///
/// ```yaml
///     figureSpec:
///       kind: figure-matrix
///       rows: 2
///       cols: 2
///       cells:
///         - form: triangle
///         - form: triangle
///           line: 90
///         - form: square
///         - blank
/// ```
///
/// `cells` runs left to right, top to bottom, and the string `blank` marks
/// the cell the student is answering about. A cell takes the same fields as
/// a figure in a series: `size`, `fill`, `dot`, `dots`, `line`, `arrow`.
///
/// **Exactly one cell may be blank**, and nothing draws what belongs in it.
class FigureMatrixFigure extends StatelessWidget {
  const FigureMatrixFigure({
    required this.rows,
    required this.cols,
    required this.cells,
    super.key,
  });

  static const kind = 'figure-matrix';

  final int rows;
  final int cols;

  /// Row-major. A null entry is the blank cell.
  final List<SeriesItem?> cells;

  /// Null when the spec cannot be read.
  static FigureMatrixFigure? fromSpec(Map<String, Object?> spec) {
    final rows = spec['rows'];
    final cols = spec['cols'];
    if (rows is! int || cols is! int) return null;
    if (rows < 2 || rows > 3 || cols < 2 || cols > 3) return null;

    final raw = spec['cells'];
    if (raw is! List || raw.length != rows * cols) return null;

    final cells = <SeriesItem?>[];
    var blanks = 0;
    for (final entry in raw) {
      if (entry == 'blank') {
        blanks++;
        cells.add(null);
        continue;
      }
      final item = FigureSeriesFigure.parseItem(entry);
      if (item == null) return null;
      cells.add(item);
    }
    // One blank, always. Two would make the question unanswerable and none
    // would make it pointless.
    if (blanks != 1) return null;

    return FigureMatrixFigure(rows: rows, cols: cols, cells: cells);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.type;
    return Semantics(
      label: 'A $rows by $cols grid of figures with one cell left empty.',
      child: SizedBox(
        height: rows == 2 ? 130 : 180,
        child: CustomPaint(
          painter: _MatrixPainter(
            rows: rows,
            cols: cols,
            cells: cells,
            ink: colors.label,
            faint: colors.fill,
            markStyle: styles.emphasized.copyWith(color: colors.secondaryLabel),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _MatrixPainter extends CustomPainter {
  _MatrixPainter({
    required this.rows,
    required this.cols,
    required this.cells,
    required this.ink,
    required this.faint,
    required this.markStyle,
  });

  final int rows;
  final int cols;
  final List<SeriesItem?> cells;
  final Color ink;
  final Color faint;
  final TextStyle markStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final rule = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = faint;

    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final radius = math.min(cellW, cellH) * 0.3;

    // The grid, drawn faint so the figures inside it stay the loud thing.
    for (var r = 1; r < rows; r++) {
      canvas.drawLine(
        Offset(0, cellH * r),
        Offset(size.width, cellH * r),
        rule,
      );
    }
    for (var c = 1; c < cols; c++) {
      canvas.drawLine(
        Offset(cellW * c, 0),
        Offset(cellW * c, size.height),
        rule,
      );
    }

    for (var i = 0; i < cells.length; i++) {
      final centre = Offset(
        cellW * (i % cols + 0.5),
        cellH * (i ~/ cols + 0.5),
      );
      final cell = cells[i];
      if (cell == null) {
        final mark = TextPainter(
          text: TextSpan(text: '?', style: markStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        mark.paint(canvas, centre - Offset(mark.width / 2, mark.height / 2));
        continue;
      }
      FigureSeriesFigure.paintItem(canvas, cell, centre, radius, ink);
    }
  }

  @override
  bool shouldRepaint(_MatrixPainter old) =>
      old.rows != rows || old.cols != cols || old.ink != ink;
}
